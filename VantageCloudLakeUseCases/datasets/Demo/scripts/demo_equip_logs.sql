REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE demo_equip_logs ;
CREATE MULTISET FOREIGN TABLE demo_equip_logs ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
(
    equipment_id   VARCHAR(20),
    service_date   DATE FORMAT 'YY/MM/DD',
    model          VARCHAR(10),
    description    VARCHAR(500)
)USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/Demo/demo_equip_logs.txt')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":" ","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
