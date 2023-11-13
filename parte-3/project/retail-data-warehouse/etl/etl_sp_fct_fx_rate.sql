create or replace procedure etl.sp_fct_rate()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select *
	  from stg.monthly_average_fx_rate
    where date > '2023-11-01' --> u otra fecha donde empiece me interese empezar a considerar
  )
insert into fct.fx_rate (month, fx_rate_usd_peso, fx_rate_usd_eur, fx_rate_usd_uru)
select * from cte;
  call etl.log('fct.fx_rate',current_date, 'sp_fct_rate','usuario'); -- SP dentro del SP rate para dejar log
END;
$$;
