import { withSupabase } from "@supabase/server";

/** Public health check — no JWT required (see verify_jwt = false in config.toml). */
export default {
  fetch: withSupabase({ auth: "none" }, async () => {
    return Response.json({ ok: true, service: "captain-edge" });
  }),
};
