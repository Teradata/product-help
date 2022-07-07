DROP TABLE retail_sample_data.obd_nos;

CREATE FOREIGN TABLE retail_sample_data.obd_nos, FALLBACK,
EXTERNAL SECURITY DEMO_AUTH_NOS
(
LOCATION VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC , Payload JSON INLINE LENGTH 32000 CHARACTER SET UNICODE )
USING(LOCATION('/S3/s3.amazonaws.com/trial-datasets/EVCarBattery/') );


REPLACE VIEW retail_sample_data.nos_test_reports_v AS
(SELECT vin, part_no, lot_no, CAST(test_report AS JSON) test_report
FROM TD_JSONSHRED(
    ON (
                SELECT payload.vin as vin, payload
                FROM retail_sample_data.obd_nos)
            USING
            ROWEXPR('parts')
            COLEXPR('part_no', 'lot_no', 'test_report')
            RETURNTYPES('VARCHAR(17)', 'VARCHAR(1000)', 'VARCHAR(10000)')
        ) AS d1 (vin, part_no, lot_no, test_report)
    );
