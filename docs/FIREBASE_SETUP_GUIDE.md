# 🔥 دليل إعداد Firebase - Firebase Setup Guide

**تاريخ: 3 ديسمبر 2025**

---

## 📋 الخطوات المطلوبة

### 1️⃣ إضافة البصمات في Firebase Console

#### أ. اذهب إلى Firebase Console:
```
https://console.firebase.google.com
```

#### ب. اختر مشروعك أو أنشئ مشروع جديد:
- إذا لم يكن لديك مشروع، اضغط **"Add project"**
- اسم المشروع المقترح: `Yemen Blood Bank`

#### ج. أضف تطبيق Android:

1. من لوحة المشروع، اضغط على أيقونة Android أو **"Add app"**
2. املأ المعلومات:

```
📱 معلومات التطبيق:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Android package name:  com.bagomri.yemenbloodbank
App nickname (اختياري): Yemen Blood Bank
Debug signing SHA-1:   [اتركه فارغاً الآن]
```

3. اضغط **"Register app"**

---

### 2️⃣ إضافة البصمات (SHA Fingerprints)

#### أ. في صفحة إعدادات المشروع:
1. اذهب إلى **Settings** (⚙️ الإعدادات في أعلى اليسار)
2. اختر **"Project settings"**
3. اسحب للأسفل إلى قسم **"Your apps"**
4. اضغط على تطبيق Android الخاص بك

#### ب. أضف البصمات التالية:

```
🔐 SHA-1 Fingerprint:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34
```

```
🔐 SHA-256 Fingerprint:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33
```

#### ج. كيفية الإضافة:
1. ابحث عن قسم **"SHA certificate fingerprints"**
2. اضغط **"Add fingerprint"**
3. انسخ والصق **SHA-1** أولاً، ثم اضغط Save
4. اضغط **"Add fingerprint"** مرة أخرى
5. انسخ والصق **SHA-256**، ثم اضغط Save

---

### 3️⃣ تحميل ملف google-services.json (Android)

#### أ. تحميل الملف:
1. في نفس الصفحة، ستجد زر **"Download google-services.json"**
2. اضغط على الزر لتحميل الملف

#### ب. نقل الملف إلى المشروع:

**📂 المسار الصحيح:**
```
d:\yemen_blood_bank_app\android\app\google-services.json
```

**⚠️ مهم جداً:**
- الملف يجب أن يكون في مجلد `android/app/`
- ليس في `android/` فقط
- ليس في جذر المشروع

#### ج. التحقق من الملف:

افتح ملف `google-services.json` وتأكد من:
```json
{
  "project_info": {
    "project_id": "your-project-id",
    ...
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:...:android:...",
        "android_client_info": {
          "package_name": "com.bagomri.yemenbloodbank"
        }
      },
      ...
    }
  ]
}
```

تأكد أن `package_name` هو: `com.bagomri.yemenbloodbank`

---

### 4️⃣ (اختياري) إضافة تطبيق iOS

إذا كنت تخطط لنشر التطبيق على App Store مستقبلاً:

#### أ. أضف تطبيق iOS:
1. من لوحة المشروع، اضغط أيقونة iOS أو **"Add app"**
2. املأ المعلومات:

```
📱 معلومات التطبيق:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
iOS bundle ID:      com.bagomri.yemenbloodbank
App nickname:       Yemen Blood Bank
App Store ID:       [اتركه فارغاً الآن]
```

#### ب. تحميل ملف GoogleService-Info.plist:
1. اضغط **"Download GoogleService-Info.plist"**
2. ضع الملف في:
```
d:\yemen_blood_bank_app\ios\Runner\GoogleService-Info.plist
```

---

## ✅ قائمة التحقق

### Android:
- [ ] إنشاء/فتح مشروع Firebase
- [ ] إضافة تطبيق Android
- [ ] إضافة SHA-1 fingerprint
- [ ] إضافة SHA-256 fingerprint
- [ ] تحميل google-services.json
- [ ] نقل google-services.json إلى android/app/
- [ ] التحقق من package_name في الملف

### iOS (اختياري):
- [ ] إضافة تطبيق iOS
- [ ] تحميل GoogleService-Info.plist
- [ ] نقل GoogleService-Info.plist إلى ios/Runner/

---

## 🔍 التحقق من التكامل

### اختبار Firebase في التطبيق:

بعد نقل الملفات، قم بتشغيل التطبيق:

```bash
# تنظيف المشروع
flutter clean

# تحميل الحزم
flutter pub get

# بناء وتشغيل
flutter run
```

### التحقق من Crashlytics:

إذا كان Firebase Crashlytics مفعل، يجب أن ترى:
- سجلات في Firebase Console > Crashlytics
- عدم وجود أخطاء في console عند تشغيل التطبيق

---

## 📋 البصمات المستخدمة (للرجوع إليها)

### معلومات Keystore:
```
Keystore File:    android/keystore/mahrah-release-key.jks
Key Alias:        upload
Password:         Saleh@770727055
```

### البصمات (من KEYSTORE_INFO.txt):

**SHA-1:**
```
D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34
```

**SHA-256:**
```
34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33
```

---

## 🚨 ملاحظات مهمة

### 1. Google Play App Signing:

⚠️ **مهم جداً:**
عند رفع التطبيق على Google Play Store لأول مرة:
- Google Play سيطلب منك استخدام **"App Signing by Google Play"**
- سيقوم Google بإنشاء بصمات جديدة (Play Store fingerprints)
- ستحتاج إضافة البصمات الجديدة أيضاً في Firebase

**الخطوات:**
1. ارفع APK/AAB على Play Console
2. سجل في App Signing
3. انتقل إلى: **Release > Setup > App signing**
4. انسخ **SHA-1** و **SHA-256** من Play Console
5. أضفهم في Firebase (بالإضافة للبصمات الحالية)

**النتيجة:**
سيكون لديك **4 بصمات** في Firebase:
- ✅ SHA-1 من keystore المحلي (Upload key)
- ✅ SHA-256 من keystore المحلي (Upload key)
- ✅ SHA-1 من Google Play (App signing key)
- ✅ SHA-256 من Google Play (App signing key)

### 2. ملف .gitignore:

تأكد أن ملف `.gitignore` يحتوي على:
```gitignore
# Firebase
**/google-services.json
**/GoogleService-Info.plist
```

هذه الملفات **محمية بالفعل** في .gitignore الخاص بمشروعك ✅

### 3. الاختبار:

بعد إضافة الملفات:
1. قم بعمل `flutter clean`
2. أعد بناء التطبيق
3. تأكد من عدم وجود أخطاء Firebase
4. اختبر الميزات المعتمدة على Firebase (مثل Crashlytics)

---

## 🔧 استكشاف الأخطاء

### خطأ: "google-services.json is missing"

**الحل:**
- تأكد أن الملف في: `android/app/google-services.json`
- تأكد أن اسم الملف صحيح (بدون مسافات أو أحرف إضافية)

### خطأ: "Default FirebaseApp is not initialized"

**الحل:**
- تأكد من تشغيل `flutter clean && flutter pub get`
- تأكد أن package_name في google-services.json مطابق للـ applicationId

### خطأ: "SHA certificate fingerprints are invalid"

**الحل:**
- تأكد من نسخ البصمات كاملة بدون مسافات
- تأكد من استخدام البصمات من KEYSTORE_INFO.txt

---

## 📞 المساعدة

إذا واجهت أي مشاكل:
1. راجع هذا الدليل
2. راجع KEYSTORE_INFO.txt للبصمات
3. راجع وثائق Firebase: https://firebase.google.com/docs

---

## ✅ الخلاصة

بعد اتباع هذه الخطوات، سيكون لديك:
- ✅ Firebase مُعد بشكل صحيح
- ✅ البصمات مضافة للتطبيق
- ✅ ملف google-services.json في مكانه الصحيح
- ✅ التطبيق جاهز للنشر على Play Store

---

**📅 تم الإنشاء**: 3 ديسمبر 2025
**👨‍💻 المطور**: صالح باقمري
**📧 البريد**: s.bagomri@gmail.com

💙 **صُنع بحب لأهالي اليمن**
