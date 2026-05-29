-- ============================================================================
--  بنك دم اليمن — المرحلة 6: إدارة المناطق المفعّلة (Admin-Managed Locations)
-- ----------------------------------------------------------------------------
--  المرجع: docs/DEVELOPMENT_PLAN... (انظر PROJECT_LOG). يُنفَّذ عبر Management API.
--  الهدف: نقل المحافظات/المديريات إلى قاعدة البيانات ليتحكم بها الأدمن
--         (تفعيل/إيقاف للمحافظات؛ إضافة/تفعيل/تعديل-مقيَّد للمديريات).
--  ⚠️ التعديل/الحذف لمديرية مستخدمة ممنوع (يكسر حقل donors.district المخزَّن).
-- ============================================================================

-- 1) الجداول
CREATE TABLE IF NOT EXISTS public.governorates (
  name       TEXT PRIMARY KEY,
  is_active  BOOLEAN NOT NULL DEFAULT true,
  sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.districts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  governorate TEXT NOT NULL REFERENCES public.governorates(name) ON UPDATE CASCADE,
  name        TEXT NOT NULL,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  UNIQUE (governorate, name)
);
CREATE INDEX IF NOT EXISTS idx_districts_gov ON public.districts(governorate);

-- 2) Seed المحافظات (بترتيب AppStrings.districts)
INSERT INTO public.governorates (name, sort_order) VALUES
  ('أمانة العاصمة',1),('عدن',2),('تعز',3),('حضرموت',4),('الحديدة',5),('إب',6),
  ('لحج',7),('أبين',8),('شبوة',9),('مأرب',10),('المهرة',11),('البيضاء',12),
  ('الضالع',13),('الجوف',14),('حجة',15),('عمران',16),('صعدة',17),('ذمار',18),
  ('المحويت',19),('ريمة',20),('أرخبيل سقطرى',21),('صنعاء',22)
ON CONFLICT (name) DO NOTHING;

-- 3) Seed المديريات (من AppStrings.governorateDistricts)
INSERT INTO public.districts (governorate, name)
SELECT g, d FROM (
  SELECT 'أمانة العاصمة' AS g, unnest(ARRAY['السبعين','شعوب','معين','التحرير','الثورة','الصافية','صنعاء القديمة','الوحدة','آزال','بني الحارث']) AS d
  UNION ALL SELECT 'عدن', unnest(ARRAY['صيرة (كريتر)','التواهي','المعلا','خور مكسر','الشيخ عثمان','المنصورة','دار سعد','البريقة'])
  UNION ALL SELECT 'تعز', unnest(ARRAY['القاهرة','المظفر','صالة','التعزية','شرعب السلام','شرعب الرونة','المخا','التربة','المواسط','خدير','ماوية','المعافر','حيفان'])
  UNION ALL SELECT 'حضرموت', unnest(ARRAY['المكلا','سيئون','الشحر','تريم','شبام','القطن','غيل باوزير','دوعن','غيل بن يمين','الريدة وقصيعر'])
  UNION ALL SELECT 'الحديدة', unnest(ARRAY['الحوك','الميناء','الحالي','باجل','بيت الفقية','زبيد','الجراحي','الخوخة','حيس','الدريهمي','المرواعة'])
  UNION ALL SELECT 'إب', unnest(ARRAY['المشنة','الظهار','ذي السفال','السياني','جبلة','حبيش','بعدان','يريم','السدة','النادرة','العدين','حزم العدين'])
  UNION ALL SELECT 'لحج', unnest(ARRAY['الحوطة','تبن','يافع (لبعوس)','ردفان','طور الباحة','القبيطة','المقاطرة','الملاح'])
  UNION ALL SELECT 'أبين', unnest(ARRAY['زنجبار','خنفر (جعار)','لودر','مودية','المحفد','أحور','رصد'])
  UNION ALL SELECT 'شبوة', unnest(ARRAY['عتق','بيحان','عسيلان','نصاب','حبان','ميفعة','الروضة','رضوم'])
  UNION ALL SELECT 'مأرب', unnest(ARRAY['المدينة','مأرب','صرواح','حريب','الجوبة','مجزر'])
  UNION ALL SELECT 'المهرة', unnest(ARRAY['الغيضة','حوف','شحن','قشن','سيحوت','المسيلة','حصوين','منعر','حات'])
  UNION ALL SELECT 'البيضاء', unnest(ARRAY['البيضاء','رداع','مكيراس','السوادية','الزاهر'])
  UNION ALL SELECT 'الضالع', unnest(ARRAY['الضالع','قعطبة','دمت','جبن','الحشاء','الشعيب'])
  UNION ALL SELECT 'الجوف', unnest(ARRAY['الحزم','خب والشعف','المطمة','المصلوب','الغيل'])
  UNION ALL SELECT 'حجة', unnest(ARRAY['حجة','عبس','المحابشة','كحلان عفار','حرض','ميدي'])
  UNION ALL SELECT 'عمران', unnest(ARRAY['عمران','خمر','ريدة','ثلاء','شهارة','حوث'])
  UNION ALL SELECT 'صعدة', unnest(ARRAY['صعدة','سحار','مجز','الصفراء','باقم','كتاف والبقع'])
  UNION ALL SELECT 'ذمار', unnest(ARRAY['ذمار','جهران (معبر)','ضوران آنس','عتمة','وصاب العالي','وصاب السافل'])
  UNION ALL SELECT 'المحويت', unnest(ARRAY['المحويت','شبام كوكبان','الطويلة','الرجم','الخبت'])
  UNION ALL SELECT 'ريمة', unnest(ARRAY['الجبين','كسمة','مزهر','السلفية','بلاد الطعام'])
  UNION ALL SELECT 'أرخبيل سقطرى', unnest(ARRAY['حديبو','قلنسية'])
  UNION ALL SELECT 'صنعاء', unnest(ARRAY['همدان','بني مطر','سنحان وبني بهلول','الحيمتين','خولان','أرحب','نهم'])
) seed
ON CONFLICT (governorate, name) DO NOTHING;

-- 4) دالة فحص الاستخدام: هل توجد سجلات متبرعين في هذه المديرية؟
--    تُستخدم لمنع التعديل/الحذف الذي يكسر حقل donors.district.
CREATE OR REPLACE FUNCTION public.district_in_use(p_governorate TEXT, p_name TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.donors
    WHERE district = p_governorate || ' - ' || p_name
       OR district = p_governorate            -- متبرعون سُجِّلوا بالمحافظة فقط
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 5) RLS: قراءة عامة (للقوائم بلا تسجيل)، كتابة للأدمن فقط
ALTER TABLE public.governorates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.districts    ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS gov_select_all ON public.governorates;
CREATE POLICY gov_select_all ON public.governorates FOR SELECT USING (true);
DROP POLICY IF EXISTS gov_admin_write ON public.governorates;
CREATE POLICY gov_admin_write ON public.governorates FOR UPDATE TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS dist_select_all ON public.districts;
CREATE POLICY dist_select_all ON public.districts FOR SELECT USING (true);
DROP POLICY IF EXISTS dist_admin_insert ON public.districts;
CREATE POLICY dist_admin_insert ON public.districts FOR INSERT TO authenticated
  WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS dist_admin_update ON public.districts;
CREATE POLICY dist_admin_update ON public.districts FOR UPDATE TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS dist_admin_delete ON public.districts;
CREATE POLICY dist_admin_delete ON public.districts FOR DELETE TO authenticated
  USING (public.is_admin());

-- التحقق:
--   SELECT (SELECT count(*) FROM governorates) govs, (SELECT count(*) FROM districts) dists;  -- 22 / ~224
--   SELECT public.district_in_use('حضرموت','المكلا');
