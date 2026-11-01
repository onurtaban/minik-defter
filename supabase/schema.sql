-- Minik Defter veritabanı kurulumu
-- Supabase panelinde SQL Editor > New query'ye yapıştırıp Run'a basın. Tekrar çalıştırmak güvenlidir.

create table if not exists public.items (
  family     text        not null,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default clock_timestamp(),
  primary key (family, id)
);
create index if not exists items_family_updated on public.items (family, updated_at);

-- Tabloya doğrudan erişim kapalı. Uygulama yalnızca aşağıdaki fonksiyonları aile koduyla çağırır.
alter table public.items enable row level security;
revoke all on public.items from anon, authenticated;

create or replace function public.md_valid(p_family text) returns boolean
language sql immutable as $$ select p_family ~ '^[A-Z0-9]{12}$' $$;

-- p_since: mikrosaniye cinsinden son eşitleme zamanı (0 = hepsi)
create or replace function public.md_get(p_family text, p_since bigint default 0)
returns table (id text, data jsonb, ts bigint)
language sql stable security definer set search_path = public as $$
  select i.id, i.data, (extract(epoch from i.updated_at) * 1000000)::bigint
  from public.items i
  where public.md_valid(p_family) and i.family = p_family
    and i.updated_at >= to_timestamp(greatest(p_since - 5000000, 0) / 1000000.0)
  order by i.updated_at
  limit 5000;
$$;

create or replace function public.md_put(p_family text, p_id text, p_data jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.md_valid(p_family) or length(p_id) > 100 or pg_column_size(p_data) > 20000 then
    raise exception 'gecersiz istek';
  end if;
  insert into public.items (family, id, data, updated_at) values (p_family, p_id, p_data, clock_timestamp())
  on conflict (family, id) do update set data = excluded.data, updated_at = clock_timestamp();
end $$;

create or replace function public.md_delete(p_family text, p_id text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.md_valid(p_family) then raise exception 'gecersiz istek'; end if;
  -- Silinen kaydı işaretli bırakır, böylece diğer telefon da silindiğini öğrenir.
  update public.items set data = '{"_deleted": true}'::jsonb, updated_at = clock_timestamp()
  where family = p_family and id = p_id;
end $$;

create or replace function public.md_exists(p_family text)
returns boolean language sql stable security definer set search_path = public as $$
  select public.md_valid(p_family) and exists (select 1 from public.items where family = p_family);
$$;

revoke all on function public.md_get(text, bigint), public.md_put(text, text, jsonb),
  public.md_delete(text, text), public.md_exists(text) from public;
grant execute on function public.md_get(text, bigint), public.md_put(text, text, jsonb),
  public.md_delete(text, text), public.md_exists(text), public.md_valid(text) to anon, authenticated;
