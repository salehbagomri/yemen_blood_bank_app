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
