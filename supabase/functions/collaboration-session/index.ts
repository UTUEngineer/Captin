import { withSupabase } from "@supabase/server";

/**
 * Example authenticated handler for Captain collaboration APIs.
 * Uses RLS-scoped client (ctx.supabase) for user data and
 * ctx.supabaseAdmin only when a trusted server action must bypass RLS.
 */
export default {
  fetch: withSupabase({ auth: "user" }, async (_req, ctx) => {
    const userId = ctx.user?.id;
    if (!userId) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Example: list rows visible to the caller under RLS
    const { data, error } = await ctx.supabase
      .from("collaboration_sessions")
      .select("id, code, created_at")
      .limit(20);

    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    return Response.json({ userId, sessions: data ?? [] });
  }),
};
