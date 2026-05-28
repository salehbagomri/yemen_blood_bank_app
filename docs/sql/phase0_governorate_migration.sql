-- ============================================================================
--  بنك دم اليمن — المرحلة 0: أساس البنية الجغرافية الوطنية
--  Phase 0: Governorate column + indexing + RPC + (draft) RLS
-- ----------------------------------------------------------------------------
--  المرجع: docs/DEVELOPMENT_PLAN.md
--  ⚠️ شغّل هذا على Supabase SQL Editor. القسم (أ) آمن وإضافي (idempotent).
--     القسم (ب) RLS = مسودة — راجع السياسات الحالية قبل تطبيقه (انظر التحذير).
--  ملاحظة معمارية مؤكدة من الكود:
--    - hospitals.id = auth.users.id (صف المستشفى مُعرَّف بمعرّف حساب المستخدم)
--    - يوجد دالتا is_admin() و is_hospital() مساعدتان (لتفادي RLS recursion)
--    - البحث العام للمستخدم بلا تسجيل دخول يعمل عبر RPC من نوع SECURITY DEFINER
--      (يتجاوز RLS) — لذا تقييد المستشفى لا يكسر البحث العام.
-- ============================================================================


-- ============================================================================
--  القسم (أ): تغييرات آمنة وإضافية — جاهزة للتشغيل
-- ============================================================================

-- 0.1 — إضافة عمود المحافظة المستقل إلى الجدولين
ALTER TABLE public.donors    ADD COLUMN IF NOT EXISTS governorate TEXT;
ALTER TABLE public.hospitals ADD COLUMN IF NOT EXISTS governorate TEXT;

-- 0.2 — Backfill: اشتقاق المحافظة من حقل district المدمج "محافظة - مديرية"
--       split_part يُرجع الجزء قبل " - "، وإن لم توجد مديرية يُرجع القيمة كاملة.
UPDATE public.donors
SET governorate = split_part(district, ' - ', 1)
WHERE governorate IS NULL AND district IS NOT NULL;

UPDATE public.hospitals
SET governorate = split_part(district, ' - ', 1)
WHERE governorate IS NULL AND district IS NOT NULL;

-- 0.3 — الفهارس لتسريع البحث والإحصائيات على مستوى 22 محافظة وآلاف السجلات
CREATE INDEX IF NOT EXISTS idx_donors_gov        ON public.donors(governorate);
CREATE INDEX IF NOT EXISTS idx_donors_gov_blood  ON public.donors(governorate, blood_type);
CREATE INDEX IF NOT EXISTS idx_hospitals_gov     ON public.hospitals(governorate);

-- 0.4 — تحديث دالة البحث لإضافة فلترة المحافظة بالعمود المفهرس
--       (نحذف التوقيع القديم أولاً لأن CREATE OR REPLACE لا يضيف معاملاً جديداً بأمان)
DROP FUNCTION IF EXISTS public.search_donors(TEXT, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION public.search_donors(
    p_blood_type     TEXT,
    p_district       TEXT,
    p_available_only BOOLEAN,
    p_governorate    TEXT DEFAULT NULL   -- جديد: اختياري للتوافق العكسي
)
RETURNS SETOF public.donors AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.donors
    WHERE is_active = true
      AND (p_blood_type  IS NULL OR blood_type  = p_blood_type)
      -- فلترة المحافظة عبر العمود المفهرس (أسرع من LIKE)
      AND (p_governorate IS NULL OR governorate = p_governorate)
      -- إبقاء سلوك المديرية القديم: مطابقة تامة أو بادئة "محافظة - %"
      AND (p_district    IS NULL OR district = p_district OR district LIKE p_district || ' - %')
      AND (NOT p_available_only OR (suspended_until IS NULL OR suspended_until < now()));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 0.5 — دالة إحصائيات خادمية (GROUP BY) بدل جلب كل المتبرعين للعدّ في الجهاز
--       p_governorate = NULL  → كل المحافظات (للأدمن)
--       p_governorate = 'X'   → محافظة واحدة (للمستشفى)
CREATE OR REPLACE FUNCTION public.get_governorate_stats(
    p_governorate TEXT DEFAULT NULL
)
RETURNS TABLE (
    governorate TEXT,
    total       BIGINT,
    available   BIGINT,
    suspended   BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.governorate,
        COUNT(*)::BIGINT AS total,
        COUNT(*) FILTER (
            WHERE d.suspended_until IS NULL OR d.suspended_until < now()
        )::BIGINT AS available,
        COUNT(*) FILTER (
            WHERE d.suspended_until IS NOT NULL AND d.suspended_until >= now()
        )::BIGINT AS suspended
    FROM public.donors d
    WHERE d.is_active = true
      AND (p_governorate IS NULL OR d.governorate = p_governorate)
    GROUP BY d.governorate
    ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- (اختياري للأداء لاحقاً) جعل governorate غير قابل للـ NULL بعد التأكد من اكتمال الـ backfill:
-- ALTER TABLE public.donors    ALTER COLUMN governorate SET NOT NULL;
-- ALTER TABLE public.hospitals ALTER COLUMN governorate SET NOT NULL;


-- ============================================================================
--  القسم (ب): RLS لتقييد المستشفى بمحافظتها — ⚠️ مسودة، لا تشغّلها أعمى
-- ----------------------------------------------------------------------------
--  لماذا التحذير: يوجد ملف سابق fix_rls_policies.sql يحوي سياسات حالية تجعل
--  التطبيق يعمل (بما فيه: البحث العام بلا تسجيل، وإضافة متبرع بلا حساب عبر anon).
--  تطبيق سياسات جديدة دون مراجعة الموجود قد يكسر:
--    1) إدراج متبرع من مستخدم غير مسجّل (anon INSERT).
--    2) قراءة الأدمن للكل.
--  الخطوة الصحيحة (بعد منح الوصول المباشر): تشغيل التشخيص أدناه أولاً، ثم
--  تعديل/إضافة السياسات بما يتسق مع الموجود — لا حذفها عشوائياً.
-- ----------------------------------------------------------------------------

-- (ب.0) تشخيص: اعرض السياسات الحالية قبل أي تعديل
-- SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check
-- FROM pg_policies WHERE tablename IN ('donors','hospitals','admins')
-- ORDER BY tablename, policyname;

-- (ب.1) دالة مساعدة: محافظة حساب المستشفى الحالي (STABLE + SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.current_hospital_governorate()
RETURNS TEXT AS $$
    SELECT governorate FROM public.hospitals WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- (ب.2) سياسات مقترحة على donors (طبّقها بعد التشخيص ومواءمتها مع الموجود):
--   الأدمن: كل الصفوف.  المستشفى: صفوف محافظتها فقط.  anon: إدراج عام (يبقى كما هو).
--
-- ALTER TABLE public.donors ENABLE ROW LEVEL SECURITY;
--
-- -- قراءة: أدمن كل شيء، مستشفى محافظتها
-- CREATE POLICY donors_select_scoped ON public.donors
--   FOR SELECT TO authenticated
--   USING ( public.is_admin()
--           OR (public.is_hospital() AND governorate = public.current_hospital_governorate()) );
--
-- -- تعديل: نفس النطاق
-- CREATE POLICY donors_update_scoped ON public.donors
--   FOR UPDATE TO authenticated
--   USING ( public.is_admin()
--           OR (public.is_hospital() AND governorate = public.current_hospital_governorate()) );
--
-- -- إدراج من حساب مستشفى: ضمن محافظتها فقط (إدراج anon العام يُترك بسياسته الحالية)
-- CREATE POLICY donors_insert_hospital ON public.donors
--   FOR INSERT TO authenticated
--   WITH CHECK ( public.is_admin()
--                OR (public.is_hospital() AND governorate = public.current_hospital_governorate()) );

-- ============================================================================
--  التحقق بعد التشغيل (القسم أ):
--    SELECT count(*) FILTER (WHERE governorate IS NULL) AS missing FROM public.donors;   -- يجب 0
--    EXPLAIN ANALYZE SELECT * FROM public.search_donors('O+', NULL, false, 'حضرموت');     -- يستخدم idx_donors_gov_blood
--    SELECT * FROM public.get_governorate_stats(NULL);                                     -- صف لكل محافظة
-- ============================================================================
