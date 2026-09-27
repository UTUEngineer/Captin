-- ========================================================
-- جدول الفرق والتشكيلات الافتراضية والتخزين المؤقت (Supabase Hybrid Seed)
-- ========================================================

-- 1. جدول الفرق المحلية (مثل دوري نجوم العراق) - مجاني 100%
CREATE TABLE IF NOT EXISTS public.local_teams (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    league TEXT DEFAULT 'دوري نجوم العراق',
    logo_url TEXT,
    formation TEXT DEFAULT '4-3-3',
    starting_xi JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. جدول التخزين المؤقت لتشكيلات المباريات العالمية (cached_lineups)
CREATE TABLE IF NOT EXISTS public.cached_lineups (
    fixture_id BIGINT PRIMARY KEY,
    home_lineup JSONB NOT NULL,
    away_lineup JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- تفعيل سياسات الأمان (RLS) للقراءة والإضافة العامة
ALTER TABLE public.local_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cached_lineups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "قراءة التشكيلات المحلية متاحة للجميع"
    ON public.local_teams FOR SELECT
    USING (true);

CREATE POLICY "قراءة التشكيلات المخزنة متاحة للجميع"
    ON public.local_teams FOR INSERT
    WITH CHECK (true);

CREATE POLICY "قراءة التشكيلات المخزنة متاحة للجميع"
    ON public.cached_lineups FOR SELECT
    USING (true);

CREATE POLICY "إضافة التشكيلات المخزنة متاحة للجميع"
    ON public.cached_lineups FOR INSERT
    WITH CHECK (true);

CREATE POLICY "تحديث التشكيلات المخزنة متاحة للجميع"
    ON public.cached_lineups FOR UPDATE
    USING (true);

-- ========================================================
-- زرع البيانات الرسمية لأندية دوري نجوم العراق (Data Seeding)
-- ========================================================

INSERT INTO public.local_teams (name, formation, starting_xi) VALUES
-- 1. نادي الزوراء
(
  'نادي الزوراء',
  '4-2-3-1',
  '[
    {"id": "z1", "name": "جلال حسن", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "z2", "name": "مصطفى ناظم", "number": 4, "pos": "DEF", "grid": "2:2"},
    {"id": "z3", "name": "ميثم جبار", "number": 5, "pos": "DEF", "grid": "2:3"},
    {"id": "z4", "name": "ضرغام إسماعيل", "number": 15, "pos": "DEF", "grid": "2:1"},
    {"id": "z5", "name": "علاء مهاوي", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "z6", "name": "حيدر عبد الكريم", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "z7", "name": "محمد علي عبود", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "z8", "name": "حسن عبد الكريم", "number": 7, "pos": "MID", "grid": "4:1"},
    {"id": "z9", "name": "لؤي العاني", "number": 10, "pos": "MID", "grid": "4:3"},
    {"id": "z10", "name": "مراد محمد", "number": 11, "pos": "MID", "grid": "4:2"},
    {"id": "z11", "name": "علاء عباس", "number": 9, "pos": "FWD", "grid": "5:1"}
  ]'::jsonb
),
-- 2. نادي الشرطة
(
  'نادي الشرطة',
  '4-3-3',
  '[
    {"id": "s1", "name": "أحمد باسل", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "s2", "name": "مناف يونس", "number": 3, "pos": "DEF", "grid": "2:2"},
    {"id": "s3", "name": "فيصل جاسم", "number": 24, "pos": "DEF", "grid": "2:3"},
    {"id": "s4", "name": "أحمد يحيى", "number": 15, "pos": "DEF", "grid": "2:1"},
    {"id": "s5", "name": "أمير صباح", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "s6", "name": "عبد الرزاق قاسم", "number": 16, "pos": "MID", "grid": "3:2"},
    {"id": "s7", "name": "إدريسا نيانغ", "number": 8, "pos": "MID", "grid": "3:1"},
    {"id": "s8", "name": "فهد يوسف", "number": 11, "pos": "MID", "grid": "3:3"},
    {"id": "s9", "name": "محمود المواس", "number": 10, "pos": "FWD", "grid": "4:1"},
    {"id": "s10", "name": "أحمد فرحان", "number": 7, "pos": "FWD", "grid": "4:3"},
    {"id": "s11", "name": "مهند علي (ميمي)", "number": 18, "pos": "FWD", "grid": "5:1"}
  ]'::jsonb
),
-- 3. نادي القوة الجوية
(
  'نادي القوة الجوية',
  '4-3-3',
  '[
    {"id": "q1", "name": "محمد حميد", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "q2", "name": "حمود مشعان", "number": 3, "pos": "DEF", "grid": "2:4"},
    {"id": "q3", "name": "رسلان حنون", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "q4", "name": "سعد ناطق", "number": 24, "pos": "DEF", "grid": "2:2"},
    {"id": "q5", "name": "مصطفى سعدون", "number": 15, "pos": "DEF", "grid": "2:1"},
    {"id": "q6", "name": "إبراهيم بايش", "number": 8, "pos": "MID", "grid": "3:3"},
    {"id": "q7", "name": "صفاء هادي", "number": 6, "pos": "MID", "grid": "3:2"},
    {"id": "q8", "name": "شريف عبد الكاظم", "number": 11, "pos": "MID", "grid": "3:1"},
    {"id": "q9", "name": "أيمن حسين", "number": 9, "pos": "FWD", "grid": "5:1"},
    {"id": "q10", "name": "علي جاسم", "number": 7, "pos": "FWD", "grid": "4:1"},
    {"id": "q11", "name": "همام طارق", "number": 10, "pos": "FWD", "grid": "4:3"}
  ]'::jsonb
),
-- 4. نادي الطلبة
(
  'نادي الطلبة',
  '4-2-3-1',
  '[
    {"id": "t1", "name": "دانيال نصر الدين", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "t2", "name": "زيد تحسين", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "t3", "name": "علي فايز", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "t4", "name": "كرار محمد", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "t5", "name": "حيدر علي", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "t6", "name": "مهدي كامل", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "t7", "name": "كرار نبيل", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "t8", "name": "وكاع رمضان", "number": 11, "pos": "MID", "grid": "4:1"},
    {"id": "t9", "name": "نهاد محمد", "number": 10, "pos": "MID", "grid": "4:2"},
    {"id": "t10", "name": "محمد جواد", "number": 7, "pos": "MID", "grid": "4:3"},
    {"id": "t11", "name": "وكاع علي", "number": 9, "pos": "FWD", "grid": "5:1"}
  ]'::jsonb
),
-- 5. نادي زاخو
(
  'نادي زاخو',
  '4-4-2',
  '[
    {"id": "zk1", "name": "عالي رحيم", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "zk2", "name": "أحمد إبراهيم", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "zk3", "name": "موزيس كوروما", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "zk4", "name": "أمجد عطوان", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "zk5", "name": "جوان القاسم", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "zk6", "name": "ناصر عبد الكاظم", "number": 8, "pos": "MID", "grid": "3:3"},
    {"id": "zk7", "name": "باتريك كارفاليو", "number": 6, "pos": "MID", "grid": "3:2"},
    {"id": "zk8", "name": "فريد مجيد", "number": 10, "pos": "MID", "grid": "3:4"},
    {"id": "zk9", "name": "أمجد راضي", "number": 11, "pos": "MID", "grid": "3:1"},
    {"id": "zk10", "name": "غوستافو كورديرو", "number": 9, "pos": "FWD", "grid": "4:2"},
    {"id": "zk11", "name": "يونس أحمد", "number": 7, "pos": "FWD", "grid": "4:3"}
  ]'::jsonb
),
-- 6. نادي أربيل
(
  'نادي أربيل',
  '4-3-3',
  '[
    {"id": "e1", "name": "حسين نصر الله", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "e2", "name": "هيلو فائق", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "e3", "name": "بيار أبوبكر", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "e4", "name": "عمر جنيات", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "e5", "name": "شيركو كريم", "number": 7, "pos": "DEF", "grid": "2:4"},
    {"id": "e6", "name": "أكام هاشم", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "e7", "name": "إلياس أحمد", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "e8", "name": "ريبين سولاقا", "number": 14, "pos": "MID", "grid": "3:1"},
    {"id": "e9", "name": "أحمد سرتيب", "number": 10, "pos": "FWD", "grid": "4:1"},
    {"id": "e10", "name": "محمود خليل", "number": 9, "pos": "FWD", "grid": "5:1"},
    {"id": "e11", "name": "ياسين سامي", "number": 11, "pos": "FWD", "grid": "4:3"}
  ]'::jsonb
),
-- 7. نادي دهوك
(
  'نادي دهوك',
  '4-2-3-1',
  '[
    {"id": "d1", "name": "محمد صالح", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "d2", "name": "بيوار سليمان", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "d3", "name": "سياف محسن", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "d4", "name": "هريم برهان", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "d5", "name": "وليد سلام", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "d6", "name": "بروا نوري", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "d7", "name": "كاميران علي", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "d8", "name": "هيران أحمد", "number": 10, "pos": "MID", "grid": "4:2"},
    {"id": "d9", "name": "زاكري درامي", "number": 7, "pos": "MID", "grid": "4:1"},
    {"id": "d10", "name": "كريم دلمي", "number": 11, "pos": "MID", "grid": "4:3"},
    {"id": "d11", "name": "يانيك زاكري", "number": 9, "pos": "FWD", "grid": "5:1"}
  ]'::jsonb
),
-- 8. نادي الميناء
(
  'نادي الميناء',
  '4-4-2',
  '[
    {"id": "m1", "name": "جعفر شنيشل", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "m2", "name": "عباس يذار", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "m3", "name": "حيدر إياد", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "m4", "name": "حمزة هادي", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "m5", "name": "محمد شوكان", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "m6", "name": "حسام مالك", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "m7", "name": "عبد الله عادل", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "m8", "name": "إياد عبد اللطيف", "number": 10, "pos": "MID", "grid": "3:1"},
    {"id": "m9", "name": "سجاد جاسم", "number": 11, "pos": "MID", "grid": "3:4"},
    {"id": "m10", "name": "سجاد علاء", "number": 9, "pos": "FWD", "grid": "4:2"},
    {"id": "m11", "name": "كرار جعفر", "number": 7, "pos": "FWD", "grid": "4:3"}
  ]'::jsonb
),
-- 9. نادي النفط
(
  'نادي النفط',
  '4-3-3',
  '[
    {"id": "nf1", "name": "مصطفى عذاب", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "nf2", "name": "حسام كاظم", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "nf3", "name": "علي المياحي", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "nf4", "name": "كرار عامر", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "nf5", "name": "عمار غالب", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "nf6", "name": "أحمد عبد الحسين", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "nf7", "name": "ستيفن ساربوك", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "nf8", "name": "بسام شاكر", "number": 10, "pos": "MID", "grid": "3:1"},
    {"id": "nf9", "name": "أفراني ييبواه", "number": 9, "pos": "FWD", "grid": "5:1"},
    {"id": "nf10", "name": "وليد كريم", "number": 7, "pos": "FWD", "grid": "4:1"},
    {"id": "nf11", "name": "أحمد لفتة", "number": 11, "pos": "FWD", "grid": "4:3"}
  ]'::jsonb
),
-- 10. نادي النجف
(
  'نادي النجف',
  '4-2-3-1',
  '[
    {"id": "nj1", "name": "سرمد محسن", "number": 1, "pos": "GK", "grid": "1:1"},
    {"id": "nj2", "name": "حمزة عدنان", "number": 4, "pos": "DEF", "grid": "2:3"},
    {"id": "nj3", "name": "طاهر حميد", "number": 5, "pos": "DEF", "grid": "2:2"},
    {"id": "nj4", "name": "علي قاسم", "number": 3, "pos": "DEF", "grid": "2:1"},
    {"id": "nj5", "name": "أحمد النعيمات", "number": 2, "pos": "DEF", "grid": "2:4"},
    {"id": "nj6", "name": "صفاء الجابري", "number": 8, "pos": "MID", "grid": "3:2"},
    {"id": "nj7", "name": "محمد حسن", "number": 6, "pos": "MID", "grid": "3:3"},
    {"id": "nj8", "name": "معين أحمد", "number": 10, "pos": "MID", "grid": "4:2"},
    {"id": "nj9", "name": "حسين فلاح", "number": 7, "pos": "MID", "grid": "4:1"},
    {"id": "nj10", "name": "شبر علي", "number": 11, "pos": "MID", "grid": "4:3"},
    {"id": "nj11", "name": "دومينيك فينيسيوس", "number": 9, "pos": "FWD", "grid": "5:1"}
  ]'::jsonb
)
ON CONFLICT DO NOTHING;
