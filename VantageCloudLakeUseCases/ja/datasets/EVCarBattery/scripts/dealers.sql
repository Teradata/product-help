DROP TABLE ev_dealers ;

CREATE MULTISET FOREIGN TABLE ev_dealers , FALLBACK ,
     EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS ,
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
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/dealers.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;