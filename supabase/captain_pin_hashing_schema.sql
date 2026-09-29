-- 1. Enable pgcrypto for salted bcrypt hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Add PIN hash column and rate-limiting counters
ALTER TABLE public.captains 
ADD COLUMN IF NOT EXISTS pin_hash TEXT,
ADD COLUMN IF NOT EXISTS failed_pin_attempts INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS pin_locked_until TIMESTAMPTZ;

-- 3. Procedure to set / update a 4-digit PIN
CREATE OR REPLACE FUNCTION public.set_captain_pin(
  p_captain_id UUID,
  p_pin TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Strict validation: exactly 4 numeric digits
  IF p_pin !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'PIN must be exactly 4 digits.';
  END IF;

  UPDATE public.captains
  SET 
    pin_hash = crypt(p_pin, gen_salt('bf', 8)),
    failed_pin_attempts = 0,
    pin_locked_until = NULL
  WHERE id = p_captain_id;
END;
$$;

-- 4. Secure Verification Function with Rate Limiting
CREATE OR REPLACE FUNCTION public.verify_captain_pin(
  p_phone TEXT,
  p_pin TEXT
)
RETURNS TABLE (
  is_valid BOOLEAN,
  captain_id UUID,
  captain_name TEXT,
  armband_tier TEXT,
  error_message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_captain RECORD;
BEGIN
  -- Fetch captain by registered phone number
  SELECT c.id, c.full_name, c.armband_tier, c.pin_hash, c.failed_pin_attempts, c.pin_locked_until
  INTO v_captain
  FROM public.captains c
  JOIN auth.users u ON u.id = c.id
  WHERE u.phone = p_phone;

  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, 'Captain not found with this phone number.'::TEXT;
    RETURN;
  END IF;

  -- Check lockout threshold (max 5 failed attempts locks for 15 minutes)
  IF v_captain.pin_locked_until IS NOT NULL AND v_captain.pin_locked_until > NOW() THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, 'Too many failed attempts. PIN locked for 15 minutes.'::TEXT;
    RETURN;
  END IF;

  -- Validate PIN against bcrypt hash
  IF v_captain.pin_hash IS NOT NULL AND v_captain.pin_hash = crypt(p_pin, v_captain.pin_hash) THEN
    -- Success: reset failed attempts
    UPDATE public.captains 
    SET failed_pin_attempts = 0, pin_locked_until = NULL 
    WHERE id = v_captain.id;

    RETURN QUERY SELECT TRUE, v_captain.id, v_captain.full_name, v_captain.armband_tier, NULL::TEXT;
  ELSE
    -- Failure: increment counter and apply temporary lock if >= 5
    UPDATE public.captains 
    SET 
      failed_pin_attempts = failed_pin_attempts + 1,
      pin_locked_until = CASE WHEN failed_pin_attempts + 1 >= 5 THEN NOW() + INTERVAL '15 minutes' ELSE NULL END
    WHERE id = v_captain.id;

    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, 'Incorrect 4-digit PIN.'::TEXT;
  END IF;
END;
$$;
