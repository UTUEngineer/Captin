import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// 1. خريطة الدوريات المدعومة (الدوري العراقي افتراضي، وقابل للتوسع لاحقاً)
const SUPPORTED_LEAGUES: Record<
  string,
  { id: number; name: string; country: string }
> = {
  iraq_stars_league: { id: 585, name: "Iraq Stars League", country: "Iraq" },
  // مستقبلاً: تفعيلها بمجرد إزالة التعليق:
  // acl_elite: { id: 17, name: "AFC Champions League Elite", country: "World" },
  // premier_league: { id: 39, name: "Premier League", country: "England" },
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("API_FOOTBALL_KEY");
    if (!apiKey) {
      throw new Error("API_FOOTBALL_KEY is not set in Supabase Secrets.");
    }

    const {
      endpoint = "standings", // standings | fixtures | teams
      leagueKey = "iraq_stars_league",
      season = 2026,
    } = await req.json();

    const selectedLeague = SUPPORTED_LEAGUES[leagueKey];
    if (!selectedLeague) {
      return new Response(
        JSON.stringify({
          error: `League '${leagueKey}' is currently disabled or not supported.`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 2. توجيه الطلب إلى API-Football (الربط المباشر الموصى به)
    const targetUrl = new URL(`https://v3.football.api-sports.io/${endpoint}`);
    targetUrl.searchParams.set("league", selectedLeague.id.toString());
    targetUrl.searchParams.set("season", season.toString());

    const headers: Record<string, string> = {
      "x-apisports-key": apiKey,
    };

    // دعم مفاتيح RapidAPI المباشرة إذا كانت مُعدّة
    const apiHost = Deno.env.get("API_FOOTBALL_HOST") || "v3.football.api-sports.io";
    if (apiHost.includes("rapidapi")) {
      headers["x-rapidapi-key"] = apiKey;
      headers["x-rapidapi-host"] = apiHost;
    }

    const apiResponse = await fetch(targetUrl.toString(), {
      method: "GET",
      headers,
    });

    if (!apiResponse.ok) {
      const errorText = await apiResponse.text();
      throw new Error(
        `API-Football error [${apiResponse.status}]: ${errorText}`,
      );
    }

    const data = await apiResponse.json();

    return new Response(
      JSON.stringify({
        success: true,
        league: selectedLeague.name,
        data: data.response,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
