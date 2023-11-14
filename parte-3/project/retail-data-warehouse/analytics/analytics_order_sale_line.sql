create or replace procedure analytics.sp_order_sale_line()
language plpgsql as $$
declare
  usuario varchar(10) := current_user ;
begin
  usuario := current_user; 
  truncate analytics.order_sale_line;
  
with aux_egresos as (
	select 
		sh.year,sh.store_id, sh.item_id,sh.quantity, c.product_cost_usd 
		,sh.quantity*c.product_cost_usd as egreso_total
	from fct.shrinkage sh
	left join dim.cost c
		on c.product_id = sh.item_id
	order by sh.year,sh.store_id,sh.item_id
	
), 


aux_philips as (
	select
		ols.order_id,pm.brand,
		extract (year from date) as year,
		sum(quantity) over(partition by extract (year from date)),
		case
			when extract (year from date) = 2022 then 20000
			when extract (year from date) = 2023 then 5000
			end as total_extra, 
		case
			when extract (year from date) = 2022 then (20000/(((sum(quantity) over(partition by extract (year from date))))*1.00))
			when extract (year from date) = 2023 then (5000/(((sum(quantity) over(partition by extract (year from date))))*1.00))
		end as ingreso_extra
	from fct.order_line_sale as ols
	left join dim.product_master as pm
		on ols.product_id = pm.product_id
	where pm.brand = 'Philips'
), cte as (

	select 
	
-- tienda
	sm.country, sm.province, sm.name as nombre_tienda
	
--SKU
	, pm.category, pm.subcategory, pm.subsubcategory, sup.name as proveedor
	
--atributos de fecha
	, extract(day from ols.date) as day
	, extract(month from ols.date) as month
	, extract(year from ols.date) as year
	, case
		when extract (month from ols.date) in (1) then concat ('FY',cast(((extract(year from ols.date))-1) as text))
		else concat ('FY',cast((extract(year from ols.date)) as text))
		end as fiscal_year_label
	, case
		when extract (month from ols.date) in (2,3,4) then 'Q1'
		when extract (month from ols.date) in (5,6,7) then 'Q2'
		when extract (month from ols.date) in (8,9,10) then 'Q3'
		when extract (month from ols.date) in (11,12,1) then 'Q4'
		end as fiscal_quarter_label
		
--pasaje a USD
	
	
	, case
			when ols.currency = 'ARS'
			then fx.fx_rate_usd_peso
			when ols.currency = 'EUR'
			then fx.fx_rate_usd_eur
			when ols.currency = 'URU'
			then fx.fx_rate_usd_uru
			else ols.sale
			end as cotizacion
    	, (analytics.conversion(ols.currency, ols.sale, fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)) as sales_usd
	, (analytics.conversion(ols.currency, ols.promotion, fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)) as promotion_usd
	, (analytics.conversion(ols.currency, ols.credit, fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)) as credit_usd
	, (analytics.conversion(ols.currency, ols.tax, fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)) as tax_usd
	, (analytics.conversion(ols.currency, (ols.sale-coalesce(ols.promotion,0)), fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)) as net_sales_usd
	, (((analytics.conversion(ols.currency, (ols.sale-coalesce(ols.promotion,0)-coalesce(ols.tax,0)), fx.fx_rate_usd_peso, fx.fx_rate_usd_eur, fx.fx_rate_usd_uru)))-(c.product_cost_usd*ols.quantity)) as margin_usd
	
	, c.product_cost_usd, ols.order_id, ols.product_id, rm.quantity as devoluciones
	, inv.initial, inv.final,ols.quantity

--ingresos extras

	, ap.ingreso_extra, pm.brand

--egresos extras
	
	, ae.egreso_total
	, sum(ols.quantity) over(partition by ae.year,ae.store_id,ae.item_id )
	, (((ae.quantity*c.product_cost_usd)*1.00)/((sum(ols.quantity) over(partition by ae.year,ae.store_id,ae.item_id ))*1.00)) as egreso_extra

--joins
	from fct.order_line_sale as ols
	left join dim.product_master as pm
		on pm.product_id = ols.product_id
	left join dim.cost as c
		on c.product_id = ols.product_id
	left join fct.fx_rate as fx
		on date_trunc('month',ols.date) = fx.month
	left join fct.inventory as inv
		on inv.item_id = ols.product_id
		and inv.date = ols.date
		and inv.store_id = ols.store
	left join fct.return_movements as rm
		on rm.order_id = ols.order_id
		and rm.product_id = ols.product_id
		and rm.movement_id = 2
	left join dim.supplier_product as sup
		on sup.product_id = ols.product_id
		and sup.is_primary is true
	left join dim.store_master as sm
		on sm.store_id = ols.store
	left join aux_philips as ap
		on ap.order_id = ols.order_id
		and ap.brand = pm.brand
		and pm.brand = 'Philips'
		and ap.year = extract(year from ols.date)
	left join aux_egresos as ae
		on ae.year = extract(year from ols.date)
		and ae.store_id = ols.store
		and ae.item_id = ols.product_id
)
	insert into analytics.order_sale_line select * from cte;
  call etl.log('order_sale_line',current_date, 'sp_order_sale_line','usuario'); -- SP dentro del SP order_sale_line para dejar log
	IF 
		(select order_id, product_id, count(1)
		from cte
		group by order_id, product_id
		having count(1) > 1) 
		is not null the raise exception 'error';
	END IF;
END;
$$;
