create or replace procedure etl.sp_fct_order_line_sale()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  usuario := current_user; 
  with cte as (
    select *
	  from stg.order_line_sale
    where date > '2023-11-01' --> u otra fecha donde empiece me interese empezar a considerar
  )
insert into fct.order_line_sale (order_id, product_id, store_id, date, quantity, sale, 
            promotion, tax, credit, currency, pos, is_walkout, line_key)
select * from cte;
  call etl.log('fct.order_line_sale',current_date, 'sp_fct_order_line_sale','usuario'); -- SP dentro del SP order_line_sale para dejar log
END;
$$;
