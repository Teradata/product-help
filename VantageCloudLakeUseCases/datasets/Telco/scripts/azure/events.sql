DROP TABLE telco_events ;

CREATE MULTISET FOREIGN TABLE telco_events , FALLBACK ,
--     EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      entity_id VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      datestamp TIMESTAMP(6),
      session_id INTEGER,
      event VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC)
USING
(
      LOCATION  ('/az/usecaseteststorage.blob.core.windows.net/product-help/VantageCloudLakeUseCases/datasets/Telco/data/events/')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;