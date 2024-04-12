REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE demo_telco_testing ;
CREATE MULTISET FOREIGN TABLE demo_telco_testing ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
( 
	cust_id                 	VARCHAR(20),
	churn_flag              	CHAR(1),
	plan_rate               	INTEGER,
	cust_days               	INTEGER,
	age                     	INTEGER,
	region                  	VARCHAR(20),
	months_from_contract_end	INTEGER,
	voice_calls_avg         	DECIMAL(5,0),
	voice_minutes_avg       	DECIMAL(5,0),
	data_usage_avg          	DECIMAL(5,0),
	sms_usage_avg           	DECIMAL(5,0),
	voicemail_calls         	DECIMAL(5,0),
	support_calls           	DECIMAL(5,0),
	support_minutes         	DECIMAL(5,0),
	bill_dispute            	INTEGER 
	)USING
(
	LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/Demo/telco_testing.csv')
	MANIFEST  ('FALSE')
	ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
	STOREDAS  ('TEXTFILE')
	HEADER  ('FALSE')
	STRIP_EXTERIOR_SPACES  ('FALSE')
	STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
