# KVKK Uyumu ve Privacy Policy

> **Disclaimer:** Bu doküman teknik rehberdir, hukuki tavsiye değildir. Faz 7'de
> Play Store'a yüklemeden önce bir KVKK avukatına / şirketinin hukuk birimine
> son metni gözden geçirtin. Tek geliştirici / hobi projesi için aşağıdaki
> şablon iyi bir başlangıç noktasıdır.

## "Kullanıcı verisi yok" yanılgısı

Senin yazdığın kod sıfır kullanıcı verisi topluyor olabilir (kayıt yok,
e-posta yok, ad yok). Ama:

| Veri | Kim toplar? | KVKK kişisel veri mi? |
|---|---|---|
| AAID (Android Advertising ID) | Firebase Analytics — otomatik | ✅ Evet |
| Firebase pseudo-ID (app instance) | Firebase Analytics — otomatik | ✅ Evet (cihaz parmak izi) |
| IP adresi | Analytics + Crashlytics — otomatik | ✅ Evet |
| Cihaz modeli + Android sürümü + dil | Analytics + Crashlytics | ⚠ Tekilse evet |
| Crash stack trace + Dart hata mesajı | Crashlytics | ⚠ İçeriğine göre |
| Gameplay event'ler (shift, customer, price) | Senin kodun → Firebase | ⚠ AAID ile birleşince evet |

**Sonuç:** Firebase Analytics + Crashlytics açık olduğu sürece KVKK'ya tabisin.
Türkiye'deki tek bir cihazdan veri akıyorsa yeter.

## Üç seviye uyum

### Seviye 1 — Minimum (Faz 5 playtest için yeterli)
- [x] Aşağıdaki Privacy Policy şablonunu doldurup bir public URL'de yayınla
      (GitHub Pages / Notion / kişisel site).
- [ ] Tester'a APK gönderirken bu URL'i de yolla.
- [ ] App içinde Ayarlar > "Gizlilik Politikası" linki (URL'e gider).

### Seviye 2 — Consent banner (Faz 6 öncesi)
- [ ] İlk açılışta modal: "Anonim kullanım verisi toplayabilir miyiz?"
      [Evet] / [Hayır].
- [ ] [Hayır] → `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)`
      ve `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false)`.
- [ ] Karar Hive'da `settings_v1.consent_analytics` olarak saklanır,
      Ayarlar'da değiştirilebilir.

### Seviye 3 — Tam KVKK uyumu (Faz 7 Play Store öncesi)
- [ ] Veri silme talebi mekanizması (e-posta linki yeterli olabilir;
      Firebase Analytics → AAID reset talimatı + Crashlytics user opt-out).
- [ ] Veri Sorumlusu Sicili (VERBİS) kaydı — gerçek/tüzel kişi ayrımına göre
      (çoğu hobi geliştirici muaf olabilir; KVKK'nın güncel eşiklerini kontrol et).
- [ ] Play Console'a Privacy Policy URL'i + Data Safety formu doldur.
- [ ] AdMob / IAP eklenirse: ek izinler.

---

## Privacy Policy Şablonu (TR)

> Aşağıdakini düz metin olarak bir markdown sayfasına koy, kendi adın/iletişim
> bilgilerinle değiştir. Yayın yerleri için fikirler:
> - GitHub Pages: `github.com/<kullanıcı>/<repo>/blob/main/PRIVACY.md`
>   → `https://<kullanıcı>.github.io/<repo>/privacy.html`
> - Notion public sayfa
> - Kendi domain'in varsa: `barcodeboss.app/privacy`

```markdown
# Gizlilik Politikası — Barcode Boss

**Son güncelleme:** [TARİH]
**Veri Sorumlusu:** Muhammet Bilgin (measlan.tr@gmail.com)

## 1. Topladığımız veriler

Barcode Boss kayıt gerektirmez, e-posta veya kişisel kimlik bilgisi
istemez. Yalnızca aşağıdaki anonim ve teknik verileri, Google Firebase
hizmetleri aracılığıyla otomatik olarak toplarız:

- **Cihaz bilgileri:** model, üretici, Android sürümü, ekran boyutu, dil.
- **Uygulama tanımlayıcıları:** Android Advertising ID (AAID),
  Firebase pseudo-ID (uygulama yeniden kurulduğunda sıfırlanır).
- **Kullanım istatistikleri:** Hangi ekranların kullanıldığı, vardiya
  sayısı, ortalama oyun süresi, satın alma davranışı (B-Coin işlemleri),
  ayarların hangi seçenekleri.
- **Çökme raporları:** Uygulama çöktüğünde teknik hata izi (stack trace),
  cihaz durumu (RAM, depolama). Kişisel veri içermez.
- **IP adresi:** Firebase tarafından coğrafi konum (ülke düzeyinde) için
  geçici olarak işlenir ve loglarda saklanmaz.

**Toplamadığımız:** Konum (GPS), kişi listesi, fotoğraf, mikrofon, kamera,
SMS, arama kayıtları, e-posta, parola, kredi kartı.

## 2. Verileri neden topluyoruz

- Oyunu iyileştirmek (hangi mekanikler eğleniyor, hangileri sıkıcı).
- Çökme ve hatalara hızla yanıt vermek.
- Performans sorunlarını tespit etmek (yavaş ekranlar, donmalar).

## 3. Verileri kimlerle paylaşıyoruz

- **Google LLC** (Firebase Analytics + Crashlytics) — Google'ın gizlilik
  politikası: https://policies.google.com/privacy
- Başka hiçbir üçüncü taraf ile paylaşmıyoruz. Reklam ağı yok, satış yok.

## 4. Verilerin saklama süresi

- Analytics olayları: 14 ay (Firebase varsayılan).
- Crash raporları: 90 gün.
- Cihazınızdaki oyun verisi (bakiye, vardiya sayısı): siz uygulamayı
  silene kadar telefonunuzda, Firebase'e gönderilmez.

## 5. Haklarınız (KVKK m.11)

İstediğiniz zaman aşağıdakileri talep edebilirsiniz:
- Hakkınızda hangi verilerin tutulduğunu öğrenme
- Düzeltme veya silme
- Veri toplamayı durdurma

Talepleriniz için: **measlan.tr@gmail.com**

Ayrıca uygulama içinden **Ayarlar > Gizlilik > Anonim veri toplama**
seçeneğini kapatarak Firebase Analytics ve Crashlytics'i devre dışı
bırakabilirsiniz.

## 6. Çocuklar

Barcode Boss 13 yaş altı çocuklara yönelik değildir. Çocuğunuzun
verisini topladığımızı düşünüyorsanız bizimle iletişime geçin.

## 7. Değişiklikler

Bu politika değiştiğinde "Son güncelleme" tarihi yenilenir. Önemli
değişikliklerde uygulama açılışında bilgilendirme gösterilir.

## 8. İletişim

Muhammet Bilgin — measlan.tr@gmail.com
```

---

## Uygulamadan link verme

Faz 5'te (consent banner'dan önce) en azından Ayarlar ekranına bir link ekle:

```dart
ListTile(
  leading: const Icon(Icons.policy_outlined),
  title: const Text('Gizlilik Politikası'),
  trailing: const Icon(Icons.open_in_new),
  onTap: () => launchUrl(Uri.parse('https://...privacy URL...')),
)
```

`url_launcher` paketini pubspec'e ekle: `url_launcher: ^6.3.0`.

---

## Consent banner kod iskeleti (Faz 6)

`lib/widgets/consent_banner.dart` (eksik):

```dart
class ConsentBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (settings.consentDecided) return const SizedBox.shrink();
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Oyunu iyileştirmek için anonim kullanım verisi '
                      'toplayabilir miyiz? Kişisel veri içermez.'),
            Row(children: [
              TextButton(
                onPressed: () => ref.read(settingsProvider.notifier)
                    .setConsent(false),
                child: const Text('Hayır'),
              ),
              FilledButton(
                onPressed: () => ref.read(settingsProvider.notifier)
                    .setConsent(true),
                child: const Text('Evet'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
```

`SettingsNotifier.setConsent(bool)`:
```dart
Future<void> setConsent(bool granted) async {
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(granted);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(granted);
  _service.consentDecided = true;
  _service.consentAnalytics = granted;
  state = state.copyWith(consentDecided: true, consentAnalytics: granted);
}
```

Bu Faz 6 kapsamında eklenecek. Faz 5 playtest'te kapalı dağıtım (≤10 tester)
olduğu için **Seviye 1** yeterlidir.
