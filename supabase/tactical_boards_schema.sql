-- ========================================================
-- جدول التشكيلات واللوحات التكتيكية (Tactical Boards Table)
-- ========================================================

CREATE TABLE IF NOT EXISTS public.tactical_boards (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    formation VARCHAR(50) DEFAULT 'Custom',
    pitch_type VARCHAR(20) DEFAULT '2D', -- '2D' أو '3D'
    board_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- فهارس لتحسين سرعة الاستعلام
CREATE INDEX IF NOT EXISTS idx_tactical_boards_user_id ON public.tactical_boards(user_id);
CREATE INDEX IF NOT EXISTS idx_tactical_boards_updated_at ON public.tactical_boards(updated_at DESC);

-- تفعيل سياسات الأمان على مستوى الصف (Row Level Security - RLS)
ALTER TABLE public.tactical_boards ENABLE ROW LEVEL SECURITY;

-- سياسة الاستعلام (SELECT)
CREATE POLICY "الكابتن يستطيع قراءة تشكيلاته فقط"
    ON public.tactical_boards FOR SELECT
    USING (auth.uid() = user_id);

-- سياسة الإضافة (INSERT)
CREATE POLICY "الكابتن يستطيع إضافة تشكيلة جديدة"
    ON public.tactical_boards FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- سياسة التحديث (UPDATE)
CREATE POLICY "الكابتن يستطيع تعديل تشكيلاته الخاصة"
    ON public.tactical_boards FOR UPDATE
    USING (auth.uid() = user_id);

-- سياسة الحذف (DELETE)
CREATE POLICY "الكابتن يستطيع حذف تشكيلاته"
    ON public.tactical_boards FOR DELETE
    USING (auth.uid() = user_id);

-- ========================================================
-- دورة حياة ونتائج تحليل الفيديو بالذكاء الاصطناعي (AI Video Pipeline)
-- ========================================================

-- جدول تتبع حالة وظائف التحليل (Jobs Lifecycle)
CREATE TABLE IF NOT EXISTS public.video_analysis_jobs (
    id UUID PRIMARY KEY,
    match_id UUID REFERENCES public.tactical_boards(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    progress INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول تخزين إحداثيات التتبع 2D المقاسة (0.0 إلى 1.0)
CREATE TABLE IF NOT EXISTS public.player_tracking_frames (
    id BIGSERIAL PRIMARY KEY,
    job_id UUID REFERENCES public.video_analysis_jobs(id) ON DELETE CASCADE,
    match_id UUID,
    frame INT NOT NULL,
    timestamp_ms INT NOT NULL,
    track_id INT NOT NULL,
    entity_type TEXT NOT NULL, -- 'player' | 'ball' | 'referee'
    x_norm FLOAT NOT NULL,
    y_norm FLOAT NOT NULL,
    team_color TEXT DEFAULT 'home'
);

CREATE INDEX IF NOT EXISTS idx_tracking_job_frame ON public.player_tracking_frames(job_id, frame);

-- تفعيل البث المباشر (Supabase Realtime) على جدول الوظائف
ALTER PUBLICATION supabase_realtime ADD TABLE public.video_analysis_jobs;

-- ========================================================
-- قيود الحذف المتتابع والامتثال القانوني (Compliance & Cascade Foreign Keys)
-- ========================================================

ALTER TABLE IF EXISTS public.tactical_boards
    DROP CONSTRAINT IF EXISTS fk_user,
    ADD CONSTRAINT fk_user
    FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) 
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.video_analysis_jobs
    DROP CONSTRAINT IF EXISTS fk_match,
    ADD CONSTRAINT fk_match
    FOREIGN KEY (match_id) 
    REFERENCES public.tactical_boards(id) 
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.player_tracking_frames
    DROP CONSTRAINT IF EXISTS fk_job,
    ADD CONSTRAINT fk_job
    FOREIGN KEY (job_id) 
    REFERENCES public.video_analysis_jobs(id) 
    ON DELETE CASCADE;

-- سجل الامتثال للخصوصية والحذف (GDPR / PDPL / CCPA Audit Log)
CREATE TABLE IF NOT EXISTS public.compliance_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    anonymized_user_hash TEXT NOT NULL,
    action_type TEXT NOT NULL, -- 'DATA_EXPORT', 'ACCOUNT_DELETION'
    regulatory_framework TEXT NOT NULL, -- 'GDPR', 'PDPL', 'CCPA'
    completed_at TIMESTAMPTZ DEFAULT NOW()
);

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
    ON public.cached_lineups FOR SELECT
    USING (true);

CREATE POLICY "إضافة التشكيلات المخزنة متاحة للجميع"
    ON public.cached_lineups FOR INSERT
    WITH CHECK (true);

CREATE POLICY "تحديث التشكيلات المخزنة متاحة للجميع"
    ON public.cached_lineups FOR UPDATE
    USING (true);

-- إدخال نموذج لتشكيلة نادي الزوراء ونادي الشرطة (مجاناً وبدون أي API)
INSERT INTO public.local_teams (name, formation, starting_xi) VALUES
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
);

