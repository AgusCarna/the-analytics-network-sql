--Modifico la stg.date para que pase a tener un rango de 5 años mediante un truncate & insert

truncate stg.date 

insert into stg.date 
select
	date_in as date,
	extract(month from date_in) as month,
	extract(year from date_in) as year,
	to_char(date_in, 'day') as weekday,
	case
		WHEN extract(dow FROM date_in) IN (0, 6) THEN 'true'
		else false
		end as is_weekend,
	to_char(date_in, 'month') as month_label,
	case
		when extract (month from date_in) in (1) then concat ('FY',cast(((extract(year from date_in))-1) as text))
		else concat ('FY',cast((extract(year from date_in)) as text))
		end as fiscal_year_label,
	case
		when extract (month from date_in) in (2,3,4) then 'Q1'
		when extract (month from date_in) in (5,6,7) then 'Q2'
		when extract (month from date_in) in (8,9,10) then 'Q3'
		when extract (month from date_in) in (11,12,1) then 'Q4'
		end as fiscal_quarter_label,
	(date_trunc('year', date_in) - interval '1 year') + (date_in - DATE_TRUNC('year', date_in)) AS date_ly	
from
	(select cast ('2022-01-01' as date) + (n || 'day')::interval as date_in
	from generate_series (0,1825) n );

--Creamos el stored procedure llamando a la tabla de stg actualizada
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
	on conflict (date)
	do nothing;
  call etl.log('dim.date',current_date, 'sp_dim_date','usuario'); -- SP dentro del SP date para dejar log
END;
$$;
