create or replace procedure etl.sp_dim_date()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
  	select date, month, year, initcap (weekday) as weekday, is_weekend, initcap (month_label) as month_label, 
	 	fiscal_year_label, fiscal_quarter_label, date_ly
	from stg.date
  )
insert into dim.date(date, month, year, weekday, is_weekend, month_label, fiscal_year_label, fiscal_quarter_label, date_ly)
select * from cte
  call etl.log(current_date, 'date','usuario'); -- SP dentro del SP date para dejar log
END;
$$;
