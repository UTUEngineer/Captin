// Minimal health endpoint for the in-app diagnostic panel.
// Deploy: supabase functions deploy health
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return new Response(
    JSON.stringify({ ok: true, ts: Date.now() }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});
