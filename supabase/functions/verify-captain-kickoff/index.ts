import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { phone, otpCode } = await req.json();

    if (!phone || !otpCode) {
      return new Response(
        JSON.stringify({ error: "Phone number and OTP code are required." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // 1. التحقق من كود الـ OTP عبر محرك مصادقة Supabase
    const { data, error } = await supabase.auth.verifyOtp({
      phone,
      token: otpCode,
      type: "sms",
    });

    if (error || !data.user) {
      return new Response(
        JSON.stringify({ error: error?.message ?? "Invalid or expired OTP code." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. التحقق من وجود دور الكابتن في جدول الملفات الشخصية
    const { data: profile } = await supabase
      .from("captains")
      .select("id, full_name, team_id")
      .eq("user_id", data.user.id)
      .maybeSingle();

    return new Response(
      JSON.stringify({
        success: true,
        session: data.session,
        captain: profile ?? null,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
