-- ========================================================
-- 1. تفعيل RLS على جميع الجداول الأساسية
-- ========================================================
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.captains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tactics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- تنظيف السياسات القديمة لتفادي التكرار
DROP POLICY IF EXISTS "Anyone can view teams" ON public.teams;
DROP POLICY IF EXISTS "Captains can manage their own team" ON public.teams;

DROP POLICY IF EXISTS "Captains can view profiles" ON public.captains;
DROP POLICY IF EXISTS "Captains can update own profile" ON public.captains;

DROP POLICY IF EXISTS "Captains view own team tactics" ON public.tactics;
DROP POLICY IF EXISTS "Captains insert own team tactics" ON public.tactics;
DROP POLICY IF EXISTS "Captains update own team tactics" ON public.tactics;
DROP POLICY IF EXISTS "Captains delete own team tactics" ON public.tactics;

DROP POLICY IF EXISTS "Anyone can view matches" ON public.matches;
DROP POLICY IF EXISTS "Competing captains can update match" ON public.matches;

-- ========================================================
-- 2. جدول الفرق (teams)
-- ========================================================
-- أ) السماح لأي مستخدم مسجل بالاطلاع على قائمة الفرق
CREATE POLICY "Anyone can view teams"
  ON public.teams
  FOR SELECT
  TO authenticated
  USING (true);

-- ب) فقط الكابتن صاحب الفريق يستطيع التعديل
CREATE POLICY "Captains can manage their own team"
  ON public.teams
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = captain_id)
  WITH CHECK (auth.uid() = captain_id);

-- ========================================================
-- 3. جدول الكباتن (captains)
-- ========================================================
-- أ) قراءة الحسابات العامة للكباتن
CREATE POLICY "Captains can view profiles"
  ON public.captains
  FOR SELECT
  TO authenticated
  USING (true);

-- ب) الكابتن يعدل فقط حسابه الشخصي
CREATE POLICY "Captains can update own profile"
  ON public.captains
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ========================================================
-- 4. جدول الخطط التكتيكية (tactics) - حماية فائقة
-- ========================================================
-- أ) القراءة: مقتصرة فقط على كابتن الفريق صاحب الخطة
CREATE POLICY "Captains view own team tactics"
  ON public.tactics
  FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid()
    OR team_id IN (
      SELECT team_id FROM public.captains WHERE user_id = auth.uid()
    )
  );

-- ب) الإضافة: تسجيل الخطة باسم الكابتن وفريقه فقط
CREATE POLICY "Captains insert own team tactics"
  ON public.tactics
  FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND team_id IN (
      SELECT team_id FROM public.captains WHERE user_id = auth.uid()
    )
  );

-- ج) التعديل: تعديل خطط فريقه فقط
CREATE POLICY "Captains update own team tactics"
  ON public.tactics
  FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid()
    OR team_id IN (
      SELECT team_id FROM public.captains WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    created_by = auth.uid()
    OR team_id IN (
      SELECT team_id FROM public.captains WHERE user_id = auth.uid()
    )
  );

-- د) الحذف: فقط منشئ الخطة
CREATE POLICY "Captains delete own team tactics"
  ON public.tactics
  FOR DELETE
  TO authenticated
  USING (created_by = auth.uid());

-- ========================================================
-- 5. جدول المباريات (matches)
-- ========================================================
-- أ) القراءة: جدول المباريات متاح للجميع للاطلاع على التوقيت والملاعب
CREATE POLICY "Anyone can view matches"
  ON public.matches
  FOR SELECT
  TO authenticated
  USING (true);

-- ب) التعديل: فقط كابتن الفريق المستضيف (home_team) أو الضيف (away_team)
CREATE POLICY "Competing captains can update match"
  ON public.matches
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.captains c
      WHERE c.user_id = auth.uid()
      AND (c.team_id = matches.home_team_id OR c.team_id = matches.away_team_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.captains c
      WHERE c.user_id = auth.uid()
      AND (c.team_id = matches.home_team_id OR c.team_id = matches.away_team_id)
    )
  );
