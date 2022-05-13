DROP TABLE retail_sample_data.bof_merchant ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.bof_merchant ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      merchant_id INTEGER,
      merchant_name VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
      streetaddress VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      city VARCHAR(90) CHARACTER SET UNICODE NOT CASESPECIFIC,
      state VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
      state_full VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
      postcode VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      country VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      country_full VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
      phone VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      phone_country_code VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      latitude FLOAT,
      longitude FLOAT)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/merchant.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;