create or replace procedure etl.sp_dim_supplier_product()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
  	select *
	from stg.suppliers
	where is_primary is true
  )
insert into dim.supplier_product(product_id, name, is_primary)
select * from cte where is_primary is true
 -- on conflict (product_code) do update
 -- set product_code = excluded.product_code;
  call etl.log(current_date, 'supplier_product','usuario'); -- SP dentro del SP supplier_product para dejar log
END;
$$;
