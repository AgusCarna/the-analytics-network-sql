/*Creación función de conversión*/
create function analytics.conversion(currency character varying(3), valor numeric, rate_peso numeric, rate_eur numeric, rate_uru numeric) 
returns numeric as
$$
select
		case
			when currency = 'ARS'
			then valor/rate_peso
			when currency = 'EUR'
			then valor/rate_eur
			when currency = 'URU'
			then valor/rate_uru
			else valor
			end as valor_usd
$$ language sql;
