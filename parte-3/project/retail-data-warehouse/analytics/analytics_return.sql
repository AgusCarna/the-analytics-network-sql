create or replace procedure analytics.sp_return()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  truncate analytics.return;
  with cte as (

select 

--atributos devoluciones
	rm.order_id, rm.return_id, rm.quantity, rm.date,
--atributos producto
	pm.product_id, pm.name as name_prod, pm.category, pm.subcategory, pm.subsubcategory, pm.material, pm.color, pm.origin, pm.ean, pm.is_active, pm.has_bluetooth, pm.size, pm.brand,
--atributos tienda
	sm.store_id, sm.country, sm.province, sm.city, sm.address, sm.name as name_store, sm.type, sm.start_date, sm.latitude, sm.longitude,
--valor de venta producto retornado	
((analytics.conversion(ols.currency, ols.sale, fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru))/ols.quantity) as cost_dev_usd

from fct.order_line_sale as ols
left join dim.product_master as pm
	on pm.product_id = ols.product_id
inner join fct.return_movements as rm
	on rm.order_id = ols.order_id
	and rm.product_id = ols.product_id
	and rm.movement_id = 2
left join dim.store_master as sm
	on sm.store_id = ols.store_id
left join fct.fx_rate as fx
	on (cast((date_trunc('month',ols.date)) as date)) = fx.month

  )
insert into analytics.return select * from cte;
  call etl.log('return', current_date, 'sp_return','usuario'); -- SP dentro del SP return para dejar log
	IF 
	(select order_number, return_id, count(1)
	from cte
	group by order_number, return_id
	having count(1) > 1) 
	is NOT NULL THEN RAISE EXCEPTION 'ERROR';
	END IF;
END;
$$;
