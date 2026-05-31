# Barcode Boss — Playtest Rehberi (Faz 5)

Bu doküman iki kitleye yönelik:
1. **Sen** (geliştirici): tester'a ne göndereceksin, ne soracaksın, ne ölçeceksin.
2. **Tester**: oyunu nasıl deneyeceksin, ne not edeceksin.

---

## Tester'a gönderilecek paket

- `app-arm64-v8a-release.apk` (~20 MB) — bkz. [release-build.md](release-build.md)
- Aşağıdaki **tester brief** mesajı (WhatsApp/Telegram/e-posta)
- Geri bildirim formu linki (Google Form / Notion / e-posta)

---

## Tester Brief (kopyala-yapıştır)

> Selam! Yaptığım mahalle marketi simülatör oyununun ilk testini deneyebilir
> misin? 10-15 dakika sürer.
>
> **APK linki:** [...]
>
> **Kurulum:** Android telefonda APK'yı indir → "Bilinmeyen kaynaklara izin
> ver" sorarsa kabul et → kur.
>
> **Ne yapman lazım:**
> 1. Oyunu aç, "Vardiyaya Başla" → Stok/Sipariş/Fiyat sekmelerine bir göz at
>    → "VARDİYAYI BAŞLAT" bas.
> 2. 2.5 dakikalık vardiyada gelen müşterilerin ürünlerini **sola swipe**
>    ederek tara (ya da Ayarlar'dan Tap modunu aç).
> 3. Ödeme ekranında nakit ise "Tamam"a bas, bozuk para ise 3 seçenekten
>    doğru para üstünü seç.
> 4. Vardiya bitince raporu oku, geri Hazırlık'a dön, fiyat ayarla / sipariş
>    ver, **3-4 vardiya** oyna.
>
> **Bana yazacakların:**
> - Bir yer takıldıysan / kafan karıştıysa: ne oluyordu?
> - En keyif aldığın an?
> - En sıkıcı / iten an?
> - Çökme oldu mu? Olduysa ne yapıyordun?
> - Telefon modeli + Android sürümü.

---

## Test senaryoları (kendi smoke testin)

Yeni build'i her tester'a göndermeden önce kendin geç:

### S1 — Cold start (tutorial fresh)
1. Önceki kurulumu kaldır (`adb uninstall com.mfbilgin.barcode_boss`).
2. Yeni APK kur → aç → "Hoş geldin!" tutorial banner görünmeli.
3. Bakiye = `🪙 1.000,00`, Seviye 1 · Vardiya 1.
4. **Beklenen:** Crash yok, banner kapatılabiliyor.

### S2 — Vardiya akışı (golden path)
1. Vardiyaya Başla → Stok tab açılır → 3 ürün "Yeterli" (Ekmek/Süt/Maden Suyu).
2. VARDİYAYI BAŞLAT → kasa ekranı yüklenir.
3. Bant'tan ilk ürün scanner'a gelir → sola swipe → beep, ürün soldan çıkar.
4. Sepet bitince ödeme overlay'i açılır → "Tamam" veya doğru para üstünü seç.
5. 2.5 dk sonra vardiya kapanır → rapor ekranı.
6. **Beklenen:** Net kâr pozitif, yıldız 3-5 arası, "Yeni başlayan bonusu: +🪙 50,00"
   satırı **VARSA** §14.3 çalışıyor demektir.

### S3 — §14.3 tutorial bonusu (5 vardiya boyunca)
- Vardiya 1-5: rapor ekranında **"Yeni başlayan bonusu: +🪙 50,00"** satırı görünmeli.
- Vardiya 6+: bu satır kaybolmalı.

### S4 — §14.4 stok=0 lifeline
- Tüm ürün stoğunu tüket (birkaç vardiya hiç sipariş verme).
- Hazırlık'ta "VARDİYAYI BAŞLAT" basınca:
  - Dialog açılır: **"Tüm stoğun bitti"**.
  - Sipariş sekmesine otomatik geçer.
  - Bakiye < 200 BC ise dialog mesajında "🪙 200 avans verildi" yazar ve
    bakiye 200 BC artar.

### S5 — §14.2 acil avans
- En zor tetik. Manuel: birçok pahalı sipariş ver → tüm bakiyeni yak → vardiya boş geç.
- Bakiye < 100 BC + tüm inv = 0 + pending = 0 olunca vardiya sonu:
  - Rapor ekranında **"Acil avans: +🪙 500,00"** satırı.
  - Popup: **"Acil avans aldın!"** — sonraki 3 vardiyada %20 kesinti.
- Sonraki vardiyalarda raporda "Avans geri ödemesi: -🪙 X,XX" satırı görünmeli.

### S6 — Persistence
1. Vardiya bitir → uygulamayı tamamen kapat (recent apps'tan kaldır).
2. Tekrar aç → vardiya numarası, bakiye, XP **korunmuş** olmalı.

### S7 — Crash güvenliği (telemetri)
Bilinçli crash testi (geçici):
```dart
FirebaseCrashlytics.instance.crash()
```
satırını main'e ekle, çalıştır → Firebase Console > Crashlytics'te 5-10 dk içinde rapor.

### S8 — Tap modu
- Ayarlar → "Tap modu" aç → kasa ekranında swipe yerine ürüne tek tap ile tara.

---

## Ölçüm — neye bakacaksın

### Firebase Console (DebugView ile)
Önce: `adb shell setprop debug.firebase.analytics.app com.mfbilgin.barcode_boss`

Beklenen event sıklığı (1 oturum, 3 vardiya):
| Event | Beklenen sayı |
|---|---|
| `app_opened` | 1 |
| `shift_started` | 3 |
| `shift_completed` | 3 |
| `customer_completed` | 20-40 |
| `customer_lost` | 0-3 (oyuncu çok yavaşsa) |
| `order_placed` | 2-5 |
| `price_changed` | 0-3 |
| `tutorial_step_completed` | 2 (welcome + prepTabs) |
| `store_level_up` | 0 (3 vardiya level 1'i geçmeye yetmez) |

### Subjektif (tester yorumundan)
- **Sabır eğrisi:** "Çok hızlı / Çok yavaş" diyenlerin oranı.
- **Fiyat anlaşılırlığı:** "Slider'ı anlamadım" diyen var mı?
- **Tap vs swipe tercihi.**
- **Bozuk para 3-option:** Doğru olanı bulmak kolay mı?
- **Estetik:** "Sevimli / Çocuksu / Profesyonel" çıkanların oranı.

---

## Geri bildirim formu — örnek sorular

1. Telefon modeli + Android sürümü?
2. Kaç vardiya oynadın?
3. 1-10 arası genel eğlence puanı?
4. Bir tane şey değiştirebilseydin ne olurdu?
5. Arkadaşına önerir misin? (Net Promoter Score)
6. Çökme / takılma yaşadın mı? Hangi ekranda?
7. (Açık uçlu) İlk 30 saniye seni içine çekti mi?

---

## Faz 5 başarı kriterleri

- ≥ 5 tester (3 cihaz tipi: low-end / mid / flagship)
- 0 reproducible crash (Crashlytics'te aynı crash 2+ cihazda)
- Median oturum süresi ≥ 8 dakika (3+ vardiya tamamlanmış)
- NPS ≥ 7/10
- §14.3 tetiklenmesi tüm cihazlarda doğrulandı

Bunlar tamamsa → Faz 6 (monetizasyon) başlayabilir.
