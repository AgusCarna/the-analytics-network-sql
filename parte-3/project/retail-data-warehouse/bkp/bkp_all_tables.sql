create or replace procedure bkp.sp_all_tables()
language plpgsql as $$
DECLARE
  usuario varchar(10) := current_user ;
BEGIN
  select * into bkp.cost from dim.cost
  select * into bkp.date from dim.date
  select * into bkp.employee from dim.employee
  select * into bkp.product_master from dim.product_master
  select * into bkp.store_master from dim.store_master
  select * into bkp.supplier_product from dim.supplier_product
  select * into bkp.fx_rate from fct.fx_rate
  select * into bkp.inventory from fct.inventory 
  select * into bkp.order_line_sale from fct.order_line_sale 
  select * into bkp.return_movements from fct.return_movements 
  select * into bkp.store_traffic from fct.store_traffic 
  call etl.log(current_date, 'bkp_total','usuario'); -- SP dentro del SP bkp_total para dejar log
END;
$$;
