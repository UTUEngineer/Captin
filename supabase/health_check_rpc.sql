-- Side-effect-free RPC for the in-app health panel.
create or replace function public.health_check()
returns json
language sql
stable
set search_path = ''
as $$
  select json_build_object('ok', true, 'db_time', now());
$$;

revoke all on function public.health_check() from public;
grant execute on function public.health_check() to anon, authenticated;
