-- المرحلة 8: نظام البانرات الديناميكي (Banners System)
-- إنشاء جدول البانرات وسياسات الحماية ومستودع تخزين الصور

CREATE TABLE IF NOT EXISTS public.banners (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title       TEXT NOT NULL,                    -- عنوان البانر
    subtitle    TEXT,                              -- وصف مختصر (اختياري)
    image_path  TEXT NOT NULL,                    -- مسار الصورة في Storage (مثل: banners/campaign1.webp)
    action_type TEXT DEFAULT 'none',              -- none | internal_route | external_url
    action_value TEXT,                             -- مسار الشاشة أو الرابط
    sort_order  INT DEFAULT 0,                    -- ترتيب العرض
    is_active   BOOLEAN DEFAULT true,             -- تفعيل/إيقاف
    starts_at   TIMESTAMPTZ,                      -- تاريخ بدء العرض (اختياري)
    ends_at     TIMESTAMPTZ,                      -- تاريخ انتهاء العرض (اختياري)
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

-- فهرس للاستعلام المتكرر (البانرات النشطة مرتبة)
CREATE INDEX IF NOT EXISTS idx_banners_active_sort ON public.banners (is_active, sort_order) WHERE is_active = true;

-- تفعيل RLS (Row Level Security)
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- سياسات الحماية لجدول banners
-- 1. السماح بالقراءة للجميع (عام)
CREATE POLICY "banners_select_all" ON public.banners 
    FOR SELECT USING (true);

-- 2. السماح بالتحكم الكامل للأدمن فقط
CREATE POLICY "banners_admin_all" ON public.banners 
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
    );

-- إعداد Storage Bucket للبانرات
-- إضافة الـ bucket للجدول
INSERT INTO storage.buckets (id, name, public) 
VALUES ('banners', 'banners', true)
ON CONFLICT (id) DO NOTHING;

-- سياسات الحماية لمستودع التخزين (storage.objects)
-- 1. قراءة عامة للصور
CREATE POLICY "banners_read_all" ON storage.objects
    FOR SELECT USING (bucket_id = 'banners');

-- 2. رفع الصور للأدمن فقط
CREATE POLICY "banners_upload_admin" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'banners' AND
        EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
    );

-- 3. حذف الصور للأدمن فقط
CREATE POLICY "banners_delete_admin" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'banners' AND
        EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
    );
