-- Table: fct.shrinkage

DROP TABLE IF EXISTS fct.shrinkage;

CREATE TABLE IF NOT EXISTS fct.shrinkage
(
		 	                        year        numeric
                            , store_id    SMALLINT
                            , item_id     VARCHAR(10)
                            , quantity    integer
                            , constraint fk_store_id
                              		foreign key (store_id)
                              		references dim.store_master(store_id)
                            , constraint fk_item_id
                              		foreign key (item_id)
                              		references dim.product_master(product_id)
);
