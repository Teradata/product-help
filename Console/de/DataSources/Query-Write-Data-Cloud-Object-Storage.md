Native Object Store-Integration mit Cloud-Objektspeicher
========================================================

-   [Daten von einem Cloud-Objektspeicher abfragen](#query-data-on-cloud-object-storage)
-   [Daten in einen Cloud-Objektspeicher schreiben](#write-data-to-a-cloud-object-store)

Daten von einem Cloud-Objektspeicher abfragen
---------------------------------------------

### Einführung

Die folgenden Beispiele zeigen, wie Sie auf Daten zugreifen können, die in Cloud-Objektspeichern gespeichert sind. Sie können die folgenden Beispielabfragen kopieren und ändern, um auf Ihre eigenen Datensätze zuzugreifen. Der Einfachheit halber werden die Beispieldatensätze über einen öffentlichen Zugriffs-Bucket bereitgestellt, für den keine Einrichtung oder Anmeldedaten erforderlich sind.

Um SQL für den Zugriff auf Ihren eigenen Cloud-Objektspeicher zu verwenden, ersetzen Sie Folgendes: \* **LOCATION** – Geben Sie den Speicherort Ihres Objektspeichers an. Der Speicherort muss mit /s3/ (Amazon) oder /az/ (Azure) beginnen \* **AUTHORIZATION** - Ersetzen Sie die leeren **USER**- und **PASSWORD**-Anmeldedaten mit **ACCESS\_KEY\_ID** und **SECRET\_ACCESS-KEY**.

**Hinweis**: Der Parameter AUTHORIZATION ist nur erforderlich, wenn Sie keine IAM-Rollen und -Richtlinien zur Verwaltung der Sicherheit verwenden.

Cloud-Objektspeicherdaten werden gelesen
----------------------------------------

Die Dateiformate Parquet, CSV und JSON werden beim Lesen aus einem Cloud-Objektspeicher unterstützt. Sie können Daten aus einem Cloud-Objektspeicher mit READ\_NOS oder fremden Tabellen lesen.

#### READ\_NOS

Mit READ\_NOS können Sie Folgendes tun, ohne Änderungen an der Datenbank vornehmen zu müssen: \* Ad-hoc-Abfrage von Daten, die in einem Cloud-Objektspeicher gespeichert sind \* Untersuchung des Schemas der Datendateien

#### Fremdtabellen

Mit der Berechtigung CREATE TABLE können Sie eine Fremdtabelle innerhalb der Datenbank erstellen, die eine ähnliche Erfahrung wie die Arbeit mit lokalen relationalen Tabellen bietet. Mit einer Fremdtabelle können Sie Folgendes tun: \* Laden externer Daten in die Datenbank \* Verbinden externer Daten mit in der Datenbank gespeicherten Daten \* Filtern der Daten \* Verwenden von Ansichten, um die Darstellung der Daten für die Benutzer zu vereinfachen

Daten, die mit Native Object Store gelesen werden, werden nie aufbewahrt.

Mit den Anweisungen INSERT SELECT und CREATE TABLE AS ... WITH DATA können Daten in die Datenbank geladen werden.

### Gesicherte Anmeldedaten mit einem Autorisierungsobjekt einrichten

Durch die Erstellung eines Autorisierungsobjekts können Sie die Anmeldedaten für Ihren Cloud-Objektspeicher in Vantage sicher speichern und referenzieren. Beachten Sie, dass unsere Beispieldatensätze Ihnen über einen öffentlichen Zugriffsbereich zur Verfügung gestellt werden, für den keine Anmeldedaten erforderlich sind.

    CREATE AUTHORIZATION InvAuth
    USER ''
    PASSWORD '';

### Auf Amazon S3 gespeicherte Daten mit READ\_NOS lesen

Wählen Sie mit READ\_NOS Daten aus dem Cloud-Objektspeicher aus:

    SELECT TOP 2 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    ) AS D;

### Das Schema von auf Amazon S3 gespeicherten Daten mit READ\_NOS untersuchen

Wählen Sie mit READ\_NOS nur das Schema der Daten aus dem Cloud-Objektspeicher aus:

    SELECT TOP 1 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    RETURNTYPE='NOSREAD_SCHEMA'
    ) AS d;

### Auf Amazon S3 gespeicherte Daten mit CREATE FOREIGN TABLE lesen

Eine Fremdtabelle erstellen:

    CREATE FOREIGN TABLE sample_data
    ,EXTERNAL SECURITY InvAuth
    USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );

Daten mit der Fremdtabelle auswählen:

    SELECT TOP 2 * FROM sample_data;

### Daten in Vantage aus auf Amazon S3 gespeicherten Daten importieren

Um Daten aus einem Cloud-Objektspeicher aufzubewahren, verwenden Sie eine CREATE TABLE AS-Anweisung:

    CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;

Daten in einen Cloud-Objektspeicher schreiben
---------------------------------------------

### Einführung

Die folgenden Beispiele zeigen, wie Sie Daten aus Vantage in einen Cloud-Objektspeicher kopieren. Sie müssen Ihren eigenen Bucket bereitstellen, um die Beispielabfragen auszuführen.

### WRITE\_NOS

Mit WRITE\_NOS können Sie Folgendes tun: \* Daten direkt in einen Cloud-Objektspeicher kopieren/schreiben \* Daten in das nicht komprimierte Parquet-Format konvertieren, es sei denn, der Benutzer hat eine Snappy-Komprimierung angegeben \* eine oder mehrere Spalten in der Quelltabelle als Partitionsattribute im Ziel-Cloud-Objektspeicher angeben \* eine Manifestdatei mit allen während des Kopiervorgangs erstellten Objekten erstellen und aktualisieren

Bevor Sie die Beispiele ausführen, ersetzen Sie die folgenden Felder in den Beispielskripten: \* *YourBucketName*: mit dem Namen Ihres Buckets \* *AccessID*: aus dem Zugriffsschlüssel für Ihren Bucket – Beispiel für eine Zugriffsschlüssel-ID: AKIAIOSFODNN7EXAMPLE \* *AccessKey*: aus dem Zugriffsschlüssel für Ihren Bucket – Beispiel für einen geheimen Zugangsschlüssel: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Tipp**: Als Alternative zu den *AccessID*- und *AccessKey*-Zeilen können Sie ein Berechtigungsobjekt erstellen, um die Anmeldeinformationen Ihres Cloud-Objektspeichers sicher zu verbergen.

#### Beispiel 1

In diesem Beispiel werden alle Zeilen im lokalen sample\_data\_local ausgewählt, um den Datensatz in die *sample1*-Partition des Objektspeichers zu kopieren:

    SELECT * FROM WRITE_NOS (
        ON ( SELECT * FROM sample_data_local )
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)        
            STOREDAS ('PARQUET')
    ) AS d;

#### Beispiel 2

In diesem Beispiel wird derselbe Datensatz durch Partitionierung nach dem Sensordatenjahr unter der Partition *sample2* kopiert:

    SELECT * FROM WRITE_NOS (
        ON ( SELECT
                sensdate
                ,senstime
                ,epoch
                ,moteid
                ,temperature
                ,humidity
                ,light
                ,voltage
                ,sensdatetime
                ,year(sensdate) TheYear
             FROM sample_data_local )
        PARTITION BY TheYear ORDER BY TheYear
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)              
            NAMING ('DISCRETE')
            INCLUDE_ORDERING ('FALSE')
            STOREDAS ('PARQUET')
     AS d;

### WRITE\_NOS-Ergebnisse validieren

Sie können die Ergebnisse Ihrer WRITE\_NOS-Anwendungsfälle validieren, indem Sie Ihre Parquet-Daten lesen, wie in den READ\_NOS-Beispielen hier beschrieben: [Auf Amazon S3 gespeicherte Daten mit READ\_NOS lesen](#read-data-stored-on-amazon-s3-using-read_nos)

### Bereinigen

Löschen Sie die in Ihrem eigenen Datenbankschema erstellten Objekte:

    DROP AUTHORIZATION InvAuth;
    DROP TABLE sample_data;
    DROP TABLE sample_data_local;
