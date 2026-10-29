-- Fictional SneakerDrop products. Photography: Unsplash.
-- Deterministic IDs make re-running this seed safe.
insert into public.sneakerdrop_products (id,name,description,price,image_url,category,colorway,availability) values
('b0000000-0000-4000-8000-000000000001','Velocity 01','A bold everyday silhouette with sculpted lines and a vivid finish. For the unexpected turn and the long way home.',8499,'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=85','Lifestyle','Signal Red','available'),
('b0000000-0000-4000-8000-000000000002','Studio Low','Familiar lines. A fresh perspective. An understated low-top designed to anchor your rotation from the first coffee to the last train.',6999,'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=1000&q=85','Everyday','Chalk / Stone','coming_soon'),
('b0000000-0000-4000-8000-000000000003','Offbeat Classic','A classic profile with its own point of view. An expressive addition to the everyday uniform, made for wearing your way.',7499,'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1000&q=85','Classic','Rose / Canvas','sold_out')
on conflict (id) do nothing;
