-- ============================================================================
--  بنك دم اليمن — المرحلة 7: إصلاح إيقاف المتبرع للمستشفيات (بسبب RLS)
--  Phase 7: Fix Donor Suspension for Hospitals (RLS bypass via Security Definer RPC)
-- ----------------------------------------------------------------------------
--  المشكلة: سياسة UPDATE الحالية على جدول donors تمنح الصلاحية فقط لمنشئ الصف (added_by)
--          أو الأدمن. المستشفى لا يستطيع إيقاف المتبرع (تسجيل عملية التبرع)
--          إذا كان المتبرع قد سجّل نفسه بنفسه (added_by IS NULL) أو أضافه مستخدم آخر.
--  الحل الفعال والآمن: إنشاء دالة rpc باسم suspend_donor_by_hospital
--                      تُنفَّذ بصلاحية مالك قاعدة البيانات (SECURITY DEFINER)
--                      لتتجاوز RLS، مع التحقق الأمني داخل الدالة من أن المستخدم
--                      المتصل هو (أدمن) أو (مستشفى في نفس محافظة المتبرع).
-- ============================================================================

CREATE OR REPLACE FUNCTION public.suspend_donor_by_hospital(p_donor_id UUID)
RETURNS public.donors AS $$
DECLARE
    v_hospital_gov TEXT;
    v_donor_gov TEXT;
    v_updated_donor public.donors;
BEGIN
    -- 1. التحقق الأمني: يجب أن يكون المستخدم مسجلاً ودوره إما admin أو hospital
    IF NOT (public.is_admin() OR public.is_hospital()) THEN
        RAISE EXCEPTION 'غير مصرح: يجب أن تكون مستشفى أو أدمن لتنفيذ هذا الإجراء.';
    END IF;

    -- 2. التحقق من النطاق الجغرافي إذا كان المستخدم مستشفى
    IF public.is_hospital() THEN
        -- الحصول على محافظة المستشفى
        SELECT governorate INTO v_hospital_gov FROM public.hospitals WHERE id = auth.uid();
        -- الحصول على محافظة المتبرع
        SELECT governorate INTO v_donor_gov FROM public.donors WHERE id = p_donor_id;

        -- التحقق من التطابق
        IF v_hospital_gov IS NULL OR v_donor_gov IS NULL OR v_hospital_gov <> v_donor_gov THEN
            RAISE EXCEPTION 'غير مصرح: لا يمكن للمستشفى إيقاف متبرع من خارج محافظته (محافظة المستشفى: %, محافظة المتبرع: %).', 
                COALESCE(v_hospital_gov, 'غير محددة'), 
                COALESCE(v_donor_gov, 'غير محددة');
        END IF;
    END IF;

    -- 3. تنفيذ عملية الإيقاف وتحديث تاريخ آخر تبرع
    UPDATE public.donors
    SET 
        suspended_until = (NOW() + INTERVAL '180 days'),
        last_donation_date = NOW()
    WHERE id = p_donor_id
    RETURNING * INTO v_updated_donor;

    -- التحقق من العثور على المتبرع
    IF v_updated_donor IS NULL THEN
        RAISE EXCEPTION 'خطأ: لم يتم العثور على المتبرع المعني.';
    END IF;

    RETURN v_updated_donor;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- منح الصلاحيات للمستخدمين المسجلين لاستدعاء الدالة
GRANT EXECUTE ON FUNCTION public.suspend_donor_by_hospital(UUID) TO authenticated;
