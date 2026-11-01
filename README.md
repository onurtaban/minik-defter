# Minik Defter

Bebek bakım defteri: beslenme, uyku, bez ve sağlık kaydı, hatırlatıcılar, notlar, aşı takvimi (T.C. Sağlık Bakanlığı) ve büyüme grafiği (DSÖ ortanca eğrisiyle).

Telefona yüklenebilen bir web uygulamasıdır (PWA). İki ebeveyn bir **aile kodu** ile aynı kayıtları paylaşır; hesap açmak gerekmez. Veriler Supabase'de tutulur.

## Kurulum

1. **Veritabanı:** Supabase panelinde *SQL Editor → New query* açın, `supabase/schema.sql` dosyasının içeriğini yapıştırıp *Run*'a basın.
2. **Yayın:** GitHub'da *Settings → Pages → Build and deployment* altında *Source: Deploy from a branch*, *Branch: main / (root)* seçin. Ücretsiz GitHub hesabında Pages için deponun **public** olması gerekir. Depoda gizli bilgi yoktur; `index.html` içindeki Supabase anahtarı tarayıcıda kullanılmak için tasarlanmış herkese açık (publishable) anahtardır.
3. **Telefona yükleme:** Yayın adresini açın.
   - iPhone (Safari): Paylaş → *Ana Ekrana Ekle*
   - Android (Chrome): ⋮ → *Ana ekrana ekle* / *Uygulamayı yükle*

## Kullanım

- İlk telefonda **Yeni aile defteri** oluşturun. Aile kodu ekranda görünür (sonra sağ üstteki kişi simgesi → *Aile kodu*).
- İkinci telefonda **Var olan deftere bağlan** bölümüne bu kodu girin.
- Kayıtlar internet yokken de eklenebilir; bağlantı gelince otomatik gönderilir.

## Bilinen sınırlar

- Hatırlatıcılar şimdilik yalnızca uygulama açıkken uyarı verir.
- Aile kodunu bilen herkes kayıtları okuyup değiştirebilir; kodu yalnızca aile içinde paylaşın.

## Dosyalar

- `index.html`: uygulamanın tamamı
- `sw.js`, `manifest.webmanifest`, `icons/`: telefona yükleme ve çevrimdışı açılış
- `vendor/supabase.js`: supabase-js 2.45.4 (UMD)
- `supabase/schema.sql`: tablo ve fonksiyonlar
