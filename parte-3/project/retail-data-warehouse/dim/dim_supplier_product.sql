-- Table: dim.supplier_product

DROP TABLE IF EXISTS dim.supplier_product;

CREATE TABLE IF NOT EXISTS dim.supplier_product
(
    product_id varchar(255) PRIMARY KEY,
    name varchar(255),
    is_primary boolean
);