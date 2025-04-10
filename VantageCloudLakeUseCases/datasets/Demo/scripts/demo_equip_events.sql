REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE demo_equip_events ;
CREATE MULTISET FOREIGN TABLE demo_equip_events ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
	(
		entity_id VARCHAR(100),
		datestamp TIMESTAMP(6),
		event VARCHAR(200) CHARACTER SET LATIN)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/Demo/demo_equip_events.txt')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":" ","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
