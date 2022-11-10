DROP TABLE demo_titan_telco_events ;
CREATE MULTISET FOREIGN TABLE demo_titan_telco_events ,FALLBACK ,
     EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS ,
     MAP = TD_MAP1 
	( 
	entity_id 	VARCHAR(20),
	datestamp 	TIMESTAMP(6),
	session_id	INTEGER,
	channel		VARCHAR(100),
	event     	VARCHAR(100) )
USING
(
	LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/Demo/titan_telco_events/')
	MANIFEST  ('FALSE')
	ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
	STOREDAS  ('TEXTFILE')
	HEADER  ('FALSE')
	STRIP_EXTERIOR_SPACES  ('FALSE')
	STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;