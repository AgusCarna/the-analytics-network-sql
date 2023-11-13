-- Table: log.table_updates

DROP TABLE IF EXISTS log.table_updates;

CREATE TABLE IF NOT EXISTS log.table_updates
(
                            table_name          VARCHAR(30)
                          , date                date
                          , stored_procedure    VARCHAR(30)
                          , username            VARCHAR(30)
);
