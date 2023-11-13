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
select * from cte where is_primary is true;
  call etl.log('dim.supplier_product',current_date, 'sp_dim_supplier_product','usuario'); -- SP dentro del SP supplier_product para dejar log
END;
$$;
