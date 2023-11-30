create or replace procedure etl.sp_fct_store_traffic()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select store_id, cast (date as date) as date, traffic
	  from stg.super_store_count
    where date > (select max (date))
  )
insert into fct.store_traffic(store_id, date, traffic)
select * from cte;
  call etl.log('fct.store_traffic',current_date, 'sp_fct_store_traffic','usuario'); -- SP dentro del SP store_traffic para dejar log
END;
$$;
