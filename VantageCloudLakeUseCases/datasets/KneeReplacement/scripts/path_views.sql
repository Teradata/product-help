-- Views for the Path Analyzer
CREATE VIEW knee_replacement_events AS
SELECT memberid as entity_id, tstamp AS datestamp, shortdesc as event,
memberid, proccode, diagcode, shortdesc, amount, tstamp, firstname, lastname, email, state        
FROM knee_replacement;
