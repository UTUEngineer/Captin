import { withSupabase } from "@supabase/server";

/**
 * Callable with the publishable (anon) key — e.g. from the Flutter app
 * without a logged-in user JWT. Platform JWT check disabled in config.toml.
 */
export default {
  fetch: withSupabase({ auth: "publishable" }, async (_req, ctx) => {
    const { data, error } = await ctx.supabase.from("leagues_cache").select("region").limit(1);

    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    return Response.json({ ok: true, sample: data });
  }),
};
