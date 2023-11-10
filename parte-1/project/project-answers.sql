-- General 
-- - Ventas brutas, netas y margen (USD)

-- - Margen por categoria de producto (USD)

-- - ROI por categoria de producto. ROI = ventas netas / Valor promedio de inventario (USD)

-- - AOV (Average order value), valor promedio de la orden. (USD)

with consolidado as (
	select *, 
		ols.date as fecha_completa,
		extract(year from ols.date) as año, 
		extract(month from ols.date) as mes,
		case
			when ols.currency = 'ARS'
			then fx.fx_rate_usd_peso
			when ols.currency = 'EUR'
			then fx.fx_rate_usd_eur
			when ols.currency = 'URU'
			then fx.fx_rate_usd_uru
			else ols.sale
			end as cotizacion,
		case
			when ols.currency = 'ARS'
			then ols.sale/fx.fx_rate_usd_peso
			when ols.currency = 'EUR'
			then ols.sale/fx.fx_rate_usd_eur
			when ols.currency = 'URU'
			then ols.sale/fx.fx_rate_usd_uru
			else ols.sale
			end as sales_usd,
		case
			when ols.currency = 'ARS'
			then coalesce(ols.promotion/fx.fx_rate_usd_peso,0)
			when ols.currency = 'EUR'
			then coalesce(ols.promotion/fx.fx_rate_usd_eur,0)
			when ols.currency = 'URU'
			then coalesce(ols.promotion/fx.fx_rate_usd_uru,0)
			else ols.promotion
			end as promotion_usd,
		case
			when ols.currency = 'ARS'
			then coalesce(ols.credit/fx.fx_rate_usd_peso,0)
			when ols.currency = 'EUR'
			then coalesce(ols.credit/fx.fx_rate_usd_eur,0)
			when ols.currency = 'URU'
			then coalesce(ols.credit/fx.fx_rate_usd_uru,0)
			else ols.credit
			end as credit_usd,
		case
			when ols.currency = 'ARS'
			then coalesce(ols.tax/fx.fx_rate_usd_peso,0)
			when ols.currency = 'EUR'
			then coalesce(ols.tax/fx.fx_rate_usd_eur,0)
			when ols.currency = 'URU'
			then coalesce(ols.tax/fx.fx_rate_usd_uru,0)
			else ols.tax
			end as tax_usd,	
		case
			when ols.currency = 'ARS'
			then (ols.sale-coalesce(ols.promotion,0))/fx.fx_rate_usd_peso
			when ols.currency = 'EUR'
			then (ols.sale-coalesce(ols.promotion,0))/fx.fx_rate_usd_eur
			when ols.currency = 'URU'
			then (ols.sale-coalesce(ols.promotion,0))/fx.fx_rate_usd_uru
			else ols.sale-coalesce(ols.promotion,0)
			end as net_sales_usd,
		case
			when ols.currency = 'ARS'
			then ((ols.sale-coalesce(ols.promotion,0)-coalesce(ols.tax,0))/fx.fx_rate_usd_peso)-(c.product_cost_usd*ols.quantity)
			when ols.currency = 'EUR'
			then ((ols.sale-coalesce(ols.promotion,0)-coalesce(ols.tax,0))/fx.fx_rate_usd_eur)-(c.product_cost_usd*ols.quantity)
			when ols.currency = 'URU'
			then ((ols.sale-coalesce(ols.promotion,0)-coalesce(ols.tax,0))/fx.fx_rate_usd_uru)-(c.product_cost_usd*ols.quantity)
			else ols.sale-coalesce(ols.promotion,0)-coalesce(ols.tax,0)-(c.product_cost_usd*ols.quantity)
			end as margin_usd
	from stg.order_line_sale as ols
	left join stg.product_master as pm
		on pm.product_code = ols.product
	left join stg.cost as c
		on c.product_code = ols.product
	left join stg.monthly_average_fx_rate as fx
		on date_trunc('month',ols.date) = fx.month
	left join stg.inventory as inv
		on inv.item_id = ols.product
		and inv.date = ols.date
		and inv.store_id = ols.store
),
aux_store as (
	select 
        date_trunc('year',inv.date ) as año, 
        date_trunc('month',inv.date ) as mes,
        store_id,
        sum((initial + final)/2) as inv_prom,
        sum(((initial + final)/2)*product_cost_usd) as cost_inv_prom
    from stg.inventory inv 
    left join stg.cost cos 
		on inv.item_id = cos.product_code 
    left join stg.product_master pm 
		on inv.item_id = pm.product_code
    group by 1,2,3
),
aux_store2 as (
	select
		año, mes,store,
		avg (inv_prom) as inv_prom ,
		avg (cost_inv_prom) as cost_inv_prom
	from aux_store
	group by 1,2,3
	order by 1,2,3
),
aux_inv as (
	select 
		año, mes, fecha_completa, category,
		sum (net_sales_usd) as net_sales_usd,
		sum (margin_usd) as margin_usd,
		sum(((initial + final)*1.00)/2) as inv_prom,
		sum((((initial + final)*1.00)/2)*product_cost_usd) as cost_inv_prom
	from consolidado
	group by 1,2,3,4
),
aux_inv2 as (
	select
		año, mes,category,
		sum (net_sales_usd) as net_sales_usd,
		sum (margin_usd) as margin_usd,
		avg (inv_prom) as inv_prom ,
		avg (cost_inv_prom) as cost_inv_prom
	from aux_inv
	group by 1,2,3
)

select 
		año, mes,
		category,
		margin_usd,
		(net_sales_usd/cost_inv_prom) as ROI
from aux_2


select 
		año, mes,
		sum (sales_usd) as sales_usd,
		sum (net_sales_usd) as net_sales_usd,
		sum (margin_usd) as margin_usd,
		(sum (sales_usd))/(count(distinct order_number)) as aov
from consolidado
group by 1,2
order by 1,2		


-- Contabilidad (USD)
-- - Impuestos pagados

-- - Tasa de impuesto. Impuestos / Ventas netas 

-- - Cantidad de creditos otorgados

-- - Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito

select 
		año, mes,
		sum (tax_usd) as tax_usd,
		(sum (tax_usd))/(sum (net_sales_usd)) as tax_rate,
		sum (credit_usd) as credit_usd,
		(sum (net_sales_usd)) - (sum (promotion_usd)) + (sum (tax_usd)) - (sum (credit_usd)) as amount_paid_usd
from consolidado
group by 1,2
order by 1,2	


-- Supply Chain (USD)
-- - Costo de inventario promedio por tienda

select 
		año, mes, store,
		cost_inv_prom
from aux_store2

-- - Costo del stock de productos que no se vendieron por tienda

with inv_cost as (
	select 
		*,
		extract(year from i.date) as año, 
		extract(month from i.date) as mes,
		extract(day from i.date) as dia
	from stg.inventory as i
	left join stg.cost as c
		on i.item_id = c.product_code
	where item_id in
		(select pm.product_code
		from stg.product_master as pm
		left join stg.order_line_sale as ols
			on pm.product_code = ols.product
		where ols.product is null)
	order by 2,3,1
)

select 
	store_id,
	año, mes,
	(sum(product_cost_usd*((initial+final)/2))) as inventario
from inv_cost
group by store_id,año, mes
order by store_id,año, mes


-- - Cantidad y costo de devoluciones
with aux_dev as (
	select
		extract(year from rm.date) as año, 
		extract(month from rm.date) as mes,
		rm.order_id, rm.item, rm.quantity, --as cant_dev,
		sum(ols.sale/ols.quantity) as costo_uni
	from stg.return_movements as rm
	left join stg.order_line_sale as ols
		on ols.order_number = rm.order_id
	group by 1,2,3,4,5
	order by 1,2,3,4,5
)
	
select
	año, mes, 
	(sum (quantity)) as quantity,
	(sum (quantity*costo_uni)) as returned_sales_usd
from aux_dev
group by 1,2 
order by 1,2


-- Tiendas
-- - Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
with stg_traffic as (
	select store_id, cast(cast(date as text) as date) as date, traffic from stg.market_count
	union all
	select store_id, cast(date as date) as date, traffic from stg.super_store_count
	)
, stg_orders as (
	select store, date, count(distinct order_number) nbr_orders
	from stg.order_line_sale ols
	group by 1,2
)
select 
    date(date_trunc('month', t.date)) as month,
    sum(nbr_orders)/sum(traffic) as cvr
from stg_traffic t 
left join stg_orders o 
	on t.store_id = o.store 
	and t.date = o.date
group by 1
