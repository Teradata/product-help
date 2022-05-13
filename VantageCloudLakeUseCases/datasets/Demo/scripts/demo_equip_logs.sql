DROP TABLE retail_sample_data.demo_equip_logs ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.demo_equip_logs ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
(
    equipment_id   VARCHAR(20),
    service_date   DATE FORMAT 'YY/MM/DD',
    model          VARCHAR(10),
    description    VARCHAR(500)
)USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/Demo/demo_equip_logs.txt')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":" ","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;