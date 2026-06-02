-- تعديل جدول البانرات لدعم البانرات النصية بجانب البانرات الصورية
-- 1. جعل مسار الصورة اختيارياً
ALTER TABLE public.banners ALTER COLUMN image_path DROP NOT NULL;

-- 2. إضافة حقول الأيقونة والتدرج اللوني للبانرات النصية
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS icon_name TEXT;
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS bg_gradient TEXT;

-- 3. إدخال البانرات الخمسة التوعوية الافتراضية السابقة في قاعدة البيانات لكي يتمكن الأدمن من إدارتها وتفعيلها/إيقافها
INSERT INTO public.banners (title, subtitle, image_path, action_type, action_value, sort_order, is_active, icon_name, bg_gradient)
VALUES 
('التبرع بالدم ينقذ الأرواح', 'كل تبرع بالدم يمكن أن ينقذ حياة ثلاثة أشخاص', NULL, 'none', NULL, 0, true, 'favorite', 'red'),
('فوائد التبرع بالدم', 'التبرع بالدم يحسن صحتك ويجدد خلايا الدم ويحفز الدورة الدموية', NULL, 'none', NULL, 1, true, 'health_and_safety', 'green'),
('كل 3 ثواني', 'يحتاج شخص ما إلى نقل دم في مكان ما كل ثلاث ثوانٍ فقط', NULL, 'none', NULL, 2, true, 'timer', 'orange'),
('كن بطلاً ومتبرعاً', 'انضم لآلاف الأبطال المتبرعين بالدم في اليمن واصنع فرقاً حقيقياً', NULL, 'none', NULL, 3, true, 'people', 'blue'),
('أبطال اليمن', 'هناك {{total_donors}} بطل تبرع بدمه لينقذ الأرواح في مجتمعنا', NULL, 'none', NULL, 4, true, 'military_tech', 'crimson')
ON CONFLICT DO NOTHING;
