-- Run as the project owner after schema, seed and admin membership setup.
-- All fixtures and changes are rolled back. Uses test@gmail.com as the configured admin.
begin;
set local role anon;
do $test$
declare product uuid;
begin
  if (select count(*) from public.sneakerdrop_products) < 3 then raise exception 'Expected at least three sneakers'; end if;
  if public.sneakerdrop_is_admin() then raise exception 'Anonymous visitor is admin'; end if;
  begin
    perform 1 from public.sneakerdrop_waitlist;
    raise exception 'Anonymous waitlist read was allowed';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.sneakerdrop_products(name,description,price,image_url) values('Forbidden','Forbidden',1,'https://example.invalid/shoe.jpg');
    raise exception 'Anonymous product write was allowed';
  exception when insufficient_privilege then null; end;
  select id into product from public.sneakerdrop_products order by id limit 1;
  perform public.sneakerdrop_join_waitlist(product,' Acceptance@Example.invalid ');
  perform public.sneakerdrop_join_waitlist(product,'acceptance@example.invalid');
  begin
    perform public.sneakerdrop_join_waitlist(product,'invalid email');
    raise exception 'Invalid email accepted';
  exception when invalid_parameter_value then null; end;
end;
$test$;
reset role;
do $test$
begin
  if (select count(*) from public.sneakerdrop_waitlist where email='acceptance@example.invalid') <> 1 then raise exception 'Duplicate prevention failed'; end if;
end;
$test$;
select set_config('request.jwt.claims','{"sub":"00000000-0000-4000-8000-000000000099","role":"authenticated"}',true);
set local role authenticated;
do $test$
declare affected integer;
begin
  if public.sneakerdrop_is_admin() then raise exception 'Ordinary user is admin'; end if;
  if exists(select 1 from public.sneakerdrop_waitlist) then raise exception 'Ordinary user can read waitlist'; end if;
  begin
    insert into public.sneakerdrop_products(name,description,price,image_url) values('Forbidden','Forbidden',1,'https://example.invalid/shoe.jpg');
    raise exception 'Ordinary user product insert was allowed';
  exception when insufficient_privilege then null; end;
  update public.sneakerdrop_products set name='Forbidden';
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'Ordinary user changed products'; end if;
  delete from public.sneakerdrop_products;
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'Ordinary user deleted products'; end if;
end;
$test$;
reset role;
select set_config('request.jwt.claims',jsonb_build_object('sub',(select id from auth.users where lower(email)='test@gmail.com'),'role','authenticated')::text,true);
set local role authenticated;
do $test$
declare product uuid := gen_random_uuid();
begin
  if not public.sneakerdrop_is_admin() then raise exception 'Authorized administrator was denied'; end if;
  insert into public.sneakerdrop_products(id,name,description,price,image_url,availability)
  values(product,'Acceptance fixture','Temporary rollback-only sneaker',100,'https://example.invalid/shoe.jpg','coming_soon');
  update public.sneakerdrop_products set availability='available',price=200 where id=product;
  if not exists(select 1 from public.sneakerdrop_products where id=product and availability='available' and price=200) then raise exception 'Admin product update failed'; end if;
  perform public.sneakerdrop_join_waitlist(product,'admin-acceptance@example.invalid');
  if not exists(select 1 from public.sneakerdrop_waitlist where product_id=product) then raise exception 'Admin waitlist read failed'; end if;
  delete from public.sneakerdrop_products where id=product;
  if exists(select 1 from public.sneakerdrop_products where id=product) or exists(select 1 from public.sneakerdrop_waitlist where product_id=product) then raise exception 'Delete or cascade failed'; end if;
end;
$test$;
reset role;
rollback;
select true as anonymous_access_checked, true as duplicate_prevention_checked, true as nonadmin_rls_checked, true as admin_crud_checked, true as cascade_checked;
