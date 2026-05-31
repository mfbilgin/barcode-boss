# Barcode Boss — Game Design Document

> **Versiyon:** 1.0.3 (Approved Pre-production — scene props refined)
> **Engine:** Flutter 3.x + Flame 1.x
> **Platform:** Android (sonraki sürümlerde iOS)
> **Tek oyuncu / Offline-first**
> **Onay tarihi:** 26 Mayıs 2026 — Tasarım donduruldu, geliştirme başlayabilir.

**v1.0.3 değişiklikler (scene props refined):** İlk Mini Market render denemelerinden sonra §7.9 dürüst kullanım listesine indirgendi. **Aktif tutulan 4 prop:** `character-employee`, `shopping-cart`, `shopping-basket`, `shelf-boxes`. **Düşürülenler:** `cash-register` (form mobilde okunmuyor), `display-bread`/`display-fruit` (oyun-içi ürünlerle görsel çakışma — soyut sembol vs somut ürün UX kuralı ihlali), `freezer-standing` (form bulanık, post-launch'a reserved). **Yeni karar:** Sipariş sekmesi kategori başlıkları için Mini Market display'leri yerine **Unicode emoji** kullanılır (🍞 Gıda Temel, 🥤 İçecek, 🍫 Atıştırmalık, ⭐ Premium, 🍎 Manav) — mobile native, ölçeklenir, UX-temiz. `products.json` katalog şemasına `emoji` field eklendi.

**v1.0.2 değişiklikler (scene props integration):** Mini Market pack'inin kullanım kapsamı tanımlandı. Yeni alt-bölüm **§7.9 Mağaza Ortamı (Mini Market Pack — Sahne Dekoru)** eklendi: 9 sahne asset'inin oyun-içi kullanım haritası (kasa ekranı, hazırlık ekranı, vardiya sonu rapor, ana menü). Render pipeline'a ikinci manifest dosyası eklendi (`render_manifest_props.json`), çıktı dizini `assets/images/props/`. Faz planlaması: Faz 1 vertical slice için `character-employee` + `cash-register`, Faz 2 için hazırlık ekranı UI prop'ları, Faz 3 için ana menü background. `display-fruit.obj` mevcut "manav" kategorisiyle tematik %100 uyumlu — v1.0.1 kategori değişikliğini görsel olarak destekliyor.

**v1.0.1 değişiklikler (asset reality patch):** Kenney Food Kit + Mini Market pack'leri indirildikten sonra mevcut asset envanteriyle eşleştirme yapıldı. Üç değişiklik: (1) 5. kategori **"hijyen" → "manav"** olarak değiştirildi (Mini Market hijyen ürünleri içermiyor; Food Kit'in zengin meyve/sebze envanteri tematiğe daha uygun). (2) Bazı ürün id'leri ve isimleri yeniden eşleştirildi: `tea_box`/`coffee_jar` kaldırıldı (asset yok), yerlerine `soda_bottle` (Gazoz) ve `croissant` (Kruvasan) eklendi. Diş macunu/sabun/tuvalet kağıdı yerine elma/domates/muz. (3) §23.2 ürün tablosuna **asset (Food Kit OBJ)** kolonu eklendi — her ürünün gerçek Kenney dosyasına direkt bağlantı. Tema "fresh market" olarak netleşti.

**v1.0 değişiklikler:** Tüm açık tasarım kararları kapatıldı, balance tabloları tamamlandı, branding finalized. Geliştirmeye geçiş onayı verildi. Bu versiyondan itibaren GDD değişiklikleri yalnızca implementation sırasında ortaya çıkan gerçek ihtiyaçlar veya playtest sonucu gelir — spekülatif tasarım değişikliği yok.

**v0.9 değişiklikler:** Son 6 eksik balance tablosu eklendi. Yeni bölüm **§23 Balance Parametreleri ve İçerik Tabloları**: mağaza seviyesi (5 seviye × XP eşiği × açılan ürün × upgrade), 15 MVP ürünü tam tablosu (id, kuruş cinsi fiyatlar, elastikiyet, unlock level), XP kazanma kuralları (eylem başına XP + örnek vardiya hesabı), 8 upgrade'in fiyatı ve etkisi, auto-reorder default davranışı, Faz 1 vertical slice ilk 3 ürünün gerekçesi. §22'de Faz 1 ürün referansı §23.6'ya bağlandı.

**v0.8 değişiklikler:** Branding kararları kapatıldı. Oyun adı **"Barcode Boss"** olarak belirlendi. Oyun-içi para birimi **"B-Coin"** olarak yeniden adlandırıldı (Barcode Boss'un B'sine tematik gönderme). VIP müşteri kesin olarak post-launch'a sabitlendi.

**v0.7 değişiklikler:** İkinci review döngüsü sonrası onaylanan kararlar uygulandı. **Büyük değişiklikler:** (1) Vardiya yapısı yeniden tasarlandı — Good Pizza Great Pizza modeli: 5 dakikalık wall-clock vardiya, sıralı müşteri kuyruğu, oyuncu hızı = işlenen müşteri sayısı; monitör vardiya içinde değil, sadece vardiya öncesi (hazırlık) ve sonrası (rapor) erişilir. (2) Tarama mekaniği drag-to-scan'den **swipe-through one-at-a-time**'a geçti. (3) Para üstü 3-option multiple choice; tam para veren müşteri skip eder. (4) Kart ödemesi MVP'ye dahil edildi (default %5 müşteri, max %20 upgrade). (5) Para birimi 2 ondalıklı yapıya geçti, denominationlar TL modeli (kuruş madeni + B-Coin kağıt). (6) Tüm faz sürelerinin yol haritasından kaldırılması. (7) Sabır formülü sepet büyüklüğüne göre baseline + zamana bağlı decay. (8) VIP tetikleyici tanımlandı (önceki vardiya memnuniyeti >0.8 ise spawn şansı boost).

**v0.6 değişiklikler:** Eleştirel review sonrası kapatılan boşluklar ve eklenen altyapı bölümleri (§13–§21 — müşteri davranışı, soft-lock, telemetri, hata yönetimi, performans, erişilebilirlik, tipografi, build/QA, yasal uyumluluk).

**v0.5 değişiklikler:** Asset stratejisi düzeltildi — Kenney'in Food Kit / Mini Market / Generic Items pack'leri 3D model içerir, doğrudan 2D'de kullanılamaz. Plan: Blender + Python batch script ile pre-rendered isometric PNG'ler.

**v0.4 değişiklikler:** Tedarik zinciri tamamen oyuncuya bağlandı — depo otomatik dolmuyor, stok yokken ürün satılamıyor ve oyuncu monitörden sipariş vermek zorunda · Fiyat elastikiyeti mekaniği netleştirildi (esnek/inelastik ürün tipleri) · Ürün modeline `elasticity` alanı eklendi.

**v0.3 değişiklikler:** Para birimi oyun-içi "B-Coin" sembolüne çevrildi (lokal para formatı kaldırıldı) · Tüm art ve müzik ücretsiz CC0 kaynaklardan (Kenney + Pixabay) · Reklam ve IAP entegrasyonu MVP'den çıkıp en sona alındı · Soft launch sadece TR, EN ekleme post-launch'a kaydırıldı · Yol haritası buna göre yeniden düzenlendi.

---

## 1. Genel Bakış

### 1.1 Yüksek Konsept
Oyuncu, küçük bir mahalle marketinin kasiyeridir. Hareket yoktur — kamera sabit, kasanın arkasındaki birinci-şahıs benzeri bir görüş açısıyla oynanır. Oyuncu, kasaya gelen müşterilerin ürünlerini tarar, ödeme alır ve karşısındaki monitörden mağazanın envanter/fiyat/sipariş yönetimini yapar. Amaç vardiyaları kâr ederek tamamlamak, marketi büyütmek ve daha hızlı/karmaşık ekipmanlar açmaktır.

### 1.2 Tür ve Ton
- **Tür:** Casual / Management / Time-pressure simulator
- **Ton:** Sıcak, hafif komik, "cozy capitalism" — stresli değil, akıcı.
- **Oturum uzunluğu — Vardiya yapısı (Good Pizza Great Pizza modeli):** Tek vardiya **5 dakika wall-clock süre** (mağaza seviyesi yükseldikçe 5 → 6 → 7 dk). Müşteriler **sıralı kuyrukta** gelir: bir müşteri ödemeyi bitirip ayrıldıkça hemen sonraki gelir. Aynı anda kasada sadece 1 aktif müşteri olur; kuyrukta 1–2 müşteri bekliyor olarak görünür (arka plan, hafif soluk). **Oyuncunun hızı = işlediği müşteri sayısı**: hızlı oyuncu 5 dakikada 12–15 müşteri, ortalama 8–10, yavaş 5–7 müşteri tamamlar. Bu, beceri tabanlı progression sağlar — daha hızlı tarama + daha doğru para üstü = daha çok B-Coin.
- **Vardiya akışı (üç aşama):**
  1. **Hazırlık (monitör ekranı, vardiya öncesi):** sipariş ver, fiyat ayarla, geçen vardiya raporunu incele. Süresiz — oyuncu hazır olduğunda başlatır.
  2. **Vardiya (kasa ekranı, 5 dk geri sayım):** müşteriler sırayla gelir, taramalar ve ödemeler yapılır. Monitöre **geçilmez** — kepenk açık, kasa başında.
  3. **Rapor (monitör ekranı, vardiya sonrası):** "Kepenk kapandı" → vardiya özeti (kazanılan B-Coin, işlenen müşteri, memnuniyet, kaçırılan talep). Tek tap ile hazırlık aşamasına dönülür.

### 1.3 Referans Oyunlar
- *Supermarket Simulator* (PC) — temel ilham, kasiyer döngüsü
- *Cashier 3D* (mobil) — tarama mekaniği
- *Stardew Valley* gün sonu özet ekranı — progression hissi
- *Cooking Madness / Diner Dash* — müşteri sabır metresi, ritm

### 1.4 USP — Neden bu oyun?
Mobil cashier sim'lerin çoğu yalnızca tarama mekaniğine odaklanır; biz tarama + arkasındaki **işletme yönetimi** katmanını birleştiriyoruz. Vardiya öncesi ve sonrası açılan **hazırlık ekranı** (stok/sipariş/fiyat/rapor) oyuncunun stratejik kararlar verebileceği ikincil katmandır — kasada hız + masada strateji.

---

## 2. Core Loop

### 2.1 Mikro Loop (saniyeler — bir müşteri)
```
Müşteri kuyruktan çıkıp kasaya gelir → Sepet açılır →
Ürünler tek tek bantta sağdan sola kayar →
Oyuncu her ürün üzerinde swipe yapar → "BEEP!" → poşetlenir →
Tüm ürünler tarandığında TOTAL ekranda → 
Müşteri öder (nakit/kart) → 
  Nakit: müşteri tam para verdiyse onayla; bozuk para verdiyse 3-option para üstü →
  Kart: tek tap "Onayla" →
Müşteri ayrılır → KUYRUKTAKİ SONRAKİ müşteri kasaya geçer
```

### 2.2 Makro Loop (vardiya — 5 dakika)
```
Hazırlık ekranı (monitör, süresiz)
  → Stok kontrol / sipariş ver / fiyat ayarla / önceki raporu incele
  → "Vardiyayı başlat" butonu
Vardiya (5 dk geri sayım, kasa ekranı)
  → Müşteriler sırayla gelir, oyuncu işler
  → Süre bitene kadar mümkün olduğunca çok müşteri tamamla
Vardiya sonu (rapor ekranı)
  → Kazanılan B-Coin, işlenen müşteri, memnuniyet, kaçırılan talep
  → XP / level güncellemesi
  → Tek tap → Hazırlık ekranına dön (sonraki vardiya döngüsü)
```

### 2.3 Meta Loop (günler/haftalar)
Mağaza seviyesi yükseldikçe yeni ürün kategorileri (içecek → meyve-sebze → kasap reyonu → şarküteri), daha hızlı tarayıcılar, kart okuyucu kapasitesi artırma (kart-müşteri oranı %5 → %20), ikinci kasa, otomatik raflama hızı upgrade'leri açılır. Vardiya süresi 5 → 6 → 7 dakikaya kadar uzayabilir.

---

## 3. Oyun Sistemleri

### 3.1 Müşteri Sistemi
Müşteriler **vardiya boyunca sıralı kuyrukta** gelir. Aynı anda kasada sadece 1 aktif müşteri vardır; arka planda kuyrukta 1–2 müşteri silüet halinde bekliyor görünür (gameplay etkisi yok, görsel anchor). Bir müşteri ayrıldıkça hemen yenisi kasaya geçer.

**Müşteri özellikleri:**
- **Sepet içeriği:** 2–12 ürün (mağaza seviyesine göre). Sepet **spawn anında** belirlenir; bu noktada her ürün için fiyat-elastikiyet kontrolü (§3.5) yapılır ve yüksek fiyatlı/elastik ürünler sepete eklenmez. Yani **kasada müşteri vazgeçmez** — sepete giren ürün satılır. Vazgeçilen satışlar "Rapor" sekmesinde "kaçırılan talep" olarak görünür.
- **Sabır metresi:** Müşteri kasaya geldiği an dolu başlar. Sabır süresi sepet büyüklüğüne göre belirlenir (büyük sepet = daha fazla tolerans):
  ```
  maxPatience = basePatience(type) + basketSize × 4
  
  basePatience by type:
    - normal:  40s   → 5 ürünlü sepet için 60s, 12 ürünlü için 88s
    - aceleci: 15s   → 5 ürünlü için 35s, 12 ürünlü için 63s
    - yaşlı:   60s   → 5 ürünlü için 80s, 12 ürünlü için 108s
  
  patience(t) = maxPatience - t × decayRate × difficultyMultiplier
  difficultyMultiplier = 1.0 + (storeLevel - 1) × 0.08
  ```
  Sabır sıfıra inerse müşteri çıkar → B-Coin kaybı (sepetteki ürünlerin satış değeri × 0.5) + memnuniyet -1.
- **Ödeme tipi (MVP'de iki yöntem):**
  - **Nakit** (default %95 oran, kart okuyucu upgrade'lerine göre azalır). Çoğu müşteri (~%70) tam parayla, ~%30'u büyük kupürle öder → para üstü 3-option mekaniği.
  - **Kart** (default %5 müşteri, mağaza upgrade ile max %20'ye çıkar). Tek tap "Onayla". Para üstü yok.
- **Tip:** Normal / Yaşlı (yavaş, sabır yüksek) / Acelesi olan (hızlı, sabır düşük). MVP'de bu 3 tip.
- **VIP (post-launch):** Spawn şansı default %5; önceki vardiya memnuniyeti >0.8 ise +%3 boost (max %8). Ödeme sonrası %25–60 ek B-Coin bahşiş. Görsel ipucu: müşteri portresinde "✨" overlay.

**Spawn algoritması (sıralı kuyruk için sadeleşti):** Müşteri akışı önceden hesaplanan bir kuyruktan gelir, aralık dinamik (önceki müşteri ayrıldığında + 0.5–1.5 sn gecikme). Vardiya 5 dk dolduğunda spawn durur, mevcut müşteri tamamlanırsa rapor ekranına geçilir. Algoritma detayı bkz. §13.

**Bahşiş (combo bonusu):** 5 ürün üst üste hızlı swipe edilirse (her swipe arası <1.5 sn) o anki aktif müşteri ödeme yaparken +5% sabit B-Coin bahşiş bırakır. Combo HUD'da küçük zincir ikonuyla görünür; aralık aşılırsa sıfırlanır. Combo yalnızca anlık müşterinin ödemesinde uygulanır — sonraki müşteriye taşınmaz.

Müşteri tipleri ilerlemeyi çeşitlendirir, mekanik aynı kalır.

### 3.2 Ürün Sistemi
Her ürün şu alanlara sahip:
- `id`, `name_i18n` (lokalizasyon key), `category`, `barcode` (görsel barkod ID'si)
- `costPrice` (toptancı alış — B-Coin cinsinden)
- `defaultSellPrice` (sistemin önerdiği satış fiyatı, baseline)
- `currentSellPrice` (oyuncunun ayarladığı fiyat — başlangıçta `defaultSellPrice` ile eşit)
- `elasticity` (fiyat duyarlılığı: 0 = inelastik, 1 = normal, 2 = elastik)
- `weight` (terazide tartılan ürünler için — ileride)
- `iconAsset`, `unlockLevel`

Başlangıçta ~15 ürün, mağaza seviyesi yükseldikçe katalog 60+ ürüne ulaşır.

**Elastikiyet kategorileri (örnek):**
- **İnelastik (0):** Ekmek, süt, su, tuvalet kâğıdı — temel ihtiyaç, fiyat yüksek olsa da alınır. Marjı yüksek tutmak için ideal.
- **Normal (1):** Çoğu ürün — peynir, deterjan, çikolata.
- **Elastik (2):** Lüks/keyfe bağlı ürünler — premium çikolata, dondurma, gazoz. Fiyat artınca satış hızla düşer.

Bu, sonraki bölümlerdeki fiyat ayarı mekaniğini stratejik kılan asıl değişkendir.

### 3.3 Tarama Mekaniği — Swipe-Through (one-at-a-time)
Müşteri kasaya gelip sepeti açıldığında ürünler **tek tek** kasa bandında sağdan sola kayarak gelir. Her ürün tarayıcı zonuna ulaştığında durur ve oyuncudan eylem bekler. Oyuncu **ürünün üzerinde yatay swipe** (sağdan sola, parmak sürekli temasta) yapar:
- Swipe başarılıysa: Laser çizgisi ürünün üstünden geçer (~200ms), "BEEP!" sesi + kısa haptic, barkod flash, fiyat POS ekranında belirir, TOTAL güncellenir, ürün poşetleme alanına kayar, **bantta hemen sonraki ürün** belirir.
- Swipe yetersiz hızda veya yanlış yöndeyse: "buzz" sesi, ürün yerinde kalır, tekrar dener.

**Neden swipe-through (drag-to-scan değil):**
- Drag mesafesi kısa (sadece tarayıcı üzeri yatay), başparmak uzun mesafe gitmez → mobil ergonomi
- Sıralı akış doğal (Good Pizza Great Pizza modeli) — sepet "yığın" gibi karmaşık değil, "sıra" gibi temiz
- Combo / hız oyunu doğal hisseder (parmak hızı = işlem hızı)
- Tactile: parmak ürüne dokunup geçirir, fizyolojik "tarama" hissi verir

**Tasarım detayları:**
- Swipe yatay yönü tek (sağdan sola); ters yön no-op (yanlışlık önleme)
- Swipe hızı toleranslı: 200–2000 px/sn arası kabul edilir
- **Combo:** Üst üste 5 ürün <1.5 sn aralıklarla başarılı taranırsa o müşterinin ödemesinde +5% sabit B-Coin bahşiş. Combo HUD'da küçük zincir ikonu, koparsa sıfır.
- **Kasıtlı bozulmalar (variety için, post-launch):** ürünün %5'i ilk swipe'da "buzz", ikinci swipe'da geçer (buruşmuş barkod hissi)
- Ağır ürünler (geç oyunda) iki parmaklı swipe gerektirebilir

**Erişilebilirlik — Tap modu:** Ayarlar'dan "Tap modu" aktive edilebilir. Bu modda swipe yerine ürün üzerinde tek tap yeterli olur — aynı sonuç. Motor zorluğu yaşayan oyuncular için.

**Mimari not:** `lib/game/handlers/scan_handler.dart` her iki modu da destekleyecek soyutlamayla başlar (swipe + tap iki ayrı strategy). Bu, Faz 1 playtest sonucu mod kararı netleşene dek esneklik sağlar.

### 3.4 Ödeme Mekaniği
Tüm ürünler tarandığında TOTAL ekranda kilitlenir. Müşterinin tipine göre ödeme akışı belirir:

**Kart ödemesi (default %5 müşteri, max %20 upgrade ile):**
- Müşteri kart cihazını uzatır, ekranda "Kart Cihazı" widget'i belirir
- Tek tap "Onayla" → POS terminalde "onaylandı" animasyonu (~500ms) + onay sesi
- Müşteri ayrılır, sıradaki gelir
- Para üstü yok, hızlı

**Nakit ödemesi (default %95 müşteri):**
- Müşteri kupürleri uzatır. İki olasılık:
  - **Tam para (~%70):** Müşteri TOTAL'e tam denk kupür kombinasyonu uzatır. Ekranda "Tam para: 🪙 47,50" görünür, tek tap "Tamam" → bitti.
  - **Bozuk para (~%30):** Müşteri TOTAL'den büyük kupür uzatır (örn: 47,50 borç → 100 B-Coin verir). Ekranda **3-option multiple choice** belirir:
    ```
    Para üstü: 🪙 52,50
    
    [ 🪙 50 + 🪙 2 + 🪙 0,50 ]   ← doğru
    [ 🪙 50 + 🪙 2,50 ]           ← yanlış (yakın)
    [ 🪙 50 + 🪙 5 ]              ← yanlış (yakın)
    ```
  - Oyuncu doğruyu tap'lerse: onay sesi + memnuniyet korunur. Yanlış tap'lerse: müşteri uyarır, memnuniyet -1, B-Coin'den fark kesilir.

**Neden 3-option (drag-stack değil):** Mobil ergonomi için minimal tap, hız önemli, oyuncu kafa hesap yapar değil seçim yapar. Tactile, hızlı, oyun temposunu koparmaz. 3 seçenek arasında 1 doğru + 2 yakın yanlış kombinasyon var; rastgele seçimi engeller (gerçek hesap yapılmazsa %33 başarı, anlamlı olmaz). Yanlış seçenekler, doğruya yakın matematiksel bozukluklar (örn: 0,50 yerine 5,00 koyma; küçük kupürü atlama).

**Sabır bar:** Kart hızlı, nakit-tam-para orta, bozuk-para uzun → sabır bar hangi yöntemde olduğuna göre baskı verir. Hızlı tarama + doğru para üstü = sabır neredeyse dolu kalır.

### 3.5 Envanter ve Sipariş Sistemi (Monitör) — Oyuncunun Ana Stratejik Katmanı
Monitör ekranı **vardiya öncesi ve sonrası** ayrı bir ekrandır (kasa ekranından farklı). Vardiya İÇİNDE monitöre geçilemez — kepenk açık, oyuncu kasa başında. Bu yapı sayesinde:
- Oyuncu vardiya temposunu bölmeden tarama odağında kalır
- İşletmecilik kararları sakin/odaklı bir anda alınır (rapor okurken, sipariş verirken zaman baskısı yok)
- Mobil için akış sadeleşir (mod değişimi yerine ekran geçişi)

Hazırlık ekranında sekmeler:

#### Stok sekmesi
- Tüm ürünlerin mevcut adetleri (rafta + depoda)
- "Azalıyor" / "Tükendi" / "Yeterli" durum etiketleri
- Hangi ürünün hangi vardiyada bitebileceğine dair tahmin (son 3 vardiyanın satış hızına göre)

#### Sipariş sekmesi — Tedarik zinciri OYUNCUYA bağlı
Stok ne otomatik dolar ne de sihirle yenilenir. Bir ürünün deposu tükenirse o ürün satılmaz; oyuncu **monitörden toptancıya manuel sipariş vermek zorundadır.**
- Her ürünün toptancı fiyatı (`costPrice`) ve sipariş miktarı seçilir
- Sipariş anında **B-Coin düşülür**, mal **bir sonraki vardiyada** depoya iner
- Yanlış planlama → boş raf → kaçırılmış satış. Doğru planlama → istikrarlı kâr.
- "Hızlı teslimat" (post-launch, rewarded ad) anlık teslim sağlar

**Auto-reorder threshold (MVP — sıkıcılığı önlemek için):**
Her ürünün satırında "otomatik sipariş eşiği" alanı vardır. Oyuncu bir değer girer (örn: 10). Vardiya bittikten sonra eğer depo+raf toplam stok eşiğin altına düştüyse sistem **öneri** olarak sipariş satırlarını dolu hazırlar — oyuncu tek tap'le "Tümünü onayla" der. Onay zorunlu (B-Coin düşümü açık görünür); tamamen otomatik değil. Bu, "her ürünü tek tek seç" yorgunluğunu kaldırır ama oyuncunun stratejik kontrolünü korur. Default davranış (yeni ürün eklendiğinde threshold = 0, toggle kapalı) için bkz. §23.5.

Bu zorunlu döngü oyuncuya gerçek bir işletmeci sorumluluğu verir: "Hangi ürünü ne kadar sipariş edeyim, kasada B-Coin'im yeterli mi, hangi ürünler bu hafta hızlı satıyor?"

#### Fiyat sekmesi — Fiyat Elastikiyeti Mekaniği
Oyuncu her ürünün satış fiyatını bireysel olarak ayarlar. `currentSellPrice` değiştikçe müşterinin o ürünü sepete alma olasılığı değişir.

**Önemli:** Bu hesap **müşteri spawn anında** yapılır, kasada değil. Müşteri spawn olduğunda mağazadaki her uygun ürün için olasılık hesaplanır, başarılı kontroller sepete eklenir, sepet büyüklüğü ürün adetine göre belirir. Kasiyer önüne gelen sepet "alınmış" sepettir. Bu, gameplay'i koparmadan elastikiyetin görünmesini sağlar (rapor sekmesinde "kaçırılan talep" olarak izlenir).

**Satın alma olasılığı formülü** (iki yönlü):
```
priceRatio = currentSellPrice / defaultSellPrice

# Fiyat artarsa satış düşer
if priceRatio >= 1.0:
    purchaseChance = clamp(1 - (priceRatio - 1) × elasticity × 0.6, 0.05, 1.0)

# Fiyat düşerse: inelastik ürünlerde değişmez (zaten %100), 
# elastik ürünlerde basket boost (aynı müşteri ekstra adet ekler)
else:
    purchaseChance = 1.0
    basketBoost = (1 - priceRatio) × elasticity × 0.8   # 0..0.8
    # → spawn anında elastik ürüne ekstra %X olasılıkla "1 adet daha" eklenir
```

Pratik örnekler:
| Ürün | Elastikiyet | Fiyat 2x | Fiyat 0.7x | Sonuç |
|------|-------------|----------|------------|-------|
| Ekmek | 0 (inelastik) | %100 satar (marj 2x) | Marj kaybı, hacim aynı | İnelastik = yüksek fiyat stratejisi |
| Peynir | 1 (normal) | %40 satar | %100 satar, +%24 basket boost | Dengeleme |
| Premium çikolata | 2 (elastik) | %5 satar | %100 satar, +%48 basket boost | İndirim eventi için ideal |

Stratejik dinamik: inelastik ürünleri yüksek fiyatla marja oyna, elastik ürünleri ucuzlatıp hacme oyna. Her iki yön de geçerli.

**UI:** Her ürün satırında bir slider (0.5x – 3.0x arası `defaultSellPrice` etrafında), anlık olarak "tahmini satış olasılığı: %X" ve "vardiya başına tahmini B-Coin: Y" hesaplanıp gösterilir. Oyuncu deneyerek sweet spot'u bulur.

**İndirim eventi (Faz 3+):** Oyuncu bir ürüne 1 vardiya süreyle "indirim" etiketleyebilir (otomatik 0.7x fiyat + basket boost) → marketing efekt; o vardiyadaki tüm müşteri spawn'ında o ürün için boost uygulanır.

#### Rapor sekmesi
Son vardiya kâr/zarar, en çok satan ürünler, kaçırılan satışlar (stok bitmesinden dolayı), hangi ürünün fiyatı çok yüksek olduğu için sepetten çıkarıldığı uyarısı.

### 3.6 Otomatik Raflama (Depo → Raf)
**Önemli ayrım:** Otomatik raflama yalnızca **depodan rafa** geçişi otomatize eder; depoya mal koymak oyuncunun sipariş kararına bağlıdır (bkz. 3.5 Sipariş sekmesi).

Akış:
```
[Toptancı] → (Oyuncu sipariş verir, B-Coin düşer)
        → [Depo] → (Otomatik, raflama hızıyla yavaşça)
        → [Raf] → (Müşteri sepete alır)
```

Raflama görseli: arka planda animasyonlu çalışan NPC, ürünleri raflara taşır. Bu hız upgrade'lenebilir (Faz 2+) ya da işçi sayısı arttırılarak hızlandırılabilir (geç oyun).

**Stok ↔ Satış mantığı:**
- Raf boşsa → müşteri o ürünü sepete almaz (sanki yokmuş gibi davranır)
- Raf doluysa ama fiyat çok yüksekse → müşteri ürünü sepete almaya hazırlanır, fiyatı görür ve elastikiyet formülüne göre vazgeçebilir
- Depo boşsa → raflama duraksar, raflar tükenince ürün satışı 0'a düşer → oyuncu sipariş vermek zorunda

Bu zincir oyunun gerilim/ödül döngüsünün temelidir: oyuncu sürekli "neyi sipariş edeyim, neyi fiyatlandırayım, hangisini stoklu tutayım" denklemini çözer.

### 3.7 Para Birimi — Oyun İçi B-Coin (2 ondalıklı, TL modeli)
Tüm fiyatlar **B-Coin** adlı tek bir oyun içi para birimiyle ifade edilir. "B-Coin" oyun içi soyut bir birim — gerçek bir ülke parası değil — ama yapısal olarak Türk Lirası modelini takip eder: 2 ondalık (kuruş alt birimi), tanıdık denomination'lar.

**Denomination yapısı:**
- **Madeni para (yüksek detaylı sprite, Kenney Game Icons + custom overlay):**
  - 5 kuruş (0,05 B-Coin)
  - 10 kuruş (0,10 B-Coin)
  - 25 kuruş (0,25 B-Coin)
  - 50 kuruş (0,50 B-Coin)
  - 1 B-Coin (1,00 B-Coin) — büyük madeni para
- **Kağıt para (renk-kodlu, Kenney UI Pack + custom overlay):**
  - 2 B-Coin (mor)
  - 5 B-Coin (turuncu)
  - 10 B-Coin (mavi)
  - 20 B-Coin (yeşil)
  - 50 B-Coin (kahverengi)
  - 100 B-Coin (kırmızı)
  - 200 B-Coin (lacivert)

**Sembol ve Marka:**
- **Faz 0–3 (geçici):** 🪙 emoji — tüm UI'da sayının yanında.
- **Faz 3+ (final asset):** Custom **"B" harfli madeni para** sprite tasarlanacak (Barcode Boss markasıyla tutarlı: sarı/altın gradient zemin, üzerinde stilize barkod çizgileriyle "B" harfi). Bu asset `assets/images/ui/bcoin_symbol.png` yolunda 64×64 ve 128×128 (HiDPI) olarak hazırlanır. Yer tutucu olarak 🪙 ile başlanır, son polish'te değiştirilir.
- **Yazılı gösterim:** Bazı bağlamlarda (rapor, IAP ekranı, credits) sembol yerine "B-Coin" kelime yazılır. Örn: "Kazandın: 47,50 B-Coin". HUD gibi kompakt yerlerde sembol + sayı: "🪙 47,50".

**Sayı formatı (Türkçe locale için, default):**
- Ondalık ayraç: virgül (`,`)
- Binlik ayraç: nokta (`.`)
- 2 ondalık her zaman görünür: `47,50` ; `1.250,00` ; `0,05`
- Sembol konumu: sembol önce, sayı sonra. Örnekler:
  - `🪙 47,50`
  - `🪙 1.250,00`
  - `🪙 0,05`
- İngilizce locale (post-launch): ondalık nokta, binlik virgül → `🪙 1,250.00`
- Büyük rakamlar için kısaltma (≥100.000): `🪙 125,3K` ; `🪙 3,2M` (bkz. §9.5)

**Yuvarlama:** Tüm B-Coin hesapları integer cinsinden tutulur — backing data tipi `int` (kuruş cinsi). Yani 47,50 B-Coin = `4750` (kuruş). UI'da gösterilirken 100'e bölünür ve formatlanır. Bu, floating-point hatalarını engeller (özellikle elastikiyet hesabında kritik).

**Fiyat balance örnekleri:**
- Ekmek: `defaultSellPrice = 2,50 B-Coin` (250 kuruş), `costPrice = 1,25 B-Coin`
- Süt: `defaultSellPrice = 8,00 B-Coin`, `costPrice = 5,50 B-Coin`
- Premium çikolata: `defaultSellPrice = 25,00 B-Coin`, `costPrice = 12,00 B-Coin`

**Ekonomi:**
- **Gelir:** ürün satışı + (post-launch) VIP bahşişi + (post-launch) rewarded ad bonusu
- **Gider:** toptancı siparişleri, işçi maaşı (geç oyun), upgrade alımları, kart-okuyucu kapasitesi artırma
- **Başlangıç sermayesi:** 1.000,00 B-Coin (oyuna giriş)
- **Hedef:** her vardiya pozitif kâr (5-50 B-Coin tipik); haftalık olarak büyük upgrade alabilecek birikim (100-500 B-Coin)

### 3.8 İlerleme (Progression)
İki paralel ilerleme ekseni:
- **Mağaza Seviyesi:** XP toplanarak artar. Her seviye yeni kategori/upgrade açar. **Seviye eşikleri ve XP kazanma kuralları için bkz. §23.1 ve §23.3.**
- **Ekipman Ağacı:** B-Coin ile satın alınır. Tarayıcı v2 (swipe tolerance), kart kapasitesi upgrade'leri, otomatik raflama v2, ikinci kasa (post-launch), elektronik fiyat etiketi (post-launch). **Tam upgrade listesi, fiyat ve etki tablosu için bkz. §23.4.**

---

## 4. Tutorial Tasarımı — İnteraktif Overlay

Tutorial **drip-feed** stratejisi izler: tek bir vardiyada her şeyi öğretmek yerine, ilk 3 vardiya boyunca yeni kavramlar tek tek tanıtılır. Ekran kısmen kararır, hedef bölge parlar, animasyonlu el ikonu eylemi gösterir.

### 4.1 Tutorial Akışı — 3 Vardiya Boyunca

**Vardiya 1 — Sadece Tarama ve Nakit (2 müşteri, 4 ürün toplam):**
1. **Karşılama:** "İlk gününe hoş geldin!" (üst banner, 2sn)
2. **İlk tarama:** Ekran kararır, ilk ürün tarayıcı üzerinde durur, animasyonlu el ikonu sağdan sola swipe hareketini gösterir, "Ürünün üstünde sola doğru kaydır"
3. **Tüm sepeti taramak:** Sonraki ürünler sırayla bantta gelir, oyuncu kendisi swipe eder (ipucu üstte küçük metin)
4. **Nakit ödeme + tam para:** Müşteri tam parayı uzatır, "Tamam" butonu parlar → tek tap
5. **İkinci müşteri — bozuk para senaryosu:** Müşteri büyük kupür uzatır, 3-option para üstü ekrana gelir, doğru seçenek 2sn parlar, oyuncu tap'ler
6. **Vardiya sonu:** "Kepenk kapandı" → Tebrik ekranı, kazanılan B-Coin + XP pop-up

**Vardiya 2 — Monitör Tanıtımı (3 müşteri):**
1. Vardiyaya başlamadan önce **hazırlık ekranı** ilk kez açılır, "Stok" sekmesi parlar — bir ürünün stoku azaldı, "Azalıyor" etiketi vurgulanır
2. "Sipariş" sekmesi tanıtılır, o ürün için bir sipariş örneği animasyonlu işaretlenir → onay
3. "Vardiyayı başlat" butonu parlar
4. Vardiya normal akar (3 müşteri), sonunda rapor ekranı

**Vardiya 3 — Fiyat, Auto-reorder ve Kart Ödemesi (4 müşteri):**
1. Hazırlık ekranında "Fiyat" sekmesi parlar — slider örneği, oyuncu bir ürünün fiyatını oynamayı dener
2. "Auto-reorder threshold" alanı tanıtılır → eşik gir, onay
3. Vardiyada **kart ödeme müşterisi** garantili olarak gelir, "Kart Cihazı" widget'i ve tek-tap onay tanıtılır
4. Vardiya sonu raporu — "Kaçırılan talep" satırı vurgulanır (elastikiyet bilgisi)

Tutorial state'i `Hive` save'inde adım adım yazılır (`tutorial_step_completed: 1..14`). Herhangi bir adım yarıda kalsa kaldığı yerden devam eder. Ayarlar'dan "Tutorial'ı tekrar göster" seçeneği vardır.

### 4.2 İleri Tutorial (post-tutorial drip-feed)
Yeni sistemler (ikinci kasa, bahşiş, indirim eventi) ilk açıldıklarında **tek-adımlık** overlay ipucu gösterir — ana tutorial 3 vardiyada biter ama yeni mekanik açıldıkça mini-tutorial'lar tetiklenir.

---

## 5. Monetizasyon — Post-Launch

> ⚠️ **Önemli:** Reklam ve IAP entegrasyonu, oyun mekanikleri ve içeriği tamamlandıktan **sonra** yapılır. MVP'de YOKTUR. Bu bölüm planlama amaçlıdır.

Hibrit model: ücretsiz indir + rewarded ad + IAP. Banner reklam yok.

### 5.1 Reklamlar (AdMob — Faz 6'da entegre)
- **Rewarded video:** vardiya sonunda "kazancı 2x yap" seçeneği, hızlı sipariş teslimi, sabır boost
- **Interstitial:** Vardiya sonu raporundan ana menüye dönüşte. Her 3 vardiyada bir, agresif değil
- **Banner:** YOK

### 5.2 IAP'lar (Faz 6'da entegre)
- **Remove Ads:** ~$2.99 — Tüm interstitial reklamları kaldırır, rewarded opsiyonel kalır
- **Gem paketleri:** Premium currency. 100/550/1200/3000 paketleri. Gem kullanımları: hızlı teslimat (sipariş anlık iner), vardiya boost (XP/B-Coin × 1.5 bir vardiya boyunca), kozmetik açma.
- **Starter Pack:** Yeni oyunculara 48 saat içinde — Gem + remove-ads + 2 kozmetik
- **Cosmetic bundles:** Kamera first-person olduğundan **görünür** öğeler kozmetikleştirilir: monitör wallpaper'ı, kasa tezgâhı dekorları (kupa, küçük figür, takvim), POS terminali skin'i, ürün ikonu skin paketleri (örn. "noel teması", "yaz teması"), tarayıcı laser rengi. Gameplay etkisi YOK.

### 5.3 İki para birimi sistemi
- **B-Coin (soft):** Oyun içinde kazanılır, ücretsiz oyuncu için ana ekonomi. Pay-to-win yok.
- **Gem (hard, post-launch):** Sadece IAP ile alınır. Hızlandırıcı ve kozmetik için. Ücretsiz oyuncunun erişebileceği hiçbir içeriği kilitlemez.

### 5.4 Hedef metrikler (soft launch'ta ölçülecek)
ARPDAU: $0.05–0.15 · Remove-ads conversion: %3–5 · D1 retention: %35+ · D7 retention: %12+

---

## 6. Ekranlar ve UI Akışı

### 6.1 Ekran Listesi
1. **Splash / Ana Menü** — Yeni oyun, Devam et, Ayarlar
2. **Hazırlık Ekranı (Monitör — vardiya öncesi)** — Stok / Sipariş / Fiyat / Önceki Rapor sekmeleri + "Vardiyayı başlat" butonu
3. **Kasa Ekranı (Game — vardiya esnası)** — 5 dk geri sayım, sıralı müşteri akışı, swipe-through tarama
4. **Vardiya Sonu Raporu (Monitör — vardiya sonrası)** — Kazanılan B-Coin, işlenen müşteri, memnuniyet, kaçırılan talep
5. **Mağaza / Upgrade Menüsü** — Ekipman alımı (hazırlık ekranından erişim)
6. **Ayarlar** — Ses (master/music/sfx), titreşim, dil, tap modu toggle, tutorial tekrar, save export, analytics opt-out
7. **Credits** — Asset kaynakları + lisanslar

*(IAP Shop ekranı Faz 6'da eklenir)*

### 6.2 Hazırlık Ekranı Layout (portrait, vardiya öncesi)
```
┌─────────────────────────────┐
│ [🪙 1.250,00]   [⚙️]        │  ← B-Coin bakiyesi + ayarlar
│ Vardiya 24 hazırlığı        │
├─────────────────────────────┤
│ [Stok] [Sipariş] [Fiyat]   │  ← sekmeler
│ [Önceki Rapor]              │
├─────────────────────────────┤
│  ... sekme içeriği ...      │
│  (liste, sliderlar, vb.)    │
├─────────────────────────────┤
│   [▶  VARDİYAYI BAŞLAT]     │  ← büyük CTA
└─────────────────────────────┘
```

### 6.3 Kasa Ekranı Layout (portrait, vardiya esnası)
```
┌─────────────────────────────┐
│ [⏱ 4:32]    [B-Coin: 🪙 47,50]│  ← üst: geri sayım + bu vardiyanın net B-Coin
│                             │
│  [Müşteri portresi]         │
│  (3/4 büst, ifade swap'lı)  │  ← aktif müşteri görseli
│  [████░░ Sabır]             │  ← sabır bar
│                             │
│  [TOTAL: 🪙 12,50]          │  ← şu ana kadar taranan toplam
├─────────────────────────────┤
│  ← ████ KASA BANDI ████     │  ← orta — sıradaki ürün burada
│      [🥛]                   │  ← TEK ürün, tarayıcı zonunda durur
│      ↑                      │
│   [📷 TARAYICI]             │  ← swipe yapılan zon
├─────────────────────────────┤
│ Sırada: [👤] [👤]           │  ← kuyrukta bekleyen silüetler
└─────────────────────────────┘
```

**Önemli:** Vardiya esnasında kasa ekranında [Nakit] [Kart] [Monitör] butonları **yok**. Ödeme metodu müşterinin tipine göre otomatik açılır (kart cihazı widget'i veya 3-option para üstü). Monitöre vardiya içinde geçiş yoktur — sadece 5 dk dolduğunda otomatik geçilir.

### 6.4 Vardiya Sonu Raporu Layout
```
┌─────────────────────────────┐
│   🎉 Kepenk Kapandı!         │
├─────────────────────────────┤
│  İşlenen müşteri:   12       │
│  Kaçırılan talep:    3       │
│  Memnuniyet:    ★★★★☆        │
│  Toplam ciro:  🪙 247,50     │
│  Maliyet:     -🪙  98,00     │
│  ───────────────             │
│  Net kâr:     +🪙 149,50     │
│  XP:          +24            │
├─────────────────────────────┤
│ [Hazırlık Ekranına Dön]      │
└─────────────────────────────┘
```

### 6.5 UX Prensipleri
- Tek elle oynanabilir olmalı (tüm interaktif alanlar başparmak menzilinde)
- Swipe mesafesi kısa (sadece tarayıcı üzeri yatay 60-80 dp)
- Kritik bilgi (TOTAL, sabır metresi, geri sayım) her zaman görünür
- Modal geçişleri yumuşak (250ms fade), kullanıcı yönünü kaybetmez
- Tarama feedback'i çok güçlü: ses + flash + haptic — eş zamanlı
- Hazırlık ekranı kasıtlı olarak "sakin" tasarımlanır (renkler matlanır, animasyon az) — kasa ekranıyla kontrast yaratır

---

## 7. Sanat Yönetimi — Ücretsiz Asset Stratejisi

### 7.1 Yaklaşım
Outsource veya ücretli stok kullanmıyoruz. Tüm görseller **CC0 lisanslı** (public domain — attribution bile gerekmeyen) hazır asset paketlerinden alınır. Bu sayede sıfır maliyetle profesyonel görünüm sağlanır; lisans takibi de minimumdur.

### 7.2 Birincil Kaynak — Kenney.nl
Kenney.nl'in tüm asset'leri CC0 lisanslıdır, ticari kullanım serbest, attribution gerekmez.

**ÖNEMLİ:** Kenney pack'leri iki kategoriye ayrılır:
- **2D sprite pack'leri:** PNG/SVG. Doğrudan Flame'de kullanılır. (UI Pack, Game Icons, Roguelike vb.)
- **3D model pack'leri:** OBJ/FBX/glTF. Flame 2D motoru bunları render edemez. (Food Kit, Mini Market, Generic Items, Toon Characters vb.)

Bizim için kritik olan ürün ve ortam asset'leri 3D pack'lerde, dolayısıyla bir **2D-render pipeline** kurmamız gerekiyor. 3D modelleri bir kez Blender'da PNG olarak render edip projeye dahil ederiz; runtime'da hep 2D sprite kullanılır.

#### Doğrudan 2D (sprite) — Pack'ler
| Pack | İçerik | Kullanım |
|------|--------|----------|
| **UI Pack** (430 asset) | Butonlar, çerçeveler, paneller | Tüm UI doğrudan |
| **Game Icons** (105 ikon) | Genel oyun ikonları | Menü/HUD/B-Coin sembolü |

#### 3D → 2D render edilecek — Pack'ler
| Pack | İçerik | Hedef sprite |
|------|--------|--------------|
| **Food Kit** (200 model) | Yiyecek/içecek | Ürün ikonları (15 MVP + ek) |
| **Generic Items** (160 model) | Günlük eşya | Market dışı ürünler (deterjan, ampul vs.) |
| **Mini Market** (20 model) | Raf, kasa, sahne öğeleri | Kasa ortamı arka planı |
| **Toon Characters** | Karakter modelleri | Müşteri portreleri (6 çeşit × 3 ifade) |

### 7.3 Render Pipeline (Faz 0 görevi)
Tek seferlik bir asset-prep aşaması. Sonradan yeni ürün eklemek istediğimizde de aynı pipeline çalışır.

**Araçlar:**
- **Blender** (ücretsiz, açık kaynak)
- Python render scripti (`tools/render_assets.py`) — Blender'ın yerleşik Python API'sini kullanır

**Akış:**
1. Kenney 3D pack'lerini `tools/raw_models/` klasörüne çıkar
2. Render scriptini çalıştır — her model için:
   - Sabit kamera (örn: 30° isometric ya da hafif öne eğik 3/4 görünüm)
   - Sabit ışıklandırma (tüm modeller aynı look)
   - Transparan arka plan
   - `assets/images/products/<id>.png` olarak kaydet (512×512 hedef)
3. Üretilen PNG'ler doğrudan `pubspec.yaml`'a eklenir, Flame'de `Sprite.load('products/apple.png')` ile yüklenir

**Avantaj:** Tüm 200 ürün aynı stilde, ışıkta, açıdaydır. Manuel illüstrasyonda mümkün olmayan tutarlılık. Yeni ürün eklemek = Blender'a yeni model at + script çalıştır.

**Alternatif (script yazmak istemezsek):** Kenney'in kendi ücretsiz aracı **Asset Forge** (Deluxe ücretli) doğrudan "Export to 2D sprite" özelliği sunuyor. Manuel tek tek yapılır, 200 ürün için zaman alır ama programlamasız.

### 7.4 Asla yapmayacağımız şeyler
- Başka oyunlardan asset rip etmek (lisans ve etik ihlal)
- "Free for personal use" yazan asset'leri ticari kullanmak (gizli lisans tuzağı)
- Stable Diffusion/Midjourney ile üretilen görselleri Play Store gönderiminde kullanmak (politika riski; AI içerik beyanı gerekir)
- Birden fazla farklı stilde pack karıştırmak (stil bütünlüğünü bozar)
- Render pipeline'da farklı kamera açıları kullanmak (set içinde stil kırılır)

### 7.5 Kamera ve Perspektif
Birinci şahıs benzeri sabit kamera. Oyuncu kasanın arkasındadır; gördüğü: önünde kasa bandı, üst kısımda müşteri (göğüs üstü görünür, ifadeler vardır), arka fonda karşıdaki monitör ve raflar. Hareket yok → 3D'ye gerek yok, tüm sahne katmanlı 2D sprite (pre-rendered).

### 7.6 Stil
2D, semi-flat illustrasyon görünümlü pre-rendered sprite'lar. Kenney'in default 3D modellerinin look'u (low-poly + soft shading) zaten "cozy/calm" hissine doğal uyuyor — biz buna sabit isometric/3-quarter açıdan render ederek 2D stil yaratmış oluruz.

### 7.7 Asset İhtiyaç Listesi (MVP)
- 1 kasa ortamı arka planı (Mini Market 3D → tek bir kompozisyon olarak render edilir)
- 15 ürün ikonu (Food Kit + Generic Items'tan seçilip batch render)
- 6 müşteri portresi × 3 ifade = 18 sprite (Toon Characters → poz/yüz değişimleriyle render)
- B-Coin sprite'ı (Game Icons — zaten 2D)
- Banknot sprite'ları (UI Pack temel + custom renk/sayı overlay — Figma/GIMP'te)
- Tarayıcı, POS terminali sprite'ı (Mini Market render)
- UI ikon seti ~20 ikon (UI Pack — zaten 2D)
- Tutorial işaretleri: el, ok, parlama (UI Pack — zaten 2D)

### 7.8 Animasyon
Kenney sprite'ları üzerinde basit Flame tween'leriyle:
- Ürünün bantta soldan sağa kayıp tarayıcı zonunda durması (translate tween)
- Swipe sırasında ürünün hafif scale-up + parmağı takip eden trail efekti
- Tarayıcı laser çizgisi (loop animasyon, swipe başarılı olunca parlar)
- Başarısız swipe'da ürünün titreşmesi (shake animasyon)
- Müşteri ifade değişimi (sprite swap)
- 3-option para üstü seçeneklerinin slide-up animasyonu
- Doğru tap'lendiğinde seçenek glow + onaylama tick'i
- "BEEP" yazısının pop'lanması (scale + fade)

### 7.9 Mağaza Ortamı (Mini Market Pack — Sahne Dekoru)
Kenney Mini Market pack'i ürün modeli değil **mağaza ekipmanı + mimari** modelleri içerir. İlk render denemelerinden sonra hangi öğelerin gerçekten kullanılabilir olduğu netleşti — bazı modeller (display'ler, cash_register, freezer) ya formu okunaklı çıkmadı ya da bizim ürün ikonlarıyla görsel çakışma yarattı. Pragmatik karar: yalnızca **görsel kimliği güçlü olan + UX'i bozmayan** 4 prop MVP'de kullanılır, geri kalanlar Faz 3 ana menü composite veya post-launch için reserved.

**MVP'de aktif kullanılacak (4 prop):**

| Asset | Ekran | Rol |
|-------|-------|-----|
| `character-employee.obj` | Hazırlık + Vardiya sonu rapor | Oyuncu avatarı (3/4 büst, sabit poz). "Selam, bugün ne yapacaksın?" / "Bugün iyi iş çıkardın!" |
| `shopping-cart.obj` | Hazırlık → Sipariş sekmesi | "Bu vardiyaya hazırlanan siparişler" göstergesi |
| `shopping-basket.obj` | Vardiya sonu rapor | "Satılan ürünler" satırının başında küçük ikon |
| `shelf-boxes.obj` | Stok sekmesi | Sekmenin üst banner'ında başlık görseli (her ürün satırının yanında değil — UI dağıtır) |

**Kategori başlıkları — emoji ile, prop ile DEĞİL:**
İlk plan kategorilerin başlığına Mini Market `display-bread.obj`, `display-fruit.obj`, `freezer-standing.obj` koymaktı. İlk render'larda görüldü ki bu display'ler **bizim ürünlerimize görsel olarak çok benziyor** — display_bread içindeki somunlar oyun-içi `bread` ürünüyle aynı silüette, display_fruit içindeki elmalar `apple` ürünüyle aynı renkte. Oyuncu "kategori başlığı mı, ürün mü?" karışıklığı yaşar. Bu UX kuralının (soyut sembol vs. somut ürün) ihlali.

Çözüm: Kategori başlıkları için **Unicode emoji** kullanılır. Mobile native rendering, ölçeklenir, tutarlı ton, platform üzerinde tanınır:

| Kategori | Emoji | Başlık (TR) |
|----------|:----:|-------------|
| gida_temel | 🍞 | Gıda Temel |
| icecek | 🥤 | İçecek |
| atistirmalik | 🍫 | Atıştırmalık |
| premium | ⭐ | Premium |
| manav | 🍎 | Manav |

`products.json` içinde her kategori için `emoji` field tutulur, UI tarafında `Text("${cat.emoji} ${cat.name_tr}")` ile render edilir.

**MVP dışı bırakılanlar (düşürüldü veya saklandı):**
- `cash-register.obj` — render edildi ama form mobil ekranda okunmuyor (sol kısım büyük gri kutu, sağ küçük detay). Kasa ekranında zaten tarayıcı + kasa bandı var; ekstra dekor görsel curt yarattığı için **MVP'den düşürüldü**. PNG'si silinebilir.
- `display-bread.obj`, `display-fruit.obj` — yukarıda anlatılan ürün-çakışması nedeniyle **MVP'den düşürüldü**. Emoji ile değiştirildi. PNG'ler silinebilir.
- `freezer-standing.obj` — form bulanık, ne olduğu küçük boyutta okunmuyor. **Post-launch'a saklı**, donmuş ürünler kategorisi açılırsa yeniden değerlendirilir. PNG silinebilir.
- `wall.obj`, `wall-corner.obj`, `wall-window.obj`, `floor.obj` — Faz 3 ana menü splash sahnesi için **saklı**. Tek tek PNG değil, Blender'da composite sahne kurulup tek statik background olarak render edilir (henüz manifest'te yok, Faz 3'te eklenecek).

**Render pipeline:** Aktif 4 prop için ayrı manifest:
- `tools/render_manifest.json` → 15 ürün, çıktı `assets/images/products/`
- `tools/render_manifest_props.json` → 4 aktif sahne dekoru, çıktı `assets/images/props/`

Aynı `tools/render_assets.py` scripti iki manifest'i de işler.

---

## 8. Ses Tasarımı — Ücretsiz Kaynaklar

### 8.1 Strateji
SFX ve müzik tamamen ücretsiz, ticari kullanıma uygun kaynaklardan alınır. CC0 tercih edilir (attribution gerekmez); CC-BY tracker tutulur ve credits ekranında listelenir.

### 8.2 Birincil Kaynaklar

| Kaynak | İçerik | Lisans |
|--------|--------|--------|
| **Pixabay Music** | Arka plan müziği, ambient | CC0 (attribution gerekmez) |
| **Freesound.org** | SFX (beep, click, drawer, paper vs.) | CC0 + CC-BY karışık (filtre ile CC0 seç) |
| **Kenney Audio** | Hazır SFX paketleri | CC0 |
| **YouTube Audio Library** | Müzik + SFX | Royalty-free |
| **Mixkit** | Müzik + SFX | Mixkit License (ticari serbest) |

### 8.3 SFX Listesi (MVP)
- Barkod beep — 3 varyant (monotonluk olmasın) → Freesound.org "supermarket scanner beep" CC0
- Yanlış tarama "buzzer" → Freesound CC0
- Ürün kaldırma (pickup) → Kenney Audio "Interface Sounds"
- Ürün geri düşmesi → Freesound CC0
- Kasa çekmecesi açılma/kapanma → Freesound "cash register drawer"
- Madeni para sesi → Freesound "coin clink"
- Kart cihazı "approved" → Freesound "credit card terminal"
- Müşteri gibberish "merhaba/teşekkürler" — kısa nötr ses (dil bağımsız) → Freesound "vocal mumble"
- Müşteri sinirli homurdanma → Freesound

### 8.4 Müzik
2–3 track, hafif lo-fi / cozy tarzı. Pixabay Music'ten "lofi shop" / "cozy" / "casual game" aramalarıyla bulunabilir. CC0 olanları tercih et. Vardiya yoğunlaştığında tempo artması için aynı türden ikinci track (intense variant) seçilir, runtime'da crossfade.

### 8.5 Lisans Takibi
`assets/data/credits.json` dosyasında her ses ve görsel asset'in kaynağı, yazarı, lisansı tutulur. Credits ekranı bunu okur. CC0 olanlar bile listelenebilir (teşekkür amacıyla) ama zorunlu değildir.

### 8.6 Ses Mix Mimarisi
Üç ayrı volume kanalı:
- **Master volume** (0-100, default 80)
- **Music volume** (0-100, default 60)
- **SFX volume** (0-100, default 90)

Hepsi Ayarlar'da slider. Hive `settings_v1`'de saklı.

**Ducking:** Müşteri konuşma SFX'i çaldığında müzik 1 sn boyunca %30'a düşer (smooth fade). Bu sayede gibberish anlaşılabilir kalır.

**Eş zamanlı SFX limiti:** Aynı SFX (örn. beep) çok hızlı tetiklenirse `flame_audio`'nun varsayılan polyphony'sine güveniriz; tarama beep'i için ek olarak 80ms cooldown (combo sırasında ses çakışmasın).

**Format:** Tüm dosyalar `.ogg` (Android native destek, küçük dosya). SFX 22kHz mono, müzik 44kHz stereo 128kbps.

**Müzik geçişi:** Vardiya başlangıcında "calm" track, müşteri sayısı >5 ve sabır metresi düşükse "intense" track'e 2 sn crossfade. Vardiya sonu sessizlik (rapor ekranı sade).

---

## 9. Teknik Mimari (Flutter + Flame)

### 9.1 Proje Yapısı
```
lib/
├── main.dart
├── app.dart                     # MaterialApp + routing
├── game/                        # Flame tarafı
│   ├── cashier_game.dart        # FlameGame subclass
│   ├── components/
│   │   ├── belt.dart            # Kasa bandı
│   │   ├── product_component.dart # DragCallbacks mixin
│   │   ├── scanner.dart         # Drop target zone
│   │   ├── customer.dart
│   │   └── scan_line_fx.dart
│   ├── input/
│   │   └── scan_handler.dart    # swipe + tap modu strategy
│   └── overlays/                # Flame'in overlay sistemi
│       ├── total_hud.dart
│       ├── patience_meter.dart
│       └── tutorial_overlay.dart
├── screens/                     # Pure Flutter ekranlar
│   ├── home_screen.dart
│   ├── game_screen.dart         # GameWidget'i barındırır
│   ├── monitor_screen.dart
│   ├── shift_summary_screen.dart
│   ├── upgrade_screen.dart
│   ├── credits_screen.dart      # asset attribution
│   └── settings_screen.dart
├── models/                      # Hive @HiveType modelleri
│   ├── product.dart
│   ├── customer_model.dart
│   ├── inventory_item.dart
│   ├── shift_record.dart
│   └── player_profile.dart
├── services/
│   ├── customer_spawner.dart   # sıralı kuyruk akışı (sequential queue)
│   ├── economy_service.dart
│   ├── inventory_service.dart
│   ├── save_service.dart        # Hive wrapper + corruption recovery
│   ├── migration_service.dart   # box şema migration
│   ├── telemetry_service.dart   # Firebase Analytics wrapper
│   ├── remote_config_service.dart
│   ├── lifeline_service.dart    # soft-lock tespit + acil avans
│   ├── bcoin_formatter.dart      # sayı formatı (binlik ayraç, K/M kısaltma)
│   └── catalog_loader.dart      # JSON → Hive seed/migration
├── state/                       # Riverpod providers
│   ├── game_state.dart
│   ├── inventory_state.dart
│   ├── economy_state.dart
│   └── tutorial_state.dart
├── data/
│   └── catalog_seed.dart
└── theme/
    └── app_theme.dart

assets/
├── images/                      # Kenney assets (gruplanmış)
│   ├── products/
│   ├── customers/
│   ├── ui/
│   └── environment/
├── audio/
│   ├── sfx/
│   └── music/
└── data/
    ├── products.json            # master ürün katalogu (versionlu)
    └── credits.json             # asset attribution
```

### 9.2 Kütüphane Seçimleri
- **State management:** `flutter_riverpod`
- **Persistence:** `hive` + `hive_flutter`
- **Audio:** `flame_audio` (SFX), `audioplayers` (müzik)
- **Animasyon (UI):** `flutter_animate`
- **Routing:** `go_router`
- **Lokalizasyon:** `intl` — TR/EN metin desteği + sayı formatlama (`NumberFormat.decimal`)
- **Haptic:** Flutter'ın yerleşik `HapticFeedback`

*Reklam ve IAP paketleri (`google_mobile_ads`, `in_app_purchase`) Faz 6'da eklenir, MVP'de bağımlılık olarak dahil edilmez.*

### 9.3 Flame ↔ Flutter Köprüsü
- Ana oyun sahnesi `GameWidget(game: cashierGame)` Flutter sayfasının içinde
- Flame `overlayBuilderMap` ile HUD (sabır, total, butonlar) Flutter widget'ı olarak render edilir → Riverpod state'inden beslenir
- Tutorial overlay'i bu sistemin üstünde, en üst Z layer'da
- Monitör tam ekran Flutter route'u, dönüşte Flame oyunu `resumeEngine()`

### 9.4 Veri Mimarisi — Hibrit JSON + Hive
Master ürün katalogu `assets/data/products.json` dosyasında tutulur. Oyun ilk açıldığında veya katalog versiyonu değiştiğinde, `catalog_loader` JSON'u parse edip Hive'a yazar. Runtime'da hep Hive'dan okunur.

**Neden hibrit:**
- JSON: balance tuning kolay, git diff'lerde okunabilir
- Hive: runtime'da hızlı tip-güvenli okuma, oyuncu state'i ile aynı sistem

**Hive Box yapısı:**
```
catalog_v1        → Ürün master katalogu (JSON'dan seed)
inventory_v1      → Oyuncu stoğu, raf durumu, auto-reorder eşikleri
economy_v1        → B-Coin, XP, level, lifetime stats, acil avans sayacı
shifts_v1         → Vardiya geçmişi (son 30 vardiya)
settings_v1       → Ses (master/music/sfx), dil, titreşim, erişilebilirlik
tutorial_v1       → Tutorial step state
meta_v1           → Schema version, app version geçmişi
crash_recovery_v1 → Aktif vardiya snapshot'u (crash sonrası kurtarma)
```

*(IAP geçmişi için `purchases_v1` box'ı Faz 6'da eklenir.)*

**Migration stratejisi:** Her box `_v1` suffix taşır. Şema değişirse `_v2` box açılır, migration script eski box'tan yeni box'a kopyalar. Versiyon numarası `meta_v1` box'ında tutulur.

### 9.5 B-Coin Formatlama
Tüm B-Coin değerleri integer cinsinden (kuruş) tutulur (örn: 4750 = 47,50 B-Coin). `bcoin_formatter.dart` helper'ı locale-aware formatlama yapar:

```dart
// Backing: int kuruş. 4750 = 47,50 B-Coin.
String formatBCoin(int kurus, {String locale = 'tr_TR'}) {
  final value = kurus / 100.0;  // 47.50
  
  // Büyük rakamlar için kısaltma (yalnızca ≥100.000 B-Coin = 10.000.000 kuruş)
  if (kurus >= 100000000) {  // ≥ 1M B-Coin
    return NumberFormat('#,##0.0', locale).format(value / 1000000) + 'M';
  }
  if (kurus >= 10000000) {   // ≥ 100K B-Coin
    return NumberFormat('#,##0.0', locale).format(value / 1000) + 'K';
  }
  
  // Standart format: 2 ondalık, locale'e göre ayraçlar
  return NumberFormat('#,##0.00', locale).format(value);
}

// UI: Row([BCoinIcon(), Text(formatBCoin(coins))])
// 
// TR locale örnekleri:
// 5        → "0,05"        (5 kuruş)
// 4750     → "47,50"
// 999999   → "9.999,99"
// 9999999  → "99.999,99"
// 10000000 → "100,0K"      (≥100K B-Coin eşiği)
// 99999999 → "999,9K"
// 100000000→ "1,0M"
//
// EN locale: virgül/nokta yer değiştirir → "47.50", "9,999.99"
```

**Neden int (kuruş)?** Floating-point yuvarlama hataları özellikle elastikiyet hesabında (0.6 katsayısı, priceRatio çarpımları) sessiz buglar üretir. Tüm para `int` olarak akar, sadece UI katmanında 100'e bölünür.

### 9.6 Performans Hedefleri
- 60 FPS, en düşük Android 7+ cihazlarda 30 FPS minimum
- Cold start < 2.5 sn
- APK boyutu hedefi: < 60 MB

---

## 10. MVP Kapsamı (İlk yayın için minimum)

**MVP'de var:**
- 1 mağaza ortamı, 5 dk default vardiya, sıralı müşteri kuyruğu
- 15 ürün (tam liste, fiyat ve elastikiyet kategorileri için bkz. §23.2)
- 3 müşteri tipi (normal, aceleci, yaşlı)
- **Swipe-through one-at-a-time** tarama mekaniği + accessibility tap modu
- Nakit ödeme (tam para + 3-option para üstü) **ve** kart ödeme (tek tap onay, default %5 müşteri)
- Kart kapasitesi upgrade'i (%5 → %10 → %15 → %20), upgrade fiyatları için bkz. §23.4
- **Hazırlık ekranı (monitör):** stok takibi + manuel sipariş + auto-reorder threshold öneri sistemi + fiyat elastikiyeti slider'ları + önceki vardiya raporu
- Otomatik raflama (sabit hız)
- 5 mağaza seviyesi (XP eşikleri için bkz. §23.1)
- Türkçe arayüz (lokal)
- B-Coin para birimi — 2 ondalık, TL modeli denomination (5/10/25/50 kuruş madeni + 1 B-Coin + 2/5/10/20/50/100/200 B-Coin kağıt)
- 3-vardiyalık drip-feed tutorial
- Soft-lock önleme (acil avans mekaniği — bkz. §14)
- Telemetri event'leri (Firebase Analytics) — bkz. §15
- Crash reporting (Crashlytics)
- Credits ekranı (asset attribution)

**MVP'de YOK (post-launch'a kayan):**
- Reklam entegrasyonu (AdMob)
- IAP / Gem / Remove-ads
- İngilizce çeviri
- Play Store gönderimi
- Terazide tartılan ürünler
- VIP müşteri tipi + bahşiş
- "Bozuk para verici" özel tip (zorlu para üstü)
- İşçi işe alma
- İkinci kasa
- Dekorasyon / kozmetikler
- İndirim eventi
- Achievements / Google Play Games
- Cloud save (manual export var, bkz. §16)

---

## 11. Geliştirme Yol Haritası

Süreler kasıtlı olarak verilmedi — solo part-time geliştirme temposu kişisel ve değişkendir. Her faz tamamlandıkça bir sonrakine geçilir.

| Faz | Çıktı |
|-----|-------|
| **Faz 0 — Setup** | Flutter+Flame iskelet, paket seçimi, Kenney pack'leri indir, Blender render pipeline kurulumu (Python script + tutarlı ışık/kamera), 15 ürün için ilk batch render. Pipeline öğrenme eğrisi en uzun parça; fallback: Asset Forge ile manuel render. |
| **Faz 1 — Vertical Slice** | Tek müşteri, swipe-through tarama + 3 ürünlü sepet + nakit (tam para) ödeme + vardiya sonu özet. Tam döngü uçtan uca çalışır, 5 dk demo. |
| **Faz 2 — Sistemler** | Sıralı kuyruk akışı, kart ödeme akışı, 3-option para üstü, hazırlık ekranı (envanter/sipariş/fiyat), auto-reorder threshold, ekonomi servisi, rapor ekranı. |
| **Faz 3 — Content & Polish** | 15 ürün katalog tamamlanır, 3 müşteri tipi, ses (mix + ducking), drip-feed tutorial, sabır formülü tuning, elastikiyet ilk balance. |
| **Faz 4 — Lokalizasyon + Telemetri** | Tüm metinler `intl` arb dosyalarına, TR tam, Firebase Analytics event taxonomy entegre, Crashlytics aktif, Remote Config iskelet. |
| **Faz 5 — Closed Beta (TR)** | Arkadaş/aile test (en az 5 cihaz matrisi), balance tuning (özellikle elastikiyet), crash fix, soft-lock senaryoları doğrulama, ergonomi son ayarı. |
| **Faz 6 — Monetizasyon entegrasyonu** | AdMob hesap, rewarded video, IAP (Gem + remove-ads + Starter Pack + cosmetic bundles). |
| **Faz 7 — Soft Launch (Sadece TR)** | Play Store hesap, KVKK uyumlu Privacy Policy yayında, ilk production gönderim, metrik toplama, Remote Config balance ince ayar. Başarı kriterleri (§20.6) ile değerlendirme. |
| **Faz 8 — İngilizce + Global Launch** | EN çeviri (arb file), GDPR consent flow aktivasyonu, global market açılışı. |

Faz 5 (closed beta) ve Faz 7 (soft launch) en kritik karar noktalarıdır — bu fazlardaki metriklere göre sonraki faza geçiş ya da gerileme kararı verilir.

---

## 12. Riskler

- **Swipe-through tekdüze hissedebilir.** Müşteri tipleri, combo bonusu, kasıtlı barkod hataları (post-launch) ile çeşitlendirilir. Faz 1 vertical slice ergonomi testinde swipe hızı/tolerans ayarı validate edilir.
- **Vardiya temposu.** 5 dk + sıralı kuyruk modelinde yavaş oyuncu çok az müşteri işler → gelir az → progression yavaş. Sabır formülünün sepet-büyüklüğüne göre genişlemesi (§3.1) bunu telafi eder; yine de Faz 5'te playtest sonucu ince ayar gerekir.
- **Fiyat elastikiyeti dengelemesi.** Eğer ürünlerin elastikiyet/baseline değerleri yanlış ayarlanırsa oyuncu ya hiçbir şey değiştirmeden zengin olur ya da hiçbir kombinasyonla kâr edemez. En uzun balance fazını gerektiren sistem — Faz 3 ve Faz 5'te yoğun playtest. **Remote Config (§15) ile post-launch düzeltme** acil çözüm yolu olarak kalır.
- **Sipariş döngüsü yorabilir.** Auto-reorder threshold öneri sistemi (§3.5) MVP'de yer alır; "Tümünü onayla" tek tap'la sipariş kararını hızlandırır.
- **Kart oranı dengesi.** Default %5 kart-müşteri yeterince hissedilir mi yoksa çok seyrek mi? Faz 5'te telemetri ile doğrulanır; gerekirse default %8'e çekilir (Remote Config).
- **Flame ekosistem olgunluğu.** Unity'ye göre topluluk küçük. Flame Discord ve örnek projeler ile risk azaltılır.
- **Hazır asset bütünlüğü.** Tek bir kaynak ailesinden (Kenney) almak bunu büyük ölçüde çözer; karışım yapılırsa stil bozulabilir.
- **Blender Python pipeline öğrenme eğrisi.** Pipeline ilk iki hafta içinde stabil hale gelmezse fallback: Asset Forge ile manuel render (15 ürün yönetilebilir miktar).
- **Soft-lock (oyuncu B-Coin biterse).** §14'te tanımlı acil avans mekaniği bunu kapatır. Tutorial'da bu mekaniğin var olduğu açıkça öğretilmez (oyuncu strese girene kadar görmez) — Faz 5'te validasyon gerekir.
- **Play Store ilk gönderim onayı.** Bilinmedik geliştirici hesabı + IAP varsa süreç uzayabilir. KVKK uyumlu Privacy Policy + ToS hazır olmalı (§21). Faz 7'de buffer süre bırakılır.

---

## 13. Müşteri Davranış Detayları

### 13.1 Spawn Algoritması (Sıralı Kuyruk)
Vardiya 5 dk wall-clock geri sayımıyla başlar. Müşteri sıralı kuyruktan gelir; aynı anda kasada 1 aktif, kuyrukta 1-2 silüet.

```dart
// customer_spawner.dart pseudocode
class ShiftCustomerStream {
  final double shiftDurationSec = 300.0;  // 5 dk default
  double elapsedSec = 0.0;
  Customer? activeCustomer;
  
  // Müşteri ayrıldığında çağrılır
  Future<Customer?> nextCustomer() async {
    if (elapsedSec >= shiftDurationSec) return null;  // vardiya bitti
    
    // 0.5–1.5 sn yapay gecikme (müşteri yürüyüş animasyonu)
    final gap = 0.5 + random() * 1.0;
    await Future.delayed(Duration(milliseconds: (gap * 1000).toInt()));
    
    // Tip seçimi (mağaza seviyesine göre ağırlıklı)
    final type = weightedPick([
      CustomerType.normal: 0.65,
      CustomerType.aceleci: 0.20,
      CustomerType.yasli: 0.15,
    ]);
    
    return Customer(
      type: type,
      basket: generateBasket(catalog, storeLevel),
      paymentMethod: pickPayment(),  // kart oranı = mevcut upgrade
      change: pickChangeScenario(),  // tam para veya bozuk para
    );
  }
}
```

**Vardiya bitiş:** geri sayım 0'a indiğinde:
- Aktif müşteri varsa tamamlanmasına izin verilir (max +30 sn ek süre)
- Tamamlandığında "Kepenk kapandı" → rapor ekranı

### 13.2 Basket Composition (spawn-time elastikiyet kontrolü)
```dart
List<Product> generateBasket(Catalog catalog, int storeLevel) {
  final basket = <Product>[];
  final maxBasket = 2 + min(storeLevel * 2, 10);  // storeLvl 1: 2-4, lvl 5: 2-12
  final targetSize = 2 + random(0, maxBasket - 2);
  final candidates = catalog.unlockedProducts.shuffled();
  
  for (var p in candidates) {
    if (basket.length >= targetSize) break;
    if (random() < purchaseChance(p)) {
      basket.add(p);
      // Elastik ürünlerde indirim varsa ekstra adet
      if (p.priceRatio < 1.0 && random() < basketBoost(p)) {
        basket.add(p);
      }
    } else {
      missedDemand.record(p);  // raporda görünür
    }
  }
  return basket;
}
```

### 13.3 Sabır Formülü (Sepet Büyüklüğüne Bağlı)
Sabır müşteri kasaya geldiği an dolar; sepet büyüdükçe başlangıç süresi uzar (büyük sepeti taramak daha çok zaman alır, oyuncuya tolerans verilmeli).

```
maxPatience = basePatience(type) + basketSize × 4

basePatience by type:
  - normal:  40s   → 5 ürünlü sepet:  60s   ·  12 ürünlü: 88s
  - aceleci: 15s   → 5 ürünlü:        35s   ·  12 ürünlü: 63s
  - yaşlı:   60s   → 5 ürünlü:        80s   ·  12 ürünlü: 108s
  - VIP (post-launch): 50s → 5 ürünlü: 70s

patience(t) = maxPatience - t × decayRate × difficultyMultiplier
decayRate = 1.0 (saniyede 1 birim, ödeme aşamasında ×1.2)
difficultyMultiplier = 1.0 + (storeLevel - 1) × 0.08

Sıfıra inerse: müşteri çıkar
  → B-Coin kaybı: sepet değeri × 0.5
  → Memnuniyet: -1
```

**Sabır bar UI:** yeşil (>%66) → sarı (33–66) → kırmızı (<%33). Renk + emoji ifade ikonu (😊 → 😐 → 😠) eş zamanlı (renk körü erişilebilirliği için, §18). Kırmızıda titreşim animasyonu.

### 13.4 Ödeme Tipi Seçimi
```dart
PaymentMethod pickPayment() {
  final cardRate = economy.cardCapacity / 100.0;  // 0.05 default, max 0.20
  return random() < cardRate ? PaymentMethod.card : PaymentMethod.cash;
}

ChangeScenario pickChangeScenario() {
  // Yalnızca nakit müşteri için
  return random() < 0.30 
    ? ChangeScenario.bigBill  // bozuk para mekaniği (3-option)
    : ChangeScenario.exactCash;  // tam para (single tap)
}
```

### 13.5 Memnuniyet Skoru
Her vardiya sonu hesaplanır:
```
satisfaction = (completedCustomers - lostCustomers × 2 - wrongChange × 1) / totalCustomers
```
Aralık [-1, 1]. Vardiya rapor ekranında 5-yıldız (★★★★★) olarak görselleştirilir. 
- Yüksek memnuniyet (>0.8) → sonraki vardiyada **VIP spawn şansı +%3** (post-launch tetiği)
- Düşük memnuniyet (<0) → sonraki vardiyada müşteri akış aralığı +%20 yavaşlar (gelir kaybı)

---

## 14. Soft-lock Önleme ve Lifelines

Oyuncu kötü kararlarla ekonomik çıkmaza girebilir. Soft-lock tespit ve müdahale:

### 14.1 Tespit Kuralı
Her vardiya sonu çalışır:
```
if coins < 100 AND
   sum(warehouse) + sum(shelf) == 0 AND
   pendingOrders.isEmpty:
       triggerEmergencyAdvance()
```

### 14.2 Acil Avans (Emergency Advance)
Otomatik 500 B-Coin verilir. Önümüzdeki 3 vardiyanın net gelirinden %20 otomatik kesilir (max 3 × 200 = 600 B-Coin geri ödeme). Oyuncuya bir bildirim popup:
> "Acil avans aldın: 🪙 500. Sonraki 3 vardiyada %20 kesinti."

Bu mekanik **lifetime'da maksimum 3 kez** kullanılır; sonrasında "kâhya" (post-launch karakter) "Bu kez işler senin elinde" diyerek devre dışı kalır. Bu sayede acil avans sistematik istismar edilemez.

### 14.3 Tutorial Garantisi
İlk 5 vardiya boyunca her vardiya sonu otomatik 50 B-Coin "öğrenme yardımı" eklenir, oyuncu farkına varmaz (rapora "Yeni başlayan bonusu" olarak işlenir). Bu erken-deneyim soft-lock'unu önler.

### 14.4 Stok Sıfır Lifeline
Eğer mağazadaki tüm ürünlerin raf+depo stoğu 0'a düştüyse vardiya başlamaz; oyuncu önce sipariş ekranına yönlendirilir. Otomatik 200 B-Coin avans verilir (B-Coin yeterli değilse) ve "Başlangıç siparişi" önerisi gösterilir.

---

## 15. Telemetri, Analytics ve Live Ops

### 15.1 Araç
**Firebase Analytics** (ücretsiz, Flutter SDK olgun) + **Crashlytics** (crash reporting). Faz 4'te entegre edilir. Soft launch öncesi tam aktif.

### 15.2 Event Taxonomy (MVP)
Her event `snake_case` isimli, parametreler tipli:

```
# Lifecycle
app_opened                    {}
app_closed                    { session_duration_sec: int }
tutorial_step_completed       { step_id: int, step_name: str }
tutorial_skipped              { last_step: int }

# Gameplay
shift_started                 { shift_number: int, store_level: int }
shift_completed               { 
  shift_number, customers_served, customers_lost, 
  coins_earned, coins_spent_on_orders, satisfaction_score 
}
customer_completed            { 
  customer_type: str, basket_size: int, 
  scan_time_sec: float, payment_correct: bool 
}
customer_lost                 { reason: 'patience_zero' | 'wrong_change' }

# Economy
order_placed                  { product_ids: list, total_cost: int }
price_changed                 { product_id: str, old_price, new_price, elasticity }
emergency_advance_triggered   { count: int }  # tetik sayısı

# Progression
store_level_up                { new_level: int, total_xp: int }
equipment_purchased           { item_id: str, cost: int }

# Errors
error_caught                  { error_type: str, screen: str }
save_load_failed              { box: str, fallback_used: bool }

# Monetization (post-launch)
ad_shown                      { type: 'rewarded'|'interstitial' }
ad_completed                  { type: str, reward_id: str? }
iap_purchase_completed        { product_id, price_usd, currency: str }
```

### 15.3 KPI Dashboards (Firebase + custom)
- D1, D7, D30 retention
- Average session duration
- Shifts per session
- Tutorial completion rate (her adımda drop-off)
- Customer-lost rate per shift number (öğrenme eğrisi)
- Emergency advance trigger frequency
- Average elasticity slider değeri (oyuncular ne yapıyor?)
- (post-launch) ARPDAU, IAP conversion, ad LTV

### 15.4 Remote Config (Faz 7+)
Firebase Remote Config ile balance parametreleri uzaktan değiştirilebilir:
- `customer_decay_rate_multiplier`
- `elasticity_curve_factor` (formüldeki 0.6 katsayısı)
- `emergency_advance_amount`
- `tutorial_bonus_per_shift`
- `feature_flags.cart_payment_enabled`, vs.

Bu sayede APK güncelleme beklemeden balance ince ayarı mümkün olur. **Önemli:** Remote Config değerleri savunmacı olarak parse edilir, hatalı değer fallback default'a düşer.

### 15.5 Gizlilik
- Tüm event'ler **anonim** — kişisel veri (isim, email, telefon, konum) toplanmaz
- IDFA / Advertising ID sadece reklam ağı için, opt-out destekli
- Analytics opt-out Ayarlar ekranında: "Anonim kullanım verisi paylaşmayı kapat" toggle
- Bkz. §21 Yasal Uyumluluk

---

## 16. Hata Yönetimi ve Veri Bütünlüğü

### 16.1 Crash Reporting
**Firebase Crashlytics** entegre. Tüm `FlutterError.onError` + zoned errors yakalanır. Crash anında:
- Crashlytics'e raporlanır
- Aktif vardiya state'i "recovery snapshot" olarak ayrı bir Hive box'a (`crash_recovery_v1`) yazılır
- Sonraki açılışta oyuncuya "Önceki oturumunda bir sorun oldu, vardiyana kaldığın yerden devam etmek ister misin?" pop-up'ı gösterilir

### 16.2 Hive Corruption Recovery
Hive box açılırken `corruptedBoxException` yakalanırsa:
1. Bozuk box `.corrupted_<timestamp>` ekiyle yedeklenir
2. Yeni boş box açılır
3. `catalog_loader` JSON'dan re-seed eder (catalog), `economy_v1` ise default değerlerle başlatılır
4. Oyuncuya "Save verisi geri yüklendi, bazı ilerleme kaybolmuş olabilir" uyarısı
5. Crashlytics'e custom event olarak raporlanır (`hive_corruption_recovered`)

### 16.3 Save Backup — Manual Export (MVP)
Oyuncu Ayarlar'dan "Save verimi yedekle" butonuyla tüm Hive box'larını JSON'a serialize edip `.kasiyer_save_<date>.json` olarak paylaşabilir (Android share intent). "Geri yükle" tersi.

Cloud save MVP'de yok, post-launch (Google Play Games Services veya Firebase) eklenir. Manual export bu boşluğu doldurur.

### 16.4 Asset Load Failure
Sprite yüklemesi başarısız olursa `assets/images/_fallback.png` (mor-siyah satranç pattern, "MISSING" yazılı) kullanılır. Oyun çökmez. Crashlytics'e raporlanır.

### 16.5 Network Failure (post-launch)
Reklam yüklenemezse rewarded butonu gri/disabled olur, hata mesajı: "Reklam şu an müsait değil." IAP başarısızlığı: standart store hata mesajı; satın alma logu Crashlytics'e gönderilir.

### 16.6 Save Migration
Hive box şema değişikliği için her box `_v1`, `_v2` suffix ile versiyonlanır. `services/migration_service.dart` her açılışta `meta_v1.schema_version`'ı kontrol eder ve gerekli `vN_to_vN+1` migration'ı çalıştırır. Migration başarısız olursa kullanıcıya bilgi verilir, eski box yedeklenir.

---

## 17. Performans ve Asset Bütçesi

### 17.1 Hedefler (yeniden)
- 60 FPS hedef (Snapdragon 660 ve üstü)
- Minimum 30 FPS (Android 7+, low-end cihaz, 2GB RAM)
- Cold start < 2.5 sn (release build, low-end cihaz)
- APK boyutu < 60 MB (App Bundle ile dağıtım, kullanıcı indirme ~30 MB)
- Heap memory < 200 MB aktif oyunda

### 17.2 Sprite Atlas Stratejisi
Tüm ürün ikonu PNG'leri tek bir atlas'a paketlenir (TexturePacker veya manuel grid). Hedef:
- Ürünler: 1 atlas (1024×1024, ~80-100 ürün için)
- UI: 1 atlas (UI Pack zaten optimize)
- Karakterler: 1 atlas (müşteriler + ifadeler)

Flame'in `SpriteSheet` sınıfı atlas'tan tek tek frame okumayı destekler. `Sprite.load('atlas.png')` tek seferlik IO, sonra in-memory kullanım.

### 17.3 Texture Memory Budget
- Toplam runtime texture memory hedefi: < 80 MB
- Tek atlas en fazla 4 MB (1024×1024 RGBA = 4MB raw, PNG compressed ~500KB-1MB disk)
- Müşteri portreleri tek tek sprite (atlas yerine), kullanılmayanlar `evict()` ile boşaltılır

### 17.4 Draw Call Bütçesi
- Hedef: vardiya sırasında < 50 draw call per frame
- Strateji: aynı atlas'taki ürünler tek batch'te render
- UI overlay (Flutter widget'ları) ayrı render katmanı, draw call yumuşak

### 17.5 Asset Boyut Limitleri
| Asset tipi | Maks dosya | Açıklama |
|------------|------------|----------|
| Ürün PNG (raw) | 50 KB | 512×512 RGBA, optimize edilmiş |
| Müşteri portresi | 80 KB | 512×512, ifade başına |
| Background | 500 KB | 1920×1080 max, JPEG |
| UI element | 20 KB | UI Pack default'ları |
| SFX (.ogg) | 30 KB | 16-bit, 22kHz mono — beep/click |
| Müzik (.ogg) | 1.5 MB | 128 kbps stereo, loop'lu |

### 17.6 Profiling Plan
- Faz 1 sonu: Flame DevTools ile frame timing baseline
- Faz 3 sonu: gerçek cihazlarda (en az 1 low-end Android 7 cihaz) test
- Faz 5: tüm cihaz matrisi (bkz. §20 QA)

---

## 18. Erişilebilirlik

### 18.1 Renk Körü Modu
- Sabır metresi: yeşil/sarı/kırmızı gradient'inin yanında ek **şekil göstergesi** (yüz ifadesi ikonu: 😊 → 😐 → 😠) — renkten bağımsız okunur
- B-Coin/banknot denomination ayrımı sadece renkle değil **sayı + sembol kombinasyonu**
- Ayarlar'da "Renk körü modu" toggle: tüm UI'da kontrast %20 artar, gradient'ler düz blok renklere döner

### 18.2 Text Scaling
Tüm metinler Flutter'ın `MediaQuery.textScaleFactor`'ına saygı duyar. 0.8x – 1.6x arası bozulmaz. Sabit-yükseklik containerlar yerine `Expanded` + `Flexible` kullanılır.

### 18.3 Haptic Opt-out
Ayarlar'da "Titreşim" toggle. Default: açık. Kapatılırsa `HapticFeedback.*` çağrıları no-op.

### 18.4 Ses Bağımsız İpuçları
Kritik feedback (tarama başarılı, ödeme tamam) sadece sesle değil:
- Görsel: flash + scale animasyonu
- Haptic: kısa titreşim (opt-out)
- Yazı: "BEEP!" / "OK!" pop-text

Bu üçlü redundancy işitme engelli oyuncular için kritik.

### 18.5 Dokunma Hedef Boyutu
Tüm tappable element minimum 48×48 dp (Material guideline). Para üstü çekmece chip'leri 56×56 dp.

### 18.6 Animasyon Azaltma
"Animasyonları azalt" toggle: spring/bounce animasyonları kapanır, fade kullanılır. Combo zincir animasyonu sadece sayaç olur.

---

## 19. Tipografi ve Yazı Tipi

### 19.1 Yazı Tipi
**Nunito** (Google Fonts, SIL OFL lisansı, ticari serbest). Türkçe ı/İ/ğ/ş/ç/ö/ü tam destek. "Cozy" ton için uygun yumuşak hatlı sans-serif. Ağırlıklar: Regular (400), SemiBold (600), Bold (700).

Alternatif: **Inter** (aynı lisans, daha keskin). Karar Faz 0 sonunda görsel testle.

Pubspec entry:
```yaml
fonts:
  - family: Nunito
    fonts:
      - asset: assets/fonts/Nunito-Regular.ttf
      - asset: assets/fonts/Nunito-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Nunito-Bold.ttf
        weight: 700
```

### 19.2 Font Size Skalası
- Display (vardiya sonu B-Coin sayısı): 32sp
- Headline (ekran başlığı): 24sp
- Title (kart başlığı, TOTAL): 20sp
- Body (genel metin): 16sp
- Caption (etiket, ipucu): 12sp

### 19.3 Lokalizasyon Özellikleri
- `intl` paketinin TR plural'i: `count: ${customers} müşteri` (Türkçede tekil/çoğul aynı; ICU plural sadece yer tutar)
- Tarih formatı: TR locale, "26 Kasım 2026"
- Sayı formatı: TR `1.250` (nokta binlik ayraç), EN `1,250` (virgül) — `NumberFormat.decimalPattern(locale)`

---

## 20. Build, Release ve QA Stratejisi

### 20.1 Build Pipeline
- **CI:** GitHub Actions. Push üzerine: `flutter analyze`, `flutter test`, `flutter build apk --release` (artifact upload)
- **Versionlama:** Semantic version `major.minor.patch` (örn `1.0.3`); `pubspec.yaml`'da `version: 1.0.3+12` (build number CI auto-increment)
- **Code signing:** Release key Android Keystore (.jks), CI secret olarak şifrelenmiş; **ASLA git'e commit edilmez**, lokal yedeği şifreli storage
- **Obfuscation:** Release build `--obfuscate --split-debug-info=build/symbols/` — Crashlytics'e symbol upload

### 20.2 Test Stratejisi
| Test tipi | Kapsam | Ne zaman |
|-----------|--------|----------|
| Unit | Economy formülleri, elasticity hesabı, formatBCoin, migration | Her commit |
| Widget | Monitör sekmeleri, vardiya sonu ekranı | Faz 3+ |
| Golden | Kritik ekranların pixel-snapshot'u | Faz 4+ |
| Integration | Tam vardiya akışı (Flame + Flutter) | Faz 3+ |
| Manual smoke | Yeni build'te 10 dakikalık manuel akış | Her release |

### 20.3 Cihaz Test Matrisi
Faz 5 closed beta'da minimum 5 cihaz:
- 1× Low-end Android 7, 2GB RAM (örn. eski Samsung J-serisi)
- 1× Mid Android 10, 4GB RAM
- 1× High-end Android 13+
- 1× Tablet (10")
- 1× Geniş ekran / katlanır (varsa)

### 20.4 Release Track'leri
- **Internal testing:** Geliştirme buildleri, kapalı grup (≤10 kişi)
- **Closed alpha:** Faz 5 friends&family (≤50)
- **Open beta:** Soft launch öncesi (≤500)
- **Production:** TR ülke kilidi → sonra global

### 20.5 Release Notes Pipeline
Her sürüm için `CHANGELOG.md` güncellenir. Play Console "What's New" alanına TR + (post-launch) EN olarak yazılır. Otomasyon: GitHub release tag → CHANGELOG diff → Play Console'a manual paste (ilk sürümlerde, sonra automation).

### 20.6 Soft Launch Başarı Kriterleri
Faz 7 metriklerine göre:
- Crash-free users > %98 → ✅ devam
- D1 retention > %30 → ✅ kabul edilebilir
- Tutorial completion > %70 → ✅ tutorial OK
- Median session > 4 dk → ✅ engagement OK

Herhangi biri başarısız → o alanda iyileştirme, Faz 8 ertelenir.

---

## 21. Yasal Uyumluluk

### 21.1 KVKK (Türkiye) — Soft Launch Şartı
- **Privacy Policy** sayfası web'de yayında olmalı (basit GitHub Pages veya Notion public site yeterli, Play Store URL gerektirir)
- Topladığımız "kişisel veri" yok diye iddia edilemez: IDFA, Advertising ID, crash logs analytics ID kapsamına girer
- KVKK metni: hangi veriler toplandığı, hangi amaçla, ne kadar saklandığı, kullanıcı hakları (erişim, silme), iletişim adresi
- Uygulamada: ilk açılışta consent banner (kabul/reddet); reddedilirse analytics opt-out (oyun çalışır)

### 21.2 GDPR (Avrupa) — Faz 8 Şartı
- TR-only soft launch GDPR kapsamına girmez ama global launch için gerekli
- AdMob/Firebase otomatik EU consent flow desteği var; aktive edilir
- "Data deletion request" e-posta adresi belirlenir

### 21.3 Play Store Gönderim Checklist
- [ ] Privacy Policy URL (public, erişilebilir)
- [ ] Data safety form (Play Console) — hangi veriler toplanıyor, hangi 3. parti
- [ ] Target API level (Android güncel min 14 = Android 14)
- [ ] Permissions justification (INTERNET, vibrate)
- [ ] In-app purchase declaration (post-launch'ta)
- [ ] Ad declaration (post-launch'ta, AdMob entegre olduğunda)
- [ ] Content rating questionnaire — bu oyun "Everyone" / PEGI 3 hedefli
- [ ] Screenshots (telefon + 7" tablet)
- [ ] App icon (512×512), feature graphic (1024×500)

### 21.4 Asset Lisans Compliance
Kenney CC0 olduğundan attribution gerekmez ama hala `assets/data/credits.json` ile listelenir (etik + topluluk şeffaflığı). Pixabay/Freesound CC-BY varsa attribution zorunlu — Credits ekranı bu listeyi okur.

### 21.5 IAP Yasal Notları (Faz 6+)
- Tüketici hakkı: dijital ürün satın alma sonrası iade — Türkiye'de 14 gün cayma hakkı; Google Play store iade politikası tutulur
- Vergi: Google Play'in seller olarak rolü gereği KDV otomatik hesaplanır; geliştirici tarafı net gelir alır
- Şirket olarak satış yapacaksanız (post-launch) gelir vergi beyanı

---

## 22. Sonraki Adımlar

Bu GDD artık geliştirmeye başlamak için yeterli olgunlukta. Aşağıdaki sıraya göre ilerlenir.

### Hemen — Kurulum
1. **GDD onayı:** Bu v0.7 sürümünü gözden geçir, "tamam" denmeden geliştirme başlamasın.
2. **Hesap kurulumları:** GitHub repo, Firebase projesi (Analytics + Crashlytics + Remote Config), Google Play Console geliştirici hesabı (25$ tek seferlik).
3. **Privacy Policy taslağı:** Boş bir Notion sayfası veya GitHub Pages site — Faz 7'ye kadar yayında olmayabilir ama URL şimdiden ayrılsın.

### Faz 0 — Setup
4. **Flutter+Flame iskelet:** `flutter create`, paket eklemeleri (riverpod, flame, hive, intl, flame_audio, go_router, firebase_core, firebase_analytics, firebase_crashlytics).
5. **Kenney pack'leri indir:** Food Kit, Mini Market, Generic Items (3D), UI Pack + Game Icons (2D), Toon Characters (2D).
6. **Render pipeline kur:** `tools/render_assets.py` Blender Python scripti; sabit kamera (isometric 30°), Sun + 2 area light, transparan PNG çıktısı (512×512). 15 MVP ürünü için ilk batch. Pipeline ilk denemede stabilize olmazsa fallback: Asset Forge.
7. **Font ekle:** Nunito (Google Fonts'tan TTF indir, `assets/fonts/`'a koy, pubspec'e tanıt).
8. **`products.json` taslağı:** İlk 15 ürün — id, name_i18n, category, costPrice (kuruş), defaultSellPrice (kuruş), elasticity (0/1/2), iconAsset, unlockLevel. JSON Schema validator yaz.
9. **Hive box init:** `catalog_v1`, `economy_v1`, `inventory_v1`, `meta_v1`, `settings_v1`, `tutorial_v1` — açılışta seed, başlangıç sermayesi 100.000 kuruş (1.000,00 B-Coin).
10. **`bcoin_formatter.dart`:** int kuruş → locale-aware "47,50" formatı. Unit testler.
11. **CI iskelet:** GitHub Actions, `flutter analyze` + `flutter test` minimum, build APK artifact.

### Faz 1 — Vertical Slice
12. **Tek müşteri spawn + 3 ürünlü sepet + swipe-through tarama + nakit tam-para ödeme + vardiya sonu özet.** 5 dk geri sayım, sıralı kuyruk akışı, uçtan uca demo. **Faz 1 ürünleri:** Ekmek, Süt, Çikolata (bkz. §23.6).
13. **Ergonomi testi:** Swipe-through'u 3 kişiye 5 dakika oynat, geri bildirim al. Tap modu opsiyonunu da test et. Hız/tolerans parametrelerini ayarla.

Faz 1 sonunda elimizde: oynayabilir bir demo, gerçek Android cihazında 60 FPS, swipe ergonomisi doğrulanmış, Crashlytics canlı, B-Coin formatı temiz. Buradan Faz 2 (sıralı kuyruk yönetimi, kart ödeme, 3-option para üstü, hazırlık ekranı) başlar.

---

## 23. Balance Parametreleri ve İçerik Tabloları

Bu bölüm GDD'nin somut sayısal/içerik kararlarını toplar. Tüm fiyatlar **kuruş cinsinden integer** (1 B-Coin = 100 kuruş). Değerler Faz 5 playtest sonucu Remote Config (§15.4) ile ince ayarlanabilir.

### 23.1 Mağaza Seviyesi Tablosu

| Lvl | XP eşiği (toplam) | Açılan ürün | Max sepet | Vardiya süresi | Açılan upgrade'ler |
|-----|-------------------|-------------|-----------|----------------|---------------------|
| 1 | 0 (başlangıç) | 3 (gıda temel) | 4 | 5 dk | — (yalnızca temel mekanik) |
| 2 | 100 | +3 (içecek) → 6 | 6 | 5 dk | Tarayıcı v2 satın alınabilir |
| 3 | 300 | +3 (atıştırmalık) → 9 | 8 | 6 dk | Kart kapasitesi %5→%10 satın alınabilir |
| 4 | 800 | +3 (premium) → 12 | 10 | 6 dk | Kart %10→%15, Otomatik raflama v2, Elektronik fiyat etiketi (post-launch) |
| 5 | 2000 | +3 (manav) → 15 | 12 | 7 dk | Kart %15→%20, Tarayıcı v3, İkinci kasa (post-launch) |

**Notlar:**
- XP curve ~2.5× her seviyede (sabit difficulty perception).
- Vardiya süresi 5/6/7 dk artışı, level 3 ve 5'te oyuncuya "yeni bir nefes" hissi verir.
- Max sepet, müşteri başına ortalama 1-2 fazla ürün → gelir doğal büyür.

### 23.2 MVP Ürün Listesi (15 ürün)

`products.json` için tam tablo. Tüm fiyatlar **kuruş** cinsinden. Tema: **"fresh market"** — beş kategori, hepsi Kenney Food Kit pack'inden render edilir (asset bütünlüğü için tek pack).

| id | name (TR) | category | costPrice | defaultSellPrice | elasticity | unlockLevel | asset (Food Kit OBJ) |
|----|-----------|----------|----------:|-----------------:|:----------:|:-----------:|----------------------|
| bread | Ekmek | gida_temel | 125 | 250 | 0 (inelastik) | 1 | `bread.obj` |
| milk_carton | Süt | gida_temel | 550 | 800 | 0 | 1 | `carton.obj` |
| mineral_water | Maden Suyu | gida_temel | 75 | 150 | 0 | 1 | `soda-bottle.obj` |
| cola_can | Kola | icecek | 350 | 700 | 1 (normal) | 2 | `soda-can.obj` |
| soda_bottle | Gazoz | icecek | 400 | 800 | 1 | 2 | `soda.obj` |
| juice_bottle | Meyve Suyu | icecek | 600 | 1100 | 1 | 2 | `bottle-ketchup.obj` |
| chocolate | Çikolata | atistirmalik | 400 | 800 | 1 | 3 | `chocolate-wrapper.obj` |
| chips_bag | Cips | atistirmalik | 350 | 750 | 1 | 3 | `bag-flat.obj` |
| cookie | Bisküvi | atistirmalik | 250 | 500 | 1 | 3 | `cookie.obj` |
| candy_bar | Premium Çikolata | premium | 1200 | 2500 | 2 (elastik) | 4 | `candy-bar-wrapper.obj` |
| croissant | Kruvasan | premium | 800 | 1500 | 2 | 4 | `croissant.obj` |
| pudding | Yoğurt | premium | 450 | 900 | 1 | 4 | `pudding.obj` |
| apple | Elma | manav | 250 | 500 | 1 | 5 | `apple.obj` |
| tomato | Domates | manav | 200 | 400 | 1 | 5 | `tomato.obj` |
| banana | Muz | manav | 350 | 700 | 1 | 5 | `banana.obj` |

**Marj analizi (default fiyatlarda):**
- İnelastik (0): %100 marj sıklığı (ekmek 2,50 / 1,25; maden suyu 1,50 / 0,75). Fiyat artırma stratejisine açık — temel ihtiyaç, talep stabil.
- Normal (1): %50–90 marj. Dengeli, slider'la denenir. Kategori çeşitliliği fazla (içecek, atıştırmalık, manav).
- Elastik (2): %60–100 marj ama priceRatio > 1.0'a duyarlı. İndirim eventi (§3.5) ile basket boost vurulur. Premium çikolata ve kruvasan bu kategoride.

**Asset eşleştirmesi:**
- 15 ürün × 1 sprite = 15 PNG (512×512 transparan)
- Hepsi tek pack'ten (Kenney Food Kit, CC0) → stil bütünlüğü garantili
- Render: Blender + Python pipeline (`tools/render_assets.py`, `tools/render_manifest.json`)
- Mini Market pack mağaza ortamı için kullanılır (raflar, kasa makinesi, freezer — Faz 3 sahne dekorasyonu)

**Kategori değişikliği notu (v1.0.1):** Orijinal v1.0 GDD'sinde 5. kategori "hijyen" idi (diş macunu, sabun, tuvalet kağıdı). Asset araştırması sonucu Kenney Mini Market pack'inin hijyen ürünleri içermediği tespit edildi (pack mağaza altyapısı verir, ürün vermez). Çözüm: 5. kategori **"manav"** olarak değiştirildi — Food Kit'in zengin meyve/sebze envanteri (elma, domates, muz) "fresh market" tematiğine de daha uygun düştü. Hijyen kategorisi post-launch genişletmesinde Generic Items pack veya custom asset ile dönebilir.

### 23.3 XP Kazanma Kuralları

| Eylem | XP |
|-------|---:|
| Müşteri tamamlandı (normal/yaşlı) | +1 |
| Müşteri tamamlandı (aceleci — zor) | +2 |
| Doğru para üstü (3-option) | +1 |
| Combo (her 5 ardışık başarılı swipe) | +2 |
| Vardiya tamamlama (5 dk dolup kepenk kapanması) | +5 |
| Yüksek memnuniyet bonusu (vardiya satisfaction > 0.8) | +10 |
| Mükemmel vardiya (0 lost customer) | +15 |
| Tutorial adımı tamamlama | +3 (her adım) |

**Örnek vardiya hesabı (orta seviye oyuncu):**
10 müşteri (8 normal + 2 aceleci) × ortalama 1.2 XP = 12 XP
+ 7 doğru para üstü = 7 XP
+ 2 combo zinciri = 4 XP
+ vardiya tamamlama = 5 XP
+ memnuniyet bonusu (0.85) = 10 XP
**Toplam: ~38 XP / vardiya**

→ Lvl 2 (100 XP): ~3 vardiya · Lvl 3 (300 XP): ~8 vardiya · Lvl 5 (2000 XP): ~50-60 vardiya. Solo session başına 1-3 vardiya varsayımıyla level 5 ~3-4 haftalık casual progression.

### 23.4 Upgrade Fiyatları ve Etkileri

| Upgrade | Etki | Lvl gereksinimi | Maliyet (B-Coin) | Kategori |
|---------|------|:---------------:|----------------:|----------|
| Tarayıcı v2 | Swipe tolerance window %20 cömert | 2 | 500 | Mekanik |
| Kart kapasitesi %5→%10 | Kart-müşteri oranı 2× | 3 | 800 | Pazar erişimi |
| Otomatik raflama v2 | Depo→raf hızı %50 ↑ | 4 | 3.000 | Operasyon |
| Kart kapasitesi %10→%15 | Kart-müşteri oranı 3× | 4 | 2.000 | Pazar erişimi |
| Tarayıcı v3 | Combo gap 1.5s → 2.0s | 5 | 8.000 | Mekanik |
| Kart kapasitesi %15→%20 | Kart-müşteri oranı max | 5 | 5.000 | Pazar erişimi |
| Elektronik fiyat etiketi (post-launch) | Toplu fiyat değişikliği UI'da | 4 | 6.000 | QoL |
| İkinci kasa (post-launch) | NPC asistan ikinci kasada — paralel müşteri akışı | 5 | 15.000 | İçerik |

**Toplam MVP upgrade maliyeti (lvl 5'e kadar tümü):** 500 + 800 + 3.000 + 2.000 + 8.000 + 5.000 = **19.300 B-Coin**. Ortalama vardiya net kâr ~30-80 B-Coin (lvl 2-3'te) → tüm upgrade'ler için ~250-300 vardiya. Bu, "uzun ama erişilebilir grind" hedefi.

### 23.5 Auto-reorder Default Davranışı

Sipariş sekmesinde her ürün satırında "auto-reorder" alanı var. Davranış kuralları:
- **Yeni ürün eklendiğinde:** threshold = 0, toggle = **kapalı** (oyuncu manuel açar)
- **UI sayı kutusu placeholder:** "örn: 10"
- **Önerilen aralık:** 5-20 adet (uyarı yok, tavsiye)
- **"Tümünü toplu set" butonu:** Bir sayı + "uygula" → tüm açık ürünlere o eşik uygulanır
- **Tetik:** Vardiya rapor ekranı kapanırken stok < eşik olan ürünler için sipariş satırları önceden doldurulmuş gelir. Oyuncu "Tümünü onayla" tek tap'le veya tek tek görerek onaylar (Coin düşümü açık görünür).
- **Kapatma:** Bir ürünün auto-reorder'ı kapalıyken sistem o ürünü öneri listesine almaz.
- **Tutorial:** Vardiya 3'te tek bir ürün (Süt) üzerinden mekanik tanıtılır (§4.1).

### 23.6 Faz 1 Vertical Slice — İlk 3 Ürün

Vertical slice prototipinde tüm akışı test etmek için ilk 3 ürün:

| id | asset | Neden seçildi |
|----|-------|---------------|
| bread (Ekmek) | `bread.obj` | İnelastik test — fiyat değişiminden bağımsız sat |
| milk_carton (Süt) | `carton.obj` | İnelastik kontrast — ekmekle birlikte farklı fiyat aralığı, farklı geometri |
| chocolate (Çikolata) | `chocolate-wrapper.obj` | Normal elastik (ileride candy_bar 2.0 için referans), paketli ürün barkod uyumu |

**Bu seçimin avantajları:**
1. Üç farklı 3D geometri (somun/dikdörtgen karton/ince paket) — render pipeline'ın geometri çeşitliliği test edilir
2. Üç farklı fiyat seviyesi (2,50 / 8,00 / 8,00 B-Coin) — formatter UI testi
3. Tutorial dostu (herkes bilir, görsel olarak ayırt edici)
4. Tek vardiyada her ürünün en az 2-3 kez satılması istatistiksel olarak olası → telemetri eventleri smoke test edilebilir

Faz 1 vertical slice tamamlanınca diğer 12 ürün batch render edilir (Faz 2-3 arasında, Asset Forge fallback gerekirse manuel render).

---

*Doküman canlıdır — her fazın sonunda güncellenmelidir.*
