DROP TABLE retail_sample_data.fp_consumer_complaints ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.fp_consumer_complaints ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      date_received DATE FORMAT 'yyyy-mm-dd',
      product VARCHAR(76) CHARACTER SET LATIN NOT CASESPECIFIC,
      sub_product VARCHAR(42) CHARACTER SET LATIN NOT CASESPECIFIC,
      issue VARCHAR(80) CHARACTER SET LATIN NOT CASESPECIFIC,
      sub_issue VARCHAR(80) CHARACTER SET LATIN NOT CASESPECIFIC,
      consumer_complaint_narrative VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      company_public_response VARCHAR(119) CHARACTER SET LATIN NOT CASESPECIFIC,
      company VARCHAR(46) CHARACTER SET LATIN NOT CASESPECIFIC,
      state VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      zip_code VARCHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC,
      tags VARCHAR(29) CHARACTER SET LATIN NOT CASESPECIFIC,
      consumer_consent_provided VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      submitted_via VARCHAR(11) CHARACTER SET LATIN NOT CASESPECIFIC,
      date_sent_to_company DATE FORMAT 'yyyy-mm-dd',
      company_response_to_consumer VARCHAR(31) CHARACTER SET LATIN NOT CASESPECIFIC,
      timely_response VARCHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC,
      consumer_disputed VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      complaint_id INTEGER)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/FinancialProtection/consumer_complaints/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;