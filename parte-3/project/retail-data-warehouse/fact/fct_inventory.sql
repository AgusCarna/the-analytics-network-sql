-- Table: fct.inventory

DROP TABLE IF EXISTS fct.inventory;

CREATE TABLE IF NOT EXISTS fct.inventory
(
		 	      date        DATE
                            , store_id    SMALLINT
                            , item_id     VARCHAR(10)
                            , initial     SMALLINT
                            , final       SMALLINT
			    , PRIMARY KEY (date, store_id, item_id)
                            , constraint fk_store_id
                              		foreign key (store_id)
                              		references dim.store_master(store_id)
                            , constraint fk_item_id
                              		foreign key (item_id)
                              		references dim.product_master(product_id)
);
