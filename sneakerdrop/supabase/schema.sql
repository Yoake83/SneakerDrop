-- Fresh SneakerDrop installation. Uses its own names to coexist with other apps.
begin;
create schema if not exists sneakerdrop_private;
revoke all on schema sneakerdrop_private from public;
grant usage on schema sneakerdrop_private to anon, authenticated;

create table public.sneakerdrop_admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.sneakerdrop_admin_users enable row level security;
revoke all on public.sneakerdrop_admin_users from public, anon, authenticated;

create function sneakerdrop_private.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $fn$
  select (select auth.uid()) is not null and exists (
    select 1 from public.sneakerdrop_admin_users where user_id = (select auth.uid())
  );
$fn$;
revoke all on function sneakerdrop_private.is_admin() from public;
grant execute on function sneakerdrop_private.is_admin() to anon, authenticated;

create function public.sneakerdrop_is_admin()
returns boolean language sql stable security invoker set search_path = ''
as $fn$ select sneakerdrop_private.is_admin(); $fn$;
revoke all on function public.sneakerdrop_is_admin() from public;
grant execute on function public.sneakerdrop_is_admin() to anon, authenticated;

create table public.sneakerdrop_products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 1 and 100),
  description text not null check (char_length(trim(description)) between 1 and 2000),
  price numeric(10,2) not null check (price > 0 and price <= 100000),
  image_url text not null check (image_url ~ '^https://[^[:space:]]+$'),
  category text not null default 'Lifestyle' check (char_length(trim(category)) between 1 and 60),
  colorway text not null default '' check (char_length(colorway) <= 80),
  availability text not null default 'coming_soon' check (availability in ('available','coming_soon','sold_out')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.sneakerdrop_products enable row level security;
revoke all on public.sneakerdrop_products from public, anon, authenticated;
grant select on public.sneakerdrop_products to anon, authenticated;
grant insert, update, delete on public.sneakerdrop_products to authenticated;
create policy "Public catalogue" on public.sneakerdrop_products for select to anon, authenticated using (true);
create policy "Admin insert" on public.sneakerdrop_products for insert to authenticated with check ((select sneakerdrop_private.is_admin()));
create policy "Admin update" on public.sneakerdrop_products for update to authenticated using ((select sneakerdrop_private.is_admin())) with check ((select sneakerdrop_private.is_admin()));
create policy "Admin delete" on public.sneakerdrop_products for delete to authenticated using ((select sneakerdrop_private.is_admin()));

create function sneakerdrop_private.set_updated_at()
returns trigger language plpgsql security invoker set search_path = ''
as $fn$ begin new.updated_at = now(); return new; end; $fn$;
revoke all on function sneakerdrop_private.set_updated_at() from public, anon, authenticated;
create trigger sneakerdrop_products_updated_at before update on public.sneakerdrop_products
for each row execute function sneakerdrop_private.set_updated_at();

create table public.sneakerdrop_waitlist (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.sneakerdrop_products(id) on delete cascade,
  email text not null check (char_length(email) <= 254 and email = lower(trim(email)) and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  created_at timestamptz not null default now(),
  constraint sneakerdrop_waitlist_product_email_key unique (product_id, email)
);
create index sneakerdrop_waitlist_created_at_idx on public.sneakerdrop_waitlist(created_at desc);
alter table public.sneakerdrop_waitlist enable row level security;
revoke all on public.sneakerdrop_waitlist from public, anon, authenticated;
grant select on public.sneakerdrop_waitlist to authenticated;
create policy "Admin waitlist read" on public.sneakerdrop_waitlist for select to authenticated using ((select sneakerdrop_private.is_admin()));

-- The public interest form deliberately accepts unauthenticated visitors.
-- Only this validated operation can insert emails; it cannot read or edit them.
create function sneakerdrop_private.join_waitlist(product_id_input uuid, email_input text)
returns text language plpgsql security definer set search_path = ''
as $fn$
declare clean_email text := lower(trim(email_input));
begin
  if clean_email is null or char_length(clean_email) > 254 or clean_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then
    raise exception 'Invalid email' using errcode = '22023';
  end if;
  if not exists (select 1 from public.sneakerdrop_products where id = product_id_input) then
    raise exception 'Product not found' using errcode = '22023';
  end if;
  insert into public.sneakerdrop_waitlist(product_id,email) values(product_id_input,clean_email)
  on conflict (product_id,email) do nothing;
  return 'joined';
end;
$fn$;
revoke all on function sneakerdrop_private.join_waitlist(uuid,text) from public;
grant execute on function sneakerdrop_private.join_waitlist(uuid,text) to anon, authenticated;
create function public.sneakerdrop_join_waitlist(product_id_input uuid,email_input text)
returns text language sql security invoker set search_path = ''
as $fn$ select sneakerdrop_private.join_waitlist(product_id_input,email_input); $fn$;
revoke all on function public.sneakerdrop_join_waitlist(uuid,text) from public;
grant execute on function public.sneakerdrop_join_waitlist(uuid,text) to anon, authenticated;

commit;

-- After creating the admin in Supabase Authentication > Users:
-- insert into public.sneakerdrop_admin_users(user_id) select id from auth.users where lower(email) = 'YOUR_ADMIN_EMAIL';
