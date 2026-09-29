import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import * as bcrypt from "https://deno.land/x/bcrypt@v0.4.1/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const MAX_ATTEMPTS = 5;
const LOCKOUT_MINUTES = 15;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { phone, pin } = await req.json();

    if (!phone || !pin || pin.length !== 4) {
      return new Response(
        JSON.stringify({ error: "Valid phone and 4-digit PIN are required." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { data: record, error: fetchErr } = await supabase
      .from("captain_pins")
      .select("id, captain_id, pin_hash, failed_attempts, locked_until")
      .eq("phone", phone)
      .maybeSingle();

    if (fetchErr || !record) {
      return new Response(
        JSON.stringify({ error: "Captain record not found." }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const now = new Date();
    if (record.locked_until && new Date(record.locked_until) > now) {
      const remainingMinutes = Math.ceil(
        (new Date(record.locked_until).getTime() - now.getTime()) / 60000
      );
      return new Response(
        JSON.stringify({
          error: `Account locked due to multiple failed attempts. Try again in ${remainingMinutes} minute(s).`,
          locked: true,
          remainingMinutes,
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const isMatch = await bcrypt.compare(pin, record.pin_hash);

    if (!isMatch) {
      const newFailedCount = (record.failed_attempts || 0) + 1;
      let lockUntilTime = null;

      if (newFailedCount >= MAX_ATTEMPTS) {
        lockUntilTime = new Date(
          now.getTime() + LOCKOUT_MINUTES * 60000
        ).toISOString();
      }

      await supabase
        .from("captain_pins")
        .update({
          failed_attempts: newFailedCount,
          locked_until: lockUntilTime,
        })
        .eq("id", record.id);

      return new Response(
        JSON.stringify({
          error:
            newFailedCount >= MAX_ATTEMPTS
              ? `Too many failed attempts. Account locked for ${LOCKOUT_MINUTES} minutes.`
              : `Incorrect PIN. Remaining attempts: ${MAX_ATTEMPTS - newFailedCount}`,
          locked: newFailedCount >= MAX_ATTEMPTS,
          remainingAttempts: Math.max(0, MAX_ATTEMPTS - newFailedCount),
        }),
        {
          status: newFailedCount >= MAX_ATTEMPTS ? 429 : 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // تصفير المحاولات عند النجاح
    await supabase
      .from("captain_pins")
      .update({ failed_attempts: 0, locked_until: null })
      .eq("id", record.id);

    return new Response(
      JSON.stringify({
        success: true,
        captainId: record.captain_id,
        message: "Authenticated successfully.",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
