--/*CREO TABLA DE LOGS*/
CREATE TABLE etl.log
                 (
                              fecha date
                            , tabla          VARCHAR(255)
                            , usuario       VARCHAR(255)
					 )

--/Creo stored procedure/
create or replace procedure etl.log(parametro_tabla VARCHAR(30), parametro_fecha date, parametro_sp varchar(10), parametro_usuario varchar(10))
language sql as $$
insert into log.table_updates (table_name, date, stored_procedure, username) 
select parametro_tabla, parametro_fecha, parametro_tabla, parametro_usuario
; 
$$;
