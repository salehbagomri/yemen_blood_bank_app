# 📓 مذكّرة تنفيذ — المرحلة 3: جعل reorderBanners عملية ذرّية

> **موجَّهة إلى:** صاحب المشروع (تطبيق SQL على Supabase) + وكيل الكود (تعديل Dart).
> **المخطِّط:** Claude.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 3.

---

## 🎯 المشكلة المؤكَّدة (من الكود الفعلي)

في `lib/services/banner_service.dart`، `reorderBanners` تستخدم حلقة `for` مع `await` متسلسل:
```dart
for (int i = 0; i < bannerIds.length; i++) {
  await _client.from('banners').update({'sort_order': i}).eq('id', bannerIds[i]);
}
```
**مشكلتان:**
1. **N رحلات شبكة متتالية** (بطء يتضاعف مع عدد البانرات).
2. **غير ذرّية:** فشل في المنتصف يترك الترتيب نصف محدَّث ومكسوراً.

**ملاحظة إضافية:** `_moveBanner` في `manage_banners_screen.dart` قد تُستدعى بسرعة متتالية (ضغط أسهم متكرر) ⇒ استدعاءات متزامنة. الحل الذرّي السريع يخفّف هذا.

**الحل:** دالة RPC واحدة `reorder_banners(p_ids UUID[])` تحدّث الكل في معاملة واحدة ذرّية، محصورة بالأدمن.

---

## 🧩 الأنماط المحمية

- الفصل الطبقي: التغيير في Service فقط (لا منطق في Widget). `BannerProvider.reorderBanners` يبقى كما هو (يستدعي الخدمة + يحدّث محلياً).
- التحديث المحلي الفوري في Provider (للاستجابة البصرية) **يبقى** — لا تحذفه.
- لا حزمة جديدة. لا إيموجي في كود Dart.
- اتساق أمني: الدالة محصورة بالأدمن (تتسق مع سياسة `banners_admin_all`).

---

## 📋 المهام

### المهمة 3.1 — إنشاء دالة RPC ذرّية (SQL على Supabase)

أنشئ ملف `docs/sql/phase9_reorder_banners.sql` بهذا المحتوى، وطبّقه على Supabase:

```sql
-- ============================================================================
--  بنك دم اليمن — إعادة ترتيب البانرات ذرّياً (Atomic Banner Reorder)
-- ----------------------------------------------------------------------------
--  يستبدل الحلقة المتسلسلة في banner_service.reorderBanners بمعاملة واحدة.
--  الأمان: محصور بالأدمن (يتسق مع سياسة banners_admin_all).
-- ============================================================================

CREATE OR REPLACE FUNCTION public.reorder_banners(p_ids UUID[])
RETURNS void AS $$
BEGIN
    -- التحقق الأمني: الأدمن فقط
    IF NOT EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) THEN
        RAISE EXCEPTION 'غير مصرح: إعادة ترتيب البانرات للأدمن فقط.';
    END IF;

    -- تحديث ذرّي: sort_order = موضع المعرّف في المصفوفة (يبدأ من 0)
    UPDATE public.banners b
    SET sort_order = arr.ord - 1,          -- WITH ORDINALITY يبدأ من 1
        updated_at = now()
    FROM unnest(p_ids) WITH ORDINALITY AS arr(id, ord)
    WHERE b.id = arr.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.reorder_banners(UUID[]) TO authenticated;
```

**التحقق بعد التطبيق:**
```sql
-- يجب ألا يرمي خطأ (بحساب أدمن)؛ تحقّق من ترتيب صفين تجريبيين ثم أعدهما.
SELECT id, sort_order FROM public.banners ORDER BY sort_order;
```

---

### المهمة 3.2 — تبسيط reorderBanners في banner_service.dart

استبدل جسم الدالة بالكامل:

```dart
/// إعادة ترتيب البانرات دفعة واحدة (ذرّياً عبر RPC)
Future<void> reorderBanners(List<String> bannerIds) async {
  try {
    await _client.rpc(
      'reorder_banners',
      params: {'p_ids': bannerIds},
    );
  } catch (e) {
    throw Exception('فشل إعادة ترتيب البانرات: ${ErrorHandler.getArabicMessage(e)}');
  }
}
```

> استدعاء شبكي واحد بدل الحلقة. ذرّي. الباقي (Provider، الشاشة) دون تغيير.

---

### المهمة 3.3 — (اختياري، تحسين تجربة) منع الاستدعاء المتزامن في الشاشة

في `manage_banners_screen.dart`، `_moveBanner`: أضف حارساً بسيطاً لمنع الضغط المتكرر أثناء عملية جارية (إن لم يكن موجوداً). مثال: تعطيل الأزرار أثناء `provider.isLoading`. **هذا اختياري** — لو كان يضيف تعقيداً، أجّله.

---

## ✅ قائمة التحقق (Definition of Done)

- [ ] دالة `reorder_banners` مُنشأة على Supabase ومحصورة بالأدمن.
- [ ] SQL موثَّق في `docs/sql/phase9_reorder_banners.sql`.
- [ ] `banner_service.reorderBanners` يستدعي RPC واحدة (لا حلقة).
- [ ] `flutter analyze` = 0 أخطاء/تحذيرات.
- [ ] اختبار يدوي: إعادة ترتيب بانرات في شاشة الإدارة تعمل، والترتيب يثبت بعد إعادة فتح الشاشة.
- [ ] اختبار خادمي: استدعاء `reorder_banners` بحساب غير أدمن يُرفض.

---

## 📝 قيد PROJECT_LOG.md المقترح

```
### YYYY-MM-DD — [perf] جعل إعادة ترتيب البانرات عملية ذرّية عبر RPC
- **الوصف:** استبدال حلقة UPDATE المتسلسلة (N رحلات شبكة، غير ذرّية) في
  banner_service.reorderBanners بدالة RPC واحدة reorder_banners(p_ids UUID[])
  تحدّث كل الترتيب في معاملة واحدة عبر unnest WITH ORDINALITY، محصورة بالأدمن.
  استدعاء شبكي واحد بدل N، وذرّية كاملة (تنجح كلها أو تفشل كلها).
- **الملفات:** `docs/sql/phase9_reorder_banners.sql` (جديد), `lib/services/banner_service.dart`
- **السبب/الدافع:** الحلقة المتسلسلة بطيئة وغير ذرّية (فشل في المنتصف يكسر الترتيب).
- **اختبار:** SQL مُطبَّق ومُتحقَّق ✅ / analyze 0/0 ✅ / يدوي: ترتيب يثبت ✅ / رفض غير الأدمن ✅.
- **Commit:** `<hash>`
```

> **صيغة commit:** `perf: make banner reorder atomic via single RPC`

---

## ⚠️ تنبيهات

1. **رتّب التنفيذ:** طبّق SQL على Supabase **أولاً**، ثم عدّل Dart. لو عُدّل Dart قبل وجود الدالة، سيفشل الاستدعاء.
2. **لا تحذف** التحديث المحلي في `BannerProvider.reorderBanners` — هو ما يعطي الاستجابة البصرية الفورية.
3. اختبر بحساب أدمن فعلي على الجهاز بعد التطبيق (ترتيب فعلي + ثبات بعد إعادة الفتح).
4. لو ظهرت أي مشكلة في الاستدعاء (نوع المصفوفة UUID[])، تأكّد أن `bannerIds` قائمة نصوص صحيحة المعرّفات؛ Supabase Dart يمرّرها كـ array.
