create or replace procedure etl.sp_dim_cost()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
  select *
	from stg.cost
  )
insert into dim.cost(product_id, cost_usd)
select * from cte
  --on conflict (product_code) do update
  --set product_code = excluded.product_code;
  call etl.log(current_date, 'cost','usuario'); -- SP dentro del SP cost para dejar log
END;
$$;
