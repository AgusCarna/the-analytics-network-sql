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
	  on conflict (product_id) do update
 	 set cost_usd = excluded.cost_usd;
select * from cte;
  call etl.log('dim.cost',current_date, 'sp_dim_cost','usuario'); -- SP dentro del SP cost para dejar log
END;
$$;
