create or replace procedure etl.sp_fct_inventory()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select *
	  from stg.inventory
    where date > '2023-11-01' --> u otra fecha donde empiece me interese empezar a considerar
  )
insert into fct.inventory (date, store_id, item_id, initial, final)
select * from cte
  call etl.log('fct.inventory',current_date, 'sp_fct_inventory','usuario'); -- SP dentro del SP inventory para dejar log
END;
$$;
