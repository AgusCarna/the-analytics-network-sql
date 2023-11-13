create or replace procedure analytics.sp_inventory()
language plpgsql as $$
truncate analytics.inventory
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user;
  truncate analytics.inventory;
  with cte as (

select 

--atributos inventarios
	i.date, ((i.initial+i.final)/2) as inv_prom,
--atributos producto
	pm.product_id, pm.name as name_prod, pm.category, pm.subcategory, pm.subsubcategory, pm.material, pm.color, pm.origin, pm.ean, pm.is_active, pm.has_bluetooth, pm.size, pm.brand,
--atributos tienda
	sm.store_id, sm.country, sm.province, sm.city, sm.address, sm.name as name_store, sm.type, sm.start_date, sm.latitude, sm.longitude,
--costo inventario
	c.cost_usd

from fct.inventory as i
left join dim.product_master as pm
	on pm.product_id = i.item_id
left join dim.store_master as sm
	on sm.store_id = i.store_id
left join dim.cost as c
	on c.product_id = i.item_id

  )
insert into analytics.inventory select * from cte; 
  call etl.log('inventory',current_date, 'sp_inventory','usuario'); -- SP dentro del SP inventory para dejar log
END;
$$;
