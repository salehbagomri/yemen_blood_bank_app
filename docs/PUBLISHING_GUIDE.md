# 📱 دليل النشر على Play Store - Publishing Guide

**تاريخ: 3 ديسمبر 2025**
**الإصدار: 2.0.0**
**اسم التطبيق: بنك دم اليمن - Yemen Blood Bank**

---

## 📋 جدول المحتويات

1. [الملفات الجاهزة](#الملفات-الجاهزة)
2. [خطوات النشر](#خطوات-النشر)
3. [المعلومات المطلوبة](#المعلومات-المطلوبة)
4. [لقطات الشاشة المطلوبة](#لقطات-الشاشة-المطلوبة)
5. [الإعدادات الموصى بها](#الإعدادات-الموصى-بها)
6. [بعد النشر](#بعد-النشر)

---

## ✅ الملفات الجاهزة

### 1. ملف APK
**الموقع:**
```
d:\yemen_blood_bank_app\build\app\outputs\flutter-apk\app-release.apk
```
**الحجم:** ~65.4 MB
**الحالة:** ✅ جاهز للنشر

**ملاحظة:** إذا كنت بحاجة لـ App Bundle، استخدم الأمر:
```bash
flutter build appbundle --release
```
**الموقع المتوقع:**
```
d:\yemen_blood_bank_app\build\app\outputs\bundle\release\app-release.aab
```

### 2. ملفات التوقيع
**Keystore:** `android/keystore/mahrah-release-key.jks`
**الخصائص:** `android/key.properties`

**SHA Fingerprints (محدّثة):**
- SHA-1: `D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34`
- SHA-256: `34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33`

### 3. Firebase Configuration
**الملف:** `android/app/google-services.json`
**الحالة:** ✅ محدّث بالبصمات الجديدة

---

## 🚀 خطوات النشر

### الخطوة 1️⃣: إنشاء حساب Google Play Console

1. اذهب إلى: https://play.google.com/console/
2. سجّل الدخول بحساب Google
3. قم بالتسجيل كمطور ($25 رسوم لمرة واحدة)

### الخطوة 2️⃣: إنشاء تطبيق جديد

1. اضغط **"Create app"** أو **"إنشاء تطبيق"**
2. املأ المعلومات:
   - **اسم التطبيق:** بنك دم اليمن
   - **اللغة الافتراضية:** العربية (ar)
   - **نوع التطبيق:** App
   - **مجاني أم مدفوع:** Free

### الخطوة 3️⃣: إكمال إعدادات التطبيق

#### أ) تصنيف المحتوى (Content Rating)
1. اذهب إلى **Policy** → **App Content**
2. املأ استبيان التصنيف:
   - فئة التطبيق: **Medical** (طبي)
   - لا يحتوي على عنف
   - لا يحتوي على محتوى جنسي
   - لا يحتوي على مخدرات
   - مناسب لجميع الأعمار 18+

#### ب) سياسة الخصوصية (Privacy Policy)
1. اذهب إلى **Policy** → **Privacy Policy**
2. أدخل رابط السياسة:
   ```
   https://salehbagomri.github.io/yemen-blood-bank-privacy/
   ```

#### ج) فئة التطبيق (App Category)
- **الفئة الرئيسية:** Medical
- **الفئة الفرعية:** Health & Fitness

#### د) معلومات الاتصال (Contact Details)
- **البريد الإلكتروني:** s.bagomri@gmail.com
- **الموقع الإلكتروني:** https://www.bagomri.com
- **الهاتف:** +967 735 325 614

### الخطوة 4️⃣: تجهيز صفحة المتجر (Store Listing)

#### 1. الوصف القصير (Short Description)
**الحد الأقصى: 80 حرف**

```
تطبيق ينقذ الأرواح - ربط متبرعي الدم بالمحتاجين في اليمن، اليمن
```

#### 2. الوصف الكامل (Full Description)
**الحد الأقصى: 4000 حرف**

استخدم الوصف من ملف `PLAY_STORE_DESCRIPTION.md` (القسم العربي).

#### 3. الأيقونة (App Icon)
**المتطلبات:**
- الحجم: 512 × 512 بكسل
- التنسيق: PNG (32-bit)
- **الملف:** `assets/icons/icon.png`

#### 4. Feature Graphic
**المتطلبات:**
- الحجم: 1024 × 500 بكسل
- التنسيق: PNG أو JPG
- **محتوى مقترح:**
  - شعار التطبيق
  - اسم التطبيق بالعربي والإنجليزي
  - شعار "معاً ننقذ الأرواح"
  - خلفية بألوان التطبيق (الأحمر المتدرج)

### الخطوة 5️⃣: لقطات الشاشة

راجع القسم [لقطات الشاشة المطلوبة](#لقطات-الشاشة-المطلوبة) أدناه.

### الخطوة 6️⃣: رفع ملف APK/AAB

1. اذهب إلى **Production** → **Create new release**
2. اختر **Upload APK/AAB**
3. ارفع الملف: `app-release.apk` أو `app-release.aab`
4. أضف ملاحظات الإصدار (Release Notes):

**بالعربية:**
```
الإصدار 2.0.0 - تحديث شامل

✨ الميزات الجديدة:
• نظام بلاغات محسّن للإبلاغ عن المتبرعين المخالفين
• بطاقات متبرعين محسّنة للأدمن مع 10 إجراءات متقدمة
• قائمة إعدادات جديدة: حول التطبيق، تواصل معنا، قيّم التطبيق
• شعار جديد للتطبيق (SVG)
• تكامل Firebase Crashlytics لتتبع الأخطاء

🔧 التحسينات:
• تحسين واجهة المستخدم
• تحسين الأداء
• إصلاح الأخطاء

💙 معاً ننقذ الأرواح في اليمن
```

**بالإنجليزية:**
```
Version 2.0.0 - Major Update

✨ New Features:
• Enhanced reporting system for inappropriate donors
• Improved donor cards for admin with 10 advanced actions
• New settings menu: About, Contact, Rate App
• New app logo (SVG)
• Firebase Crashlytics integration

🔧 Improvements:
• UI enhancements
• Performance improvements
• Bug fixes

💙 Together We Save Lives in Yemen
```

### الخطوة 7️⃣: المراجعة والنشر

1. راجع جميع المعلومات
2. اضغط **"Review release"**
3. اضغط **"Start rollout to Production"**
4. انتظر مراجعة Google (قد تستغرق من ساعات إلى عدة أيام)

---

## 📸 لقطات الشاشة المطلوبة

**المتطلبات:**
- **العدد:** على الأقل 2، موصى به 8
- **الحجم:** الحد الأدنى 320 بكسل، الحد الأقصى 3840 بكسل
- **التنسيق:** PNG أو JPG (24-bit)
- **النسبة:** 16:9 أو 9:16

**لقطات الشاشة الموصى بها (7 صور):**

### 1. الشاشة الرئيسية
**المحتوى:**
- الإحصائيات الرئيسية
- الأزرار الرئيسية (البحث، التبرع، التوعية، البلاغات)
- شريط التطبيق مع الشعار

**كيفية التقاطها:**
1. شغّل التطبيق على جهاز Android أو Emulator
2. اذهب للشاشة الرئيسية
3. التقط screenshot

### 2. البحث عن متبرعين
**المحتوى:**
- شاشة البحث مع الفلاتر
- اختيار فصيلة الدم
- اختيار المديرية

### 3. نتائج البحث
**المحتوى:**
- قائمة المتبرعين
- بطاقات المتبرعين
- معلومات مختصرة

### 4. تفاصيل المتبرع
**المحتوى:**
- معلومات كاملة للمتبرع
- أزرار الاتصال (هاتف، واتساب)
- حالة التوفر

### 5. إضافة متبرع
**المحتوى:**
- نموذج التسجيل
- الحقول المطلوبة

### 6. قسم التوعية
**المحتوى:**
- معلومات عن التبرع بالدم
- الفوائد والشروط

### 7. لوحة الإحصائيات (للأدمن)
**المحتوى:**
- الرسوم البيانية
- توزيع المتبرعين

**أدوات لالتقاط Screenshots:**
- Android Emulator في Android Studio
- جهاز Android حقيقي (F11 + Power على معظم الأجهزة)
- أداة `scrcpy` للتحكم بالجهاز من الكمبيوتر

---

## ⚙️ الإعدادات الموصى بها

### 1. الدول المستهدفة
**الأولوية:**
- 🇾🇪 اليمن (Yemen)

**اختياري:**
- متاح عالمياً

### 2. السعر
- **مجاني** (Free)
- لا يحتوي على إعلانات
- لا يحتوي على عمليات شراء داخل التطبيق

### 3. الفئة العمرية
- **18+ سنة**
- المحتوى طبي مناسب للبالغين

### 4. الأذونات (Permissions)
التطبيق يطلب الأذونات التالية:
- **INTERNET** - للاتصال بقاعدة البيانات
- **URL_LAUNCHER** - لفتح المكالمات وواتساب
- لا توجد أذونات حساسة إضافية

### 5. إعدادات Google Play
- ✅ تفعيل App Signing بواسطة Google Play
- ✅ تفعيل Pre-launch Report
- ✅ تفعيل Internal Testing قبل Production

---

## 🔧 إعدادات Firebase بعد النشر

عندما تنشر التطبيق على Google Play:

### 1. احصل على App Signing Key Fingerprints
1. اذهب إلى Play Console → **Setup** → **App Signing**
2. ستجد **App signing key certificate**
3. انسخ SHA-1 و SHA-256

### 2. أضف البصمات في Firebase
1. اذهب إلى Firebase Console
2. افتح مشروع `yemen-blood-bank`
3. اذهب إلى **Project Settings** → **Your apps**
4. اضغط **Add fingerprint**
5. أضف البصمات الجديدة من Play Console

### 3. حمّل google-services.json الجديد
1. من Firebase Console، اضغط **Download google-services.json**
2. استبدل الملف في `android/app/google-services.json`
3. أعد بناء التطبيق للإصدار التالي

---

## 📊 بعد النشر

### 1. مراقبة الأداء
- **Play Console Dashboard** - عدد التحميلات، التقييمات
- **Firebase Crashlytics** - تتبع الأخطاء
- **User Reviews** - التعليقات والتقييمات

### 2. التحديثات المستقبلية
عند إصدار تحديث جديد:

1. قم بزيادة `versionCode` و `versionName` في `build.gradle.kts`:
   ```kotlin
   versionCode = 3
   versionName = "2.1.0"
   ```

2. قم ببناء APK/AAB جديد:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

3. ارفع على Play Console كـ **New Release**

### 3. الرد على المراجعات
- رد على تعليقات المستخدمين
- اشكر المستخدمين الإيجابيين
- حل مشاكل المستخدمين السلبيين

### 4. الترويج
- شارك رابط التطبيق على وسائل التواصل
- اطلب من المستخدمين التقييم
- **رابط التطبيق:**
  ```
  https://play.google.com/store/apps/details?id=com.bagomri.yemenbloodbank
  ```

---

## 📞 الدعم

### المطور
**الاسم:** صالح باقمري (Saleh Bagomri)
**البريد:** s.bagomri@gmail.com
**الموقع:** https://www.bagomri.com
**واتساب:** +967 735 325 614

### الملفات المرجعية
- **وصف المتجر:** `PLAY_STORE_DESCRIPTION.md`
- **سياسة الخصوصية:** `PRIVACY_POLICY.md`
- **Firebase:** `FIREBASE_SETUP_GUIDE.md`
- **Keystore:** `android/keystore/README.md`
- **SHA Fingerprints:** `SHA_FINGERPRINTS.txt`

---

## ✅ قائمة التحقق النهائية

قبل النشر، تأكد من:

- [ ] APK/AAB تم بناؤه بنجاح
- [ ] تم اختبار التطبيق على جهاز حقيقي
- [ ] جميع الميزات تعمل بشكل صحيح
- [ ] لا توجد أخطاء واضحة
- [ ] سياسة الخصوصية منشورة ومتاحة
- [ ] Firebase SHA fingerprints محدّثة
- [ ] google-services.json محدّث
- [ ] تم تحضير 7 لقطات شاشة
- [ ] تم تحضير Feature Graphic (1024x500)
- [ ] تم تحضير أيقونة التطبيق (512x512)
- [ ] الوصف الكامل جاهز (عربي وإنجليزي)
- [ ] معلومات الاتصال صحيحة
- [ ] تم إكمال تصنيف المحتوى

---

## 🎯 الخطوات التالية

بعد النشر الناجح:

1. **مراقبة الأداء** في أول 24 ساعة
2. **الرد على التعليقات** بشكل سريع
3. **جمع الملاحظات** من المستخدمين
4. **التخطيط للتحديث القادم** بناءً على الملاحظات
5. **الترويج للتطبيق** في المجتمع المحلي

---

**🎉 مبروك مقدماً على نشر التطبيق!**

💙 **معاً ننقذ الأرواح في اليمن**

---

**📅 تم الإنشاء:** 3 ديسمبر 2025
**👨‍💻 المطور:** صالح باقمري
**📧 البريد:** s.bagomri@gmail.com

---

## 📝 ملاحظات إضافية

### حول App Bundle vs APK

**App Bundle (AAB) - موصى به:**
- حجم أصغر للمستخدمين النهائيين
- Google Play يقوم بإنشاء APKs محسّنة لكل جهاز
- مطلوب للتطبيقات الجديدة بعد أغسطس 2021

**APK - مقبول:**
- يمكن تثبيته مباشرة على الأجهزة
- أسهل للاختبار
- حجم أكبر

**ملاحظة:** إذا واجهت مشكلة في بناء AAB (كما حدث)، يمكنك استخدام APK مؤقتاً، ولكن يفضل حل المشكلة للإصدارات القادمة.

### حل مشكلة App Bundle

المشكلة الحالية:
```
Invalid dex file indices, expecting file 'classes?.dex' but found 'classes2.dex'.
```

**حلول مقترحة للإصدارات القادمة:**

1. **تحديث Gradle:**
   ```bash
   cd android
   ./gradlew wrapper --gradle-version=8.12
   ```

2. **تنظيف شامل:**
   ```bash
   flutter clean
   cd android && ./gradlew clean && cd ..
   rm -rf build
   flutter pub get
   flutter build appbundle --release
   ```

3. **تعطيل R8/ProGuard مؤقتاً:**
   في `build.gradle.kts`:
   ```kotlin
   buildTypes {
       release {
           isMinifyEnabled = false
           isShrinkResources = false
       }
   }
   ```

4. **إعادة تشغيل الكمبيوتر:**
   أحياناً مشكلة Kotlin daemon تحل بإعادة التشغيل.

---

💙 **صُنع بحب لأهالي اليمن**
