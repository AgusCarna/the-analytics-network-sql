--/*CREO TABLA DE LOGS*/
CREATE TABLE etl.log
                 (
                              fecha date
                            , tabla          VARCHAR(255)
                            , usuario       VARCHAR(255)
					 )

--/Creo stored procedure/
create or replace procedure etl.log(parametro_fecha date, parametro_tabla varchar(10), parametro_usuario varchar(10))
language sql as $$
insert into etl.log (fecha,tabla,usuario) 
select parametro_fecha, parametro_tabla, parametro_usuario
; 
$$;
