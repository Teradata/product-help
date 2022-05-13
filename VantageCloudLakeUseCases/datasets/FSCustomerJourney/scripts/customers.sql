DROP TABLE retail_sample_data.fscj_customers ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.fscj_customers ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
     id BIGINT,
     customer_identifier VARCHAR(26),
     firstname VARCHAR(50),
     lastname VARCHAR(90),
     email VARCHAR(90),
     phone VARCHAR(50),
     birthday VARCHAR(10),
     streetaddress VARCHAR(200),
     city VARCHAR(90),
     state VARCHAR(50),
     zipcode VARCHAR(10),
     latitude FLOAT,
     longitude FLOAT,
     num_accounts INTEGER)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/FSCustomerJourney/customers.csv')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;