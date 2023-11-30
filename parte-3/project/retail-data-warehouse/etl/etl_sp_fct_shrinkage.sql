create or replace procedure etl.sp_fct_shrinkage()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select *
	  from stg.shrinkage
 --   where date > (select max (year))
  )
insert into fct.shrinkage (year, store_id, item_id, quantity)
select * from cte;
  call etl.log('fct.shrinkage',current_date, 'sp_fct_shrinkage','usuario'); -- SP dentro del SP shrinkage para dejar log
END;
$$;
