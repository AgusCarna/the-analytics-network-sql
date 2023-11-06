create or replace procedure etl.sp_dim_product_master()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
  select *,
	    CASE 
        WHEN lower(name) LIKE '%samsung%' THEN 'Samsung'
        WHEN lower(name) LIKE '%philips%' THEN 'Phillips'
        WHEN lower(name) LIKE 'levi%' THEN 'Levis'
        WHEN lower(name) LIKE 'jbl%' THEN 'JBL'
        WHEN lower(name) LIKE '%motorola%' THEN 'Motorola'
        WHEN lower(name) LIKE 'tommy%' THEN 'TH'
        ELSE 'Unknown' end as brand,
	  CASE
        WHEN material IS NULL THEN 'UNKNOWN'
        ELSE initcap (material),
	  CASE
        WHEN color IS NULL THEN 'UNKNOWN'
        ELSE initcap (color),
	  from stg.product_master
  )
insert into dim.product_master(product_code, name, category, subcategory, subsubcategory, material, color, origen, ean, is_active, has_bluetooth, size, brand)
select * from cte
  on conflict (product_code) do update
  set product_code = excluded.product_code;
  call etl.log(current_date, 'product_master','usuario'); -- SP dentro del SP product_master para dejar log
END;
$$;