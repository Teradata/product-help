DROP TABLE retail_sample_data.ev_dealers ;

CREATE MULTISET FOREIGN TABLE retail_sample_data.ev_dealers , FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      Id INTEGER NOT NULL,
      Company VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      StreetAddress VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      City VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      State VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      ZipCode INTEGER,
      Country VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      EmailAddress VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      TelephoneNumber VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      DomainName VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      Latitude FLOAT,
      Longitude FLOAT
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/EVCarBattery/dealers.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;