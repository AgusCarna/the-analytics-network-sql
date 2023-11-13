create or replace procedure etl.sp_fct_return_movements()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select *
	  from stg.return_movements
    where date > '2023-11-01' --> u otra fecha donde empiece me interese empezar a considerar
  )
insert into fct.return_movements (order_id, return_id, item, quantity, movement_id, from_location, to_location, received_by, date)
select * from cte
  call etl.log('fct.return_movements',current_date, 'sp_fct_return_movements','usuario'); -- SP dentro del SP return_movements para dejar log
END;
$$;
