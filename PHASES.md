## Faz 0 — Ortam ve proje doğrulama

**✅ TAMAMLANDI** — flutter doctor, analyze (0 error), test, debug APK ve gerçek cihazda (Samsung Galaxy A22) açılış doğrulandı.

**Amaç:** Geliştirme ortamının Flutter/Android APK için hazır olduğunu doğrulamak.

### Yapılacaklar

* Flutter SDK sürümünü kontrol et.
* Dart sürümünü kontrol et.
* Git kontrol et.
* Android SDK / platform-tools / build-tools mevcut mu kontrol et.
* Android Studio yoksa kurmaya çalışma.
* Flutter'ın Android toolchain'i kullanabildiğini doğrula.
* Projeyi oluştur.
* `pubspec.yaml` temel bağımlılıklarını belirle.
* Git repository oluştur/başlangıç commit'i oluştur.

### Çıktı

```text
neurobloom/
├── android/
├── lib/
├── assets/
├── test/
├── pubspec.yaml
├── README.md
├── ARCHITECTURE.md
├── ROADMAP.md
├── CONTRIBUTING.md
└── ATTRIBUTIONS.md
```

### Kontroller

```bash
flutter doctor
flutter --version
dart --version
flutter create .
flutter pub get
flutter analyze
flutter test
```

İlk APK kontrolü:

```bash
flutter build apk --debug
```

### Geçiş kriteri

* `flutter doctor` kritik Android hatası vermiyor.
* `flutter analyze` → 0 error.
* `flutter test` → başarılı.
* Debug APK oluşturulabiliyor.
* Uygulama Android cihaz/emülatörde açılıyor.

---

# Faz 1 — Design System + App Shell

**✅ TAMAMLANDI** — Material 3 tema, renk paleti, go_router bottom navigation (Home/Exercises/Games/Assistant/Progress/Premium), placeholder ekranlar; analyze/test/debug APK ve cihaz doğrulaması geçti.

**Amaç:** NeuroBloom'un görsel ve navigasyon temelini oluşturmak.

### Yapılacaklar

* Material 3 theme.
* NeuroBloom renk paleti.
* Typography.
* 24 px rounded cards.
* 56 px ana butonlar.
* Gradient sistemi.
* Hafif glassmorphism.
* Rounded icons.
* Light pastel background.
* Sayfa geçiş animasyonları.
* Responsive layout.
* Accessibility temel ayarları.
* `go_router`.
* Bottom navigation.

Ana navigasyon:

```text
Home
Exercises
Games
Assistant
Progress
Premium
```

### Çıktı

Henüz fonksiyonların tamamı çalışmak zorunda değil.

Ancak tüm ana sayfalar placeholder olarak açılabilmeli.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Manuel:

* Uygulama açılıyor.
* Bottom navigation çalışıyor.
* Her sekmeye geçilebiliyor.
* Geri navigasyon çalışıyor.
* Tema tutarlı.

### Geçiş kriteri

**Tüm navigation akışı crash olmadan çalışıyor.**

---

# Faz 2 — Splash + Onboarding + Profil

**✅ TAMAMLANDI** — Splash animasyonu, 5 adımlı onboarding akışı, 8 orijinal avatar, Hive üzerinden kalıcı UserProfile; analyze/test/debug APK ve cihaz doğrulaması geçti.

**Amaç:** İlk kullanıcı deneyimini tamamlamak.

### Yapılacaklar

Splash:

```text
Flower
   ↓
Speech bubble
   ↓
NeuroBloom
   ↓
Konuşmayı birlikte güçlendirelim.
```

Yaklaşık 2 saniye.

Onboarding:

```text
NeuroBot
   ↓
Merhaba...
   ↓
İsim
   ↓
Yaş 3–13
   ↓
Cinsiyet
   ↓
Avatar
   ↓
Profil oluştur
```

8 avatar.

Profil lokal olarak saklanacak.

### Veri modeli

Örneğin:

```text
UserProfile
├── name
├── age
├── gender
├── avatarId
├── createdAt
└── onboardingCompleted
```

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Manuel test:

* Uygulama ilk açılışta onboarding gösteriyor.
* Profil oluşturuluyor.
* Uygulama kapanıp açıldığında onboarding tekrar gelmiyor.
* Profil bilgileri korunuyor.
* Avatar değiştirilebiliyor.

### Geçiş kriteri

**Temiz kurulum → onboarding → profil → ana uygulama akışı tamamen çalışıyor.**

---

# Faz 3 — Ana Ekran + Duygu Sistemi

**✅ TAMAMLANDI** — Profil header, NeuroBot mesajı, 7 duygu seçici, haftalık duygu takvimi, günlük görev listesi, haftalık ilerleme; gerçek cihazda force-stop + yeniden açma testiyle verinin kalıcılığı doğrulandı. analyze/test/debug APK geçti.

**Amaç:** Çocuğun günlük kullanım döngüsünü oluşturmak.

### Ana ekran

```text
Profil
NeuroBot
"Bugün nasılsın bakalım?"

😊 😄 😐 😔 😟 😠 😮

Haftalık Duygu Takvimi

Bugünkü Görev
☐ Duygunu seç
☐ Egzersiz yap
☐ Mini oyun oyna

Haftalık İlerleme
```

### Duygu sistemi

7 duygu:

```text
very_happy
happy
neutral
sad
anxious
angry
surprised
```

Günde bir ana kayıt.

Ancak aynı gün değiştirilebilir.

### JSON

Duygular da mümkün olduğunca content-driven tutulabilir.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Unit test:

* Duygu kaydı.
* Aynı gün değiştirme.
* Haftalık veri hesaplama.
* Boş günler.

### Geçiş kriteri

**Bir haftalık duygu geçmişi doğru şekilde kaydedilip gösterilebiliyor.**

---

# Faz 4 — Egzersiz Content Engine

**✅ TAMAMLANDI** — tongue/lips/speech JSON içerik motoru, Exercise modeli, enabled/age filtreleme, gerçek cihazda görsel doğrulama yapıldı. Kullanıcı onayıyla yer tutucu (placeholder) egzersiz içeriği kullanılıyor; orijinal 9 dil + 12 dudak listesi daha sonra sağlanabilir.

Bu faz çok önemli.

**Amaç:** Egzersizleri UI kodundan tamamen ayırmak.

### Klasör

```text
assets/data/exercises/
├── tongue.json
├── lips.json
└── speech.json
```

### JSON parser

Örneğin:

```text
Exercise
├── id
├── category
├── title
├── description
├── instruction
├── duration
├── repetitions
├── tts
├── animation
├── xp
├── difficulty
├── ageRange
└── enabled
```

### Repository

```text
ExerciseRepository
        ↓
JSON Loader
        ↓
Exercise Model
        ↓
Exercise Provider
        ↓
UI
```

### Önemli

`enabled == false` olan egzersiz gösterilmemeli.

`ageRange` kullanıcının yaşına göre filtrelenmeli.

Hatalı JSON uygulamayı crash ettirmemeli.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Testler:

```text
JSON parsing
Invalid JSON
Missing field
Age filtering
Enabled filtering
Category filtering
```

### Geçiş kriteri

**Yeni bir egzersizi yalnızca JSON ekleyerek uygulamada gösterebilmek.**

---

# Faz 5 — Dil/Dudak Egzersizleri

**✅ TAMAMLANDI** — Egzersiz koşucusu (BAŞLA, tekrar sayacı, dairesel geri sayım), TTS servisi (tr-TR, kapatılabilir), XP ödülü ve tamamlama kaydı, kategori bazlı animasyon fallback'i; gerçek cihazda adb üzerinden uçtan uca doğrulandı (onboarding → egzersiz listesi → BAŞLA → 5 tekrar → tamamlanma ekranı → Home'da görev güncellemesi). analyze/test/debug APK geçti.

**Amaç:** NeuroBloom'un ana fonksiyonunu çalışır hale getirmek.

İki kategori:

```text
Dil
Dudak
```

### Egzersiz ekranı

```text
Egzersiz 3 / 9

━━━━━━━━━━●━━━━

Dilini dışarı çıkar

[Animation]

Dilini hiçbir yere değdirmeden
dışarı çıkar ve 5 saniye bekle.

        5
      ◯

[ BAŞLA ]
```

Tekrar:

```text
1 / 5
2 / 5
3 / 5
...
5 / 5
```

### TTS

`TTSService`

* Türkçe.
* Başla ile çalışır.
* Kullanıcı kapatabilir.
* Egzersiz adımlarında kullanılabilir.

### Animation

Lottie/SVG asset bulunuyorsa göster.

Asset yoksa **zarif fallback illustration** kullan.

Uygulama animation asset'i eksik diye crash olmamalı.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Test:

* Timer.
* Repetition.
* Exercise completion.
* Skip davranışı.
* XP event.
* TTS disabled.
* Animation fallback.

### Geçiş kriteri

**9 dil + 12 dudak egzersizi gerçek kullanıcı akışıyla tamamlanabiliyor.**

---

# Faz 6 — XP + Yıldız + Streak + Rozetler

**✅ TAMAMLANDI** — İdempotent XpEvent ledger'ı (activityType+sourceId+date ile tekrar XP engelleme), günlük giriş/duygu/egzersiz/7 günlük streak XP ödülleri, gerçek verilerden hesaplanan streak, 10 rozetlik JSON içerik motoru ve kural motoru (all_badges meta-rozeti dahil), rozet açılışında yıldız+konfeti animasyonu (reduced-motion uyumlu); gerçek cihazda adb üzerinden uçtan uca doğrulandı (XP/streak/rozetler force-stop + yeniden açma sonrası korundu). analyze/test (51/51)/debug APK geçti.

**Amaç:** Oyunlaştırmayı ana terapi amacını destekleyecek şekilde eklemek.

### XP

```text
Daily login       10
Emotion            5
Small exercise    20
Full exercise     50
Mini game         30
7-day streak     100
```

### Rozetler

10 rozet JSON'dan gelecek.

```text
First Step
3 Day Streak
7 Day Streak
Sound Explorer
Lip Hero
Game Lover
500 XP
1000 XP
Consistency
NeuroBloom Star
```

### Streak

Günlük kullanım üzerinden hesaplanmalı.

Aşırı kullanım teşvik edilmemeli.

### Başarı animasyonu

* yıldız
* kısa konfeti
* badge unlock

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Özellikle test:

```text
XP calculation
Duplicate XP prevention
Streak calculation
Badge unlock
Badge persistence
```

### Geçiş kriteri

**Uygulama kapatılıp açıldığında XP, rozet ve streak verileri doğru kalıyor.**

---

# Faz 7 — Harf Çarkı

**✅ TAMAMLANDI** — Harf Çarkı: JSON içerikli hece havuzu (MA/BA/PA/TA/DA/NA/SA/LA), döndür → hece + prompt → kaydet/dinle/tekrar kaydet → bitir akışı; AudioService (record + just_audio), mikrofon izni yalnızca KAYDET anında isteniyor, izin reddinde oyun kayıtsız modda oynanabiliyor; kayıt hiçbir zaman kalıcı tutulmuyor (bitirmede ve dispose'da silme). Gerçek cihazda uçtan uca doğrulandı: gerçek Android mikrofon izin diyaloğu, kayıt/dinleme/tekrar kaydetme, +30 XP tamamlama, Ana Sayfa'da XP/streak/"Mini oyun oyna" güncellemesi. QA sırasında bulunan gerçek hata (arka tuşla kayıt ortasında çıkışta dosya silinmiyordu) düzeltildi ve cihazda yeniden doğrulandı — cache boş kalıyor. analyze/test (68/68)/debug APK geçti.

**Amaç:** İlk gerçek mini oyunu tamamlamak.

### Akış

```text
Harf Çarkı

        🎡

      [DÖNDÜR]

          ↓

         MA

"MA sesiyle bir kelime söyle."

[ KAYDET ]

     🎙️

[ DİNLE ]

[ TEKRAR KAYDET ]

```

### İçerik

Örneğin:

```text
MA
BA
PA
SA
LA
...
```

JSON'dan gelecek.

### AudioService

* Microphone permission sadece gerektiğinde.
* Record.
* Playback.
* Re-record.
* Session sonunda sil.

Kalıcı audio storage yok.

### XP

Oyunun tamamlanması → 30 XP.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Manuel:

* Mikrofon izni.
* Kayıt.
* Playback.
* Re-record.
* Uygulamadan çıkış.
* Kayıt silinmesi.

### Geçiş kriteri

**Harf Çarkı tamamen offline çalışıyor ve ses kaydı kalıcı olarak tutulmuyor.**

---

# Faz 8 — İlerleme + Günlük Hedef

**✅ TAMAMLANDI** — İlerleme ekranı: istatistik kartları (Toplam XP, Seri, Egzersiz, Oyun), Bugünkü Görev (Home ile paylaşılan `TodayGoalsCard`), Egzersiz/XP/Duygu geçmişi — tamamı gerçek yerel verilerden hesaplanıyor, mock data yok. Gerçek cihazda uçtan uca doğrulandı: duygu kaydı + egzersiz + oyun tamamlandıktan sonra İlerleme ekranındaki her sayı (65 XP, 1 gün seri, 1 egzersiz, 1 oyun) ve geçmiş listeleri yapılan işlemlerle birebir eşleşiyor. QA sırasında bulunan gerçek hata (istatistik kartlarında "BOTTOM OVERFLOWED BY 10 PIXELS") düzeltildi, telefon genişliğini taklit eden bir regresyon testi eklendi ve cihazda taşma olmadığı doğrulandı. analyze/test (70/70)/debug APK geçti.

**Amaç:** Çocuğun kendi gelişimini görebileceği ekranı tamamlamak.

### Progress

```text
Toplam XP
⭐ 680

Seri
🔥 6 gün

Egzersiz
24

Oyun
12
```

### Geçmiş

```text
Exercise History
XP History
Emotion History
```

### Günlük görev

```text
🌟 Bugünkü Görev

✓ Duygunu seç
✓ Egzersiz yap
○ Mini oyun oyna
```

Görevler tamamlanmadığında ceza yok.

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Geçiş kriteri

**Progress ekranındaki bütün istatistikler gerçek lokal verilerden hesaplanıyor; mock data kullanılmıyor.**

---

# Faz 9 — Ebeveyn Paneli

**✅ TAMAMLANDI** — Ebeveyn PIN'i PBKDF2-HMAC-SHA256 ile tuzlanıp hashleniyor, salt+hash secure storage'da (Hive'dan ayrı) tutuluyor, asla plaintext saklanmıyor; ilk kurulumda oluşturuluyor. Dashboard: Toplam Egzersiz/XP/Streak kartları + 3 gerçek grafik (fl_chart: haftalık aktivite bar chart, duygu dağılımı pie chart, XP ilerlemesi line chart), tamamı gerçek yerel veriden. `/parent/dashboard` rotası router redirect ile korunuyor — doğru PIN olmadan (parentUnlockedProvider) asla açılmıyor, deep-link ile bile. PIN girişi ekran-üstü sayısal tuş takımı ile yapılıyor (OS klavyesine bağımlı değil). QA sırasında bulunan gerçek hata (yanlış PIN sonrası gizli TextField'ın IME bağlantısı bir daha güvenilir şekilde açılmıyordu) kökten çözüldü: gizli TextField yaklaşımı tamamen kaldırılıp ekran-üstü tuş takımıyla değiştirildi; ayrıca bu yeni ekranda bulunan bir overflow hatası da düzeltildi. Gerçek cihazda uçtan uca doğrulandı: PIN oluşturma, doğru PIN, yanlış PIN + hemen ardından doğru PIN ile tekrar deneme, kilitleme. analyze/test (92/92)/debug APK geçti.

**Amaç:** Ebeveynin çocuğun kullanımını güvenli şekilde takip etmesini sağlamak.

### PIN

```text
Parent Area

Enter PIN
● ● ● ●
```

PIN:

* Plaintext tutulmaz.
* Hashlenir.
* İlk kurulumda oluşturulur.

### Dashboard

```text
Toplam Egzersiz
Toplam XP
Streak

Weekly Activity
Emotion History
XP Progress
```

### Grafikler

3 temel grafik:

1. Haftalık aktivite
2. Duygu dağılımı
3. XP ilerlemesi

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Test:

* PIN oluşturma.
* Doğru PIN.
* Yanlış PIN.
* PIN persistence.
* Dashboard hesaplamaları.

### Geçiş kriteri

**Çocuk ekranından ebeveyn paneline doğrudan erişilemiyor; doğru PIN olmadan dashboard açılmıyor.**

---

# Faz 10 — Premium Placeholder

**Amaç:** Gelecekteki Premium mimarisinin UI/feature sınırını hazırlamak.

### İçerik

```text
✨ NeuroBloom Premium

Daha fazla oyun, egzersiz ve
gelişim özelliği yakında!

🎮 Daha fazla oyun
👄 Daha fazla egzersiz
📊 Detaylı gelişim raporları
🎨 Özel avatarlar
👨‍👩‍👧 Gelişmiş ebeveyn özellikleri

🔒 Yakında Kullanıma Açılacak
```

Butonlar disabled.

**Gerçek ödeme sistemi yok.**

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Geçiş kriteri

Premium ekranı çalışıyor fakat hiçbir ödeme/abonelik isteği oluşturmuyor.

---

# Faz 11 — Assistant / NeuroBot MVP

**Amaç:** AI olmadan NeuroBot'un kontrollü versiyonunu eklemek.

### Örnek

```text
🤖 Merhaba!

Bugün birlikte ne yapmak
istersın?

[Egzersiz yapalım]
[Bir oyun oynayalım]
[Nasılsın?]
[İlerlememe bak]
```

Seçime göre predefined cevaplar.

Örneğin:

```text
"Harika! Önce küçük bir
egzersiz yapalım mı?"
```

### Kritik sınır

NeuroBot:

* teşhis koymaz
* klinik değerlendirme yapmaz
* terapi önerisi üretmez
* açık uçlu çocuk sohbetine girmez
* kullanıcının hassas verilerini dış servise göndermez

### Kontroller

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Geçiş kriteri

**Assistant sekmesi tamamen offline ve kontrollü seçeneklerle çalışıyor.**

---

# Faz 12 — Entegrasyon + Güvenlik + QA

Bu fazda yeni feature eklenmemeli.

**Amaç:** Bütün sistemi stabilize etmek.

### Kontroller

```bash
flutter clean
flutter pub get

flutter analyze

flutter test

flutter build apk --release
```

Ardından gerçek Android cihazda:

```text
Fresh install
↓
Onboarding
↓
Profile
↓
Emotion
↓
Exercise
↓
XP
↓
Badge
↓
Game
↓
Progress
↓
Parent
↓
Premium
↓
Assistant
```

test edilmeli.

### Özellikle test edilecek durumlar

* Uygulama internet olmadan açılıyor mu?
* Uygulama kapatılıp açıldığında veri korunuyor mu?
* Bozuk JSON crash yaratıyor mu?
* Eksik animation crash yaratıyor mu?
* TTS kullanılamazsa uygulama çalışıyor mu?
* Mikrofon reddedilirse oyun çalışmaya devam ediyor mu?
* Yanlış PIN'de parent dashboard açılıyor mu?
* Yaş filtresi doğru çalışıyor mu?
* Disabled exercise görünmüyor mu?
* XP iki kez veriliyor mu?
* Streak doğru hesaplanıyor mu?
* Ses kaydı oyun sonunda siliniyor mu?

### Son build

```bash
flutter build apk --release
```

### Geçiş kriteri

**Release APK gerçek Android cihazda baştan sona kullanılabiliyor ve kritik crash/functional bug bulunmuyor.**

---

# Faz 13 — Dokümantasyon ve v0.1 teslimi

Son aşamada:

```text
README.md
ARCHITECTURE.md
ROADMAP.md
CONTRIBUTING.md
ATTRIBUTIONS.md
```

güncellenecek.

README'de özellikle:

```bash
flutter pub get
flutter run
```

ve:

```bash
flutter build apk --release
```

bulunmalı.

Ayrıca:

```text
APK location
Requirements
Flutter version
Android requirements
Offline limitations
Privacy model
Content JSON format
How to add exercise
How to add badge
How to add game
```

açıklanmalı.

---

# Faz geçiş mantığı

Claude Code'a özellikle şu kuralı koyardım:

> **Bir fazın geçiş kriterleri sağlanmadan sonraki faza geçme.**

Örneğin:

```text
IMPLEMENT
   ↓
ANALYZE
   ↓
TEST
   ↓
BUILD
   ↓
VERIFY
   ↓
NEXT PHASE
```

Hata varsa:

```text
ERROR
 ↓
DIAGNOSE
 ↓
FIX
 ↓
ANALYZE
 ↓
TEST
 ↓
BUILD
```

şeklinde ilerlemeli.

## Son mimari akış

```text
                   NeuroBloom
                       │
              ┌────────┴────────┐
              │                 │
          Presentation       Content
              │                 │
          Riverpod           JSON
              │                 │
          Repository       Content Loader
              │                 │
          Services             │
       ┌──────┼──────┐         │
       │      │      │         │
     TTS   Audio  Storage      │
       │      │      │         │
       └──────┴──────┴─────────┘
                       │
              Encrypted Local Data
```

Ve en önemli prensip:

**UI → doğrudan JSON'a, Hive'a, TTS'e veya microphone API'ına bağlanmayacak.**

Bunun yerine:

```text
UI
 ↓
Provider
 ↓
Repository / Service
 ↓
Data source
```

kullanılacak.

Bu planla v0.1'in sonunda yalnızca bir demo değil, **offline çalışan, test edilmiş, APK olarak dağıtılabilen ve v0.2–v0.7 özelliklerine genişletilebilecek gerçek bir temel ürün** elde edilir.
