# ⚠️ تحديث Firebase مطلوب - Firebase Update Required

**تاريخ: 3 ديسمبر 2025**

---

## 🔍 المشكلة المكتشفة

تم اكتشاف عدم تطابق بين البصمات (SHA Fingerprints):

### 📋 البصمة القديمة في Firebase:
```
certificate_hash: 62499eec19c3761df9761467bcbc5936f62625b9
```

### 📋 البصمة الجديدة من Keystore الحالي:
```
SHA-1:   D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34
SHA-256: 34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33
```

---

## ❗ لماذا هذا مهم؟

عدم تطابق البصمات قد يسبب:
- ❌ فشل Firebase Crashlytics في إرسال التقارير
- ❌ مشاكل في المصادقة إذا استخدمت Firebase Auth مستقبلاً
- ❌ فشل Google Sign-In إذا أضفته لاحقاً
- ❌ مشاكل في Firebase Cloud Messaging (الإشعارات)

---

## ✅ الحل: تحديث البصمات في Firebase

### الخطوة 1️⃣: اذهب إلى Firebase Console

```
https://console.firebase.google.com/project/yemen-blood-bank
```

### الخطوة 2️⃣: افتح إعدادات التطبيق

1. من القائمة اليسرى، اضغط على ⚙️ **Settings**
2. اختر **Project settings**
3. اسحب للأسفل إلى قسم **"Your apps"**
4. ابحث عن التطبيق: **com.bagomri.yemenbloodbank**

### الخطوة 3️⃣: أضف البصمات الجديدة

في قسم **"SHA certificate fingerprints"**:

#### أ) أضف SHA-1:
```
D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34
```

**الخطوات:**
1. اضغط **"Add fingerprint"**
2. انسخ والصق SHA-1 أعلاه
3. اضغط **Save**

#### ب) أضف SHA-256:
```
34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33
```

**الخطوات:**
1. اضغط **"Add fingerprint"** مرة أخرى
2. انسخ والصق SHA-256 أعلاه
3. اضغط **Save**

### الخطوة 4️⃣: حمّل google-services.json الجديد

1. في نفس الصفحة، اضغط **"Download google-services.json"**
2. استبدل الملف القديم بالجديد:
   ```
   d:\yemen_blood_bank_app\android\app\google-services.json
   ```

### الخطوة 5️⃣: أعد بناء التطبيق

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🔍 التحقق من التحديث

### 1. افتح google-services.json الجديد:
ابحث عن قسم `oauth_client` → `android_info` → `certificate_hash`

### 2. يجب أن يحتوي على البصمة الجديدة أو بصمات متعددة:
```json
{
  "oauth_client": [
    {
      "android_info": {
        "package_name": "com.bagomri.yemenbloodbank",
        "certificate_hash": "d6cd53f165d06a5ed72e10b6b26edd5b6bd8c134"
      }
    }
  ]
}
```

**ملاحظة:** البصمة في الملف JSON تكون بدون النقطتين (:) وبأحرف صغيرة.

---

## 📌 ملاحظات إضافية

### 1. البصمة القديمة:
- ✅ **لا تحذفها** من Firebase
- ✅ احتفظ بها إذا كانت من keystore سابق
- ✅ Firebase يدعم عدة بصمات للتطبيق الواحد

### 2. عند النشر على Play Store:
عندما تنشر التطبيق على Google Play:
- سيولد Google Play بصمات إضافية (App Signing Key)
- يجب إضافتها أيضاً في Firebase
- سيكون لديك 3-4 بصمات في المجموع:
  * البصمة القديمة (إذا كانت موجودة)
  * البصمة الحالية (Upload Key) ✅
  * بصمات Google Play (App Signing Key) - بعد النشر

### 3. Firebase Crashlytics:
بعد التحديث، سيعمل Crashlytics بشكل صحيح:
- ✅ إرسال تقارير الأخطاء
- ✅ تتبع الأعطال
- ✅ تحليل الأداء

---

## ✅ قائمة التحقق

- [ ] فتحت Firebase Console
- [ ] وجدت التطبيق: com.bagomri.yemenbloodbank
- [ ] أضفت SHA-1: D6:CD:53:F1:65:D0:6A:5E:D7:2E:10:B6:B2:6E:DD:5B:6B:D8:C1:34
- [ ] أضفت SHA-256: 34:48:32:C9:CD:5E:90:D4:42:28:40:63:BA:C3:14:50:F4:8D:C8:77:8D:CE:6F:D5:52:14:4B:D8:FC:96:6F:33
- [ ] حملت google-services.json الجديد
- [ ] استبدلت الملف في android/app/
- [ ] نفذت flutter clean && flutter pub get
- [ ] بنيت التطبيق من جديد

---

## 📞 المساعدة

إذا واجهت أي مشاكل:
1. راجع [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)
2. راجع [SHA_FINGERPRINTS.txt](SHA_FINGERPRINTS.txt)
3. تحقق من وثائق Firebase: https://firebase.google.com/docs

---

## 📊 ملخص سريع

### قبل التحديث:
```
❌ بصمة قديمة في Firebase
❌ قد لا يعمل Crashlytics بشكل صحيح
❌ مشاكل محتملة في المستقبل
```

### بعد التحديث:
```
✅ بصمات محدثة في Firebase
✅ Crashlytics يعمل بشكل صحيح
✅ جاهز للنشر على Play Store
✅ دعم ميزات Firebase المستقبلية
```

---

**⚡ هذا التحديث ضروري قبل نشر التطبيق على Play Store!**

---

**📅 تم الإنشاء**: 3 ديسمبر 2025
**👨‍💻 المطور**: صالح باقمري
**📧 البريد**: s.bagomri@gmail.com

💙 **صُنع بحب لأهالي اليمن**
