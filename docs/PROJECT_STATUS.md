# 📊 حالة المشروع — بنك دم اليمن

> **المصدر الحيّ الوحيد لحالة المشروع.** يُحدَّث بعد كل تغيير جوهري.
> الإصدار: انظر pubspec.yaml (مصدر الحقيقة). آخر تحديث: 2026-06-06.

## الحالة الحالية
- التطبيق: قيد التطوير (غير منشور على Google Play بعد).
- جودة الكود: flutter analyze = 0 issues. flutter test = 198 اختبار، 0 فشل. تغطية 76.39% (منطق النماذج/الـ utils).
- النطاق: وطني (22 محافظة، 161 مديرية).
- المنصات: Android, iOS.

## ما أُنجز في مراجعة الجودة (2026-06-03 إلى 2026-06-06)
- تأمين بيانات التوقيع (keystore جديد v2، إبطال القديم).
- تدقيق RLS باختبار اختراق فعلي (طبقة الكتابة محكمة).
- توحيد مصدر الإصدار (pubspec + قراءة ديناميكية).
- reorderBanners ذرّية عبر RPC.
- معالجة 12 BuildContext async gap.
- تنظيف analyze إلى صفر تام.
- إصلاح الاختبارات المهجورة + توسيع التغطية (198 اختبار).
- حذف MainActivity الشبح من مسار حزمة قديم.

## القيود المعروفة (Known Limitations) — بصراحة
- مفتاح Supabase anon علني في الكود (مقبول بطبيعته — الحماية على RLS؛ يُنظّف خارج الكود قبل النشر — المرحلة 8.5 المؤجَّلة).
- Rate limiting ضد السحب الجماعي للقراءة: غير مفعّل بعد (يمكن تفعيله عند الحاجة عبر Cloudflare Worker).
- حماية تعديل المتبرع قائمة على ملكية الصف (added_by) لا المحافظة (آمن؛ قد يكون مقيّداً وظيفياً — قرار مفتوح).
- التغطية 76.39% للمنطق القابل للاختبار وحدوياً؛ شاشات UI والخدمات الشبكية غير مغطّاة (تحتاج integration tests).
- بناء AAB: تم التحقق منه بنجاح وهو يعمل (تجاوز مشكلة dex file indices).
- متطلبات Firebase قبل النشر:
  * تحديث بصمات SHA في Firebase Console بإضافة بصمة keystore v2 النشطة (SHA-1: EC:E5:A7:FE:29:4F:E1:CA:C8:1E:0D:20:03:CB:D4:5D:99:86:1A:94، SHA-256: 84:14:9A:00:58:89:26:C6:5D:B1:22:33:3F:71:EF:ED:65:E4:EA:FA:72:69:64:2A:7C:15:DB:D0:5B:65:D5:55).
  * بعد رفع التطبيق على Google Play، يجب إضافة بصمة App Signing من Play Console إلى Firebase Console.
  * تنزيل google-services.json المحدّث واستبداله في المشروع.
- خطة طوارئ حجب Supabase في اليمن: تم إزالة كود Cloudflare Worker الميت. في حال عودة الحجب، يمكن إنشاء Worker كـ Reverse Proxy وتمرير عنوانه للتطبيق عبر `--dart-define=SUPABASE_URL=<worker_url>` دون تعديل أي كود (راجع التفاصيل في yemen_blood_bank_handoff.md).


## بيانات التوقيع
- keystore النافذ: yemen-release-key-v2.jks (غير مرفوع). بصمته موثّقة في yemen_blood_bank_handoff.md.
- ⚠️ أي بصمة في ملفات الأرشيف قديمة (keystore محروق) — لا تُعتمد.

## معلومات التطبيق
| المعلومة | القيمة |
|---------|--------|
| Package | com.bagomri.yemenbloodbank |
| الإصدار | انظر pubspec.yaml |
| الهدف | Android 5.0+ (API 21) |
| اللغة | العربية (RTL) |

## المراجع الحيّة
- CLAUDE.md — تعليمات الوكلاء والأنماط المحمية
- PROJECT_LOG.md — السجل الزمني
- yemen_blood_bank_handoff.md — البنية وSchema وRLS
- docs/quality-refinement/QUALITY_REFINEMENT_PLAN.md — خطة المراجعة
