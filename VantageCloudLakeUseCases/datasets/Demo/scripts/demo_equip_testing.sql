DROP TABLE retail_sample_data.demo_equip_testing ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.demo_equip_testing ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
(
    equipment_id              VARCHAR(20),
    model_name                INTEGER,
    age_days                  INTEGER,
    onsite_days               INTEGER,
    last_repair_cd            VARCHAR(20),
    days_since_last_repair    INTEGER,
    operating_days            DECIMAL(7,0),
    operating_hours           DECIMAL(5,0),
    equip_work_cycles         DECIMAL(5,0),
    cnt_pump_threshold_events DECIMAL(5,0),
    cnt_repair_events         DECIMAL(5,0),
    cnt_load_threshold_events DECIMAL(5,0),
    breakdown_next_30_ind     INTEGER
)USING
(
	LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/Demo/demo_equip_testing/')
	MANIFEST  ('FALSE')
	ROWFORMAT  ('{"field_delimiter":" ","record_delimiter":"\n","character_set":"LATIN"}')
	STOREDAS  ('TEXTFILE')
	HEADER  ('FALSE')
	STRIP_EXTERIOR_SPACES  ('FALSE')
	STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;