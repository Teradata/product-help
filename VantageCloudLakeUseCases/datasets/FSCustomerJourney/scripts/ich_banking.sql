DROP TABLE retail_sample_data.fscj_ich_banking ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.fscj_ich_banking ,FALLBACK ,
    EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
	MAP = TD_MAP1  
	( 
	customer_skey             	integer,
	customer_identifier       	varchar(26),
	customer_cookie           	varchar(50),
	customer_online_id        	varchar(3),
	customer_offline_id       	integer,
	customer_type             	varchar(90),
	customer_days_active      	integer,
	interaction_session_number  	bigint,
	interaction_timestamp     	timestamp with time zone,
	interaction_source        	varchar(100),
	interaction_type          	varchar(100),
	sales_channel    		varchar(100),
	conversion_id             	varchar(50),
	product_category          	varchar(90),
	product_type              	varchar(90),
	conversion_sales          	number(15,2),
	conversion_cost           	number(15,2),
	conversion_margin         	number(15,2),
	conversion_units          	number(15,2),
	marketing_code            	varchar(50),
	marketing_category        	varchar(50),
	marketing_description     	varchar(50),
	marketing_placement       	varchar(50),
    mobile_flag                 char(1),
    updt						varchar(50)
	)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/FSCustomerJourney/ich_banking/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;