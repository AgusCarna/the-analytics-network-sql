-- Table: dim.fx_rate

DROP TABLE IF EXISTS dim.fx_rate;

CREATE TABLE IF NOT EXISTS dim.fx_rate
(
                              month        DATE
                            , fx_rate_usd_peso DECIMAL
                            , fx_rate_usd_eur DECIMAL
                            , fx_rate_usd_uru  DECIMAL
);