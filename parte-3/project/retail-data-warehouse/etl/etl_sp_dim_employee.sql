create or replace procedure etl.sp_dim_employee()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
      select id, name, surname, start_date, end_date,
        	case
          		when end_date is null then current_date-start_date
          		else end_date-start_date
          		end as duration,
          phone, country, province, store_id, position,
        	case
          		when end_date is null then true
          		else false
          		end as is_active
	    from stg.employees
  )
insert into dim.employee(id, name, surname, start_date, end_date, duration, phone, country, province, store_id, position, active)
select * from cte;
  call etl.log('dim.employee',current_date, 'sp_dim_employee','usuario'); -- SP dentro del SP employee para dejar log
END;
$$;
