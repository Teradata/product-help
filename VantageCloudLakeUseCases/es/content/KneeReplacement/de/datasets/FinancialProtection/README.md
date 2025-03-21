FinancialProtection-Datensatz
=============================

Der FinancialProtection-Datensatz wird in Anwendungsfällen des finanziellen Schutzes verwendet.

So aktualisieren Sie die Daten in S3

    aws s3 rm s3://${S3_BUCKET}/FinancialProtection --recursive   

    aws s3 cp data/* s3://${S3_BUCKET}/FinancialProtection/ 

Da wir eine Autorisierung verwenden, ist dies nicht erforderlich. Wenn wir die Dateien jedoch öffentlich zugänglich machen möchten, fügen wir dies dem S3-CP-Aufruf hinzu.

    --acl public-read    

Die SQL-Dateien im Skriptordner sind idempotent, was bedeutet, dass sie unabhängig davon, wie oft Sie sie ausführen, erneut ausgeführt werden können und der Status der Tabellen nach jedem Durchlauf derselbe ist. Um dies zu erreichen, löschen wir die Objekte und erstellen sie bei jedem Durchlauf neu. Wenn die Abfrage zum Löschen des Objekts ausgeführt wird, ignorieren wir alle Fehler, dass das Objekt nicht existiert, aber wir sollten Fehler behandeln, bei denen der Benutzer nicht über die richtigen Berechtigungen verfügt.
