Arbeiten mit externen Objektspeichern: Lesen und Schreiben von Daten
--------------------------------------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

In diesem Abschnitt wird gezeigt, wie Benutzer mit offenen Objektspeichern interagieren können. Teradata VantageCloud Lake bietet native Funktionen zum Lesen und Schreiben von Daten in diese skalierbaren, kostengünstigen Datenspeicher. So können Benutzer problemlos große Datenmengen in Data Lakes integrieren und Archivdaten oder andere Daten auf diese Plattformen auslagern.

Zu Evaluierungszwecken hat Teradata Daten in einem offenen Objektspeicherort bereitgestellt. Für die Verwendung in der Praxis sollten Benutzer Anmeldeinformationen oder andere rollenbasierte Zugriffsrechte auf den Objektspeicher angeben. Wenn Sie Ihren eigenen Objektspeicher zum Abfragen von Daten verwenden möchten, ersetzen Sie Folgendes im SQL-Code:

-   **LOCATION** – Verwenden Sie stattdessen den Speicherort Ihres Objektspeichers. Der Speicherort muss mit /s3/ (Amazon), /az/ (Azure) oder /gs/ (Google) beginnen.
-   **USER** oder **ACCESS\_ID** – Fügen Sie den Benutzernamen für Ihren Objektspeicher hinzu.
-   **PASSWORD** oder **ACCESS\_KEY** – Fügen Sie das Passwort des Benutzers in Ihrem Objektspeicher hinzu.
-   **SESSION\_TOKEN** – Sie können auch ein optionales Sitzungstoken hinzufügen, wenn Sie den AWS Security Token Service verwenden, um die Zugangsdaten bereitzustellen.
-   Entfernen Sie bei Bedarf die Kommentarzeichen aus der Klausel EXTERNAL SECURITY.

Wenn Sie die SQL-Abfrage ändern, um auf Ihre eigenen Daten in Ihrem Objektspeicher zuzugreifen, stellen Sie sicher, dass er so konfiguriert ist, dass er den Zugriff aus der VantageCloud Lake-Umgebung zulässt. Geben Sie die richtigen Anmeldeinformationen in den Elementen USER und PASSWORD in der Anweisung CREATE AUTHORIZATION oder im JSON-Zeichenfolgenargument des in der Anweisung READ\_NOS verwendeten AUTHORIZATION-Elements an.

Um diese Anwendungsfälle auszuführen, benötigt der Benutzer spezielle Berechtigungen für die SQL-Funktionen, die zum Lesen und Schreiben in externen Objektspeichern verwendet werden. Führen Sie die folgenden Anweisungen als Datenbankbenutzer mit Administratorberechtigungen aus oder bitten Sie einen Datenbankadministrator, sie für Sie auszuführen.

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### Zugreifen auf den Objektspeicher

Es gibt zwei Möglichkeiten, Daten aus einem Objektspeicher zu lesen:

#### READ\_NOS

Der READ\_NOS-Tabellenoperator ist eine Funktion, die Benutzern Folgendes ermöglicht: \* Eine Ad-hoc-Abfrage für Daten in den Formaten Parquet, CSV und JSON mit den Daten an Ort und Stelle in einem Objektspeicher durchzuführen \* Die Struktur (das Layout) des Objektspeichers zu untersuchen \* Das Schema der formatierten Daten zu untersuchen

``` sourceCode
--This SQL statement will query ten rows of data from the s3 bucket 
--defined in the LOCATION element 
SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
  ) AS D; 

--By adding a RETURNTYPE element, and passing either 
-- ‘NOSREAD_KEYS' or ‘NOSREAD_SCHEMA’ arguments 
--users can investigate the objects and structure of the data 
SELECT TOP 10 * FROM (
    LOCATION = '/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_KEYS' 
  ) AS D; 

SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_SCHEMA'
  ) AS D; 
```

### Beim Zugriff auf Ihre eigenen Daten

Um auf externe Objektspeicher zuzugreifen, die eine Authentifizierung erfordern, erstellen Sie ein Autorisierungsobjekt. Dieses Objekt enthält die Anmeldeinformationen (Benutzername, Passwort, Sitzungstoken, Identity and Access Management (IAM) usw.), die die Datenbank zum Lesen (und/oder Schreiben) von Daten benötigt. Mit der folgenden Anweisung können Sie ein Autorisierungsobjekt erstellen, das die Anmeldeinformationen für Ihren externen Objektspeicher enthält. Alternativ können die Anmeldeinformationen als JSON-formatierte Zeichenfolge an das AUTHORIZATION-Element der Abfrage übergeben werden.

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Verwendung einer Autorisierung für den Zugriff auf Daten, die auf Amazon S3 gespeichert sind

``` sourceCode
SELECT TOP 2 * FROM ( 
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}' 
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials] 
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store] 
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files]  
) AS D; 
```

#### Fremdtabellen

Fremdtabellen ermöglichen VantageCloud Lake den Zugriff auf Daten in externen Objektspeichern, wie z. B. halbstrukturierte und unstrukturierte Daten in Amazon S3, Microsoft Azure Blob Storage und Google Cloud Storage. Die Integration dieser Daten in die Datenbank ermöglicht es Data Scientists und Analysten, diese Daten mit VantageCloud Lake unter Verwendung von Standard-SQL zu lesen und zu verarbeiten. Sie können externe Daten mit relationalen Daten in VantageCloud Lake verknüpfen und sie mithilfe integrierter VantageCloud Lake-Analysen und -Funktionen verarbeiten.

Daten, die über eine Fremdtabelle gelesen werden, werden nicht beibehalten und können nur von dieser Abfrage verwendet werden.

Daten können in die Datenbank geladen werden, indem Sie in einer CREATE TABLE AS ... WITH DATA-Anweisung aus READ\_NOS oder einer Fremdtabelle auswählen.

### Zugriff auf in Amazon S3 gespeicherte Daten mit CREATE FOREIGN TABLE

Erstellen Sie eine Fremdtabelle:

``` sourceCode
CREATE MULTISET FOREIGN TABLE sample_sensor ,FALLBACK,
     EXTERNAL SECURITY MyAuth
    (
        sensedate DATE,
        sensetime TIME,
        epoch INTEGER,
        moteid INTEGER,
        temperature FLOAT,
        humidity FLOAT,
        light FLOAT,
        voltage FLOAT
    )
USING
    (
        LOCATION  ('/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/')
        MANIFEST  ('FALSE')
        ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
        STOREDAS  ('TEXTFILE')
        HEADER  ('FALSE')
        STRIP_EXTERIOR_SPACES  ('FALSE')
    )
NO PRIMARY INDEX ;
```

Zeigen Sie einige Daten mithilfe der Fremdtabelle an:

``` sourceCode
SELECT TOP 2 * FROM sample_sensor;
```

### Importieren von Daten in VantageCloud Lake aus in Amazon S3 gespeicherten Daten

Um die Daten aus einem Objektspeicher zu speichern, können wir eine CREATE TABLE AS-Anweisung wie folgt verwenden. Betten Sie die READ\_NOS SELECT-Anweisung in CREATE TABLE AS ein und achten Sie darauf, WITH DATA einzuschließen, um alle Zeilen in eine lokale Tabelle einzufügen:

``` sourceCode
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

Schreiben von Daten in einen Objektspeicher
-------------------------------------------

### Einführung

Nachfolgend finden Sie eine Zusammenfassung darüber, wie Sie Daten aus VantageCloud Lake in einen Objektspeicher kopieren. Sie müssen Ihren eigenen Bucket und Ihre eigenen Anmeldeinformationen (oder Ihr Autorisierungsobjekt) angeben, um die folgenden Beispielabfragen auszuführen.

Die WRITE\_NOS-Abfrage gibt die Liste der Objekte und deren Metadaten zurück, die in den Zielobjektspeicher geschrieben wurden. Diese Ergebnisse sind nützlich für die Protokollierung/Rückverfolgbarkeit und andere administrative und verwaltungstechnische Anwendungsfälle.

#### WRITE\_NOS

WRITE\_NOS ermöglicht Ihnen: \* Daten direkt in einen Objektspeicher zu kopieren/schreiben \* Daten optional zu komprimieren \* Eine oder mehrere Spalten in der Quelltabelle als Partitionsattribute im Zielobjektspeicher anzugeben. Partitionsattribute werden verwendet, um beim Schreiben der Daten zusätzliche Objektschlüssel zu generieren. Diese Schlüssel können zur effizienten Datenorganisation und zum Filtern für andere Systeme verwendet werden, die die Objekte lesen. \* Manifestdateien zu erstellen und mit allen Objekten zu aktualisieren, die während des Kopiervorgangs erstellt wurden

Ersetzen Sie vor dem Ausführen der folgenden Beispiele die folgenden Felder in den Beispielskripts: \* *YourBucketName*: Ersetzen Sie durch den Namen Ihres Buckets oder Blob-Speichers, in dem Sie Schreibzugriff haben. \* Damit VantageCloud Lake die richtigen Anmeldeinformationen übergibt, können Sie entweder ein Autorisierungsobjekt verwenden oder die Anmeldeinformationen als JSON-formatiertes Argument an das AUTHORIZATION-Element übergeben. \* Fügen Sie hier Ihr Autorisierungsobjekt mit Ihren Speicheranmeldeinformationen ein oder: \* *AccessID*: über den Zugriffsschlüssel für Ihren Bucket (optional) – Beispiel für die Zugriffsschlüssel-ID: AKIAIOSFODNN7EXAMPLE \* *AccessKey*: über den Zugriffsschlüssel für Ihren Bucket (optional) – Beispiel für einen geheimen Zugriffsschlüssel: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Beispiel 1

In diesem Beispiel wird das Ergebnis einer SELECT-Anweisung verwendet, die alle Zeilen in der Tabelle **sample\_sensor** (oben erstellt) abruft und in die Partition oder den Container *sample1* in dem Konto oder Bucket schreibt, das bzw. der im LOCATION-Element angegeben ist:

``` sourceCode
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_sensor )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### Beispiel 2

In diesem Beispiel wird dieselbe Tabelle **sensor\_data** als Quelle verwendet, diesmal jedoch unterteilt nach dem Sensordatum und dem Jahr unter der Partition *sample2*:

``` sourceCode
SELECT * FROM WRITE_NOS (
    ON ( SELECT
            sensedate,
            sensetime,
            epoch,
            moteid,
            temperature,
            humidity,
            light,
            voltage,
            year(sensedate) TheYear
        FROM sample_sensor )
    PARTITION BY TheYear ORDER BY TheYear
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        NAMING ('DISCRETE')
        INCLUDE_ORDERING ('FALSE')
        STOREDAS ('PARQUET'))
 AS d;
```

### Ihre WRITE\_NOS-Ergebnisse validieren

Sie können die Ergebnisse Ihrer WRITE\_NOS-Anwendungsfälle validieren, indem Sie ein Autorisierungsobjekt mit Ihren Bucket-Benutzeranmeldeinformationen erstellen und dann eine Fremdtabelle für den Zugriff auf Parquet-Daten erstellen, wie in den Beispielen im obigen Abschnitt beschrieben, oder indem Sie eine einfache SELECT-Anweisung mit der READ\_NOS-Syntax von oben ausführen.

### Bereinigen

Löschen Sie die Objekte, die wir in unserem eigenen Datenbankschema erstellt haben.

``` sourceCode
DROP AUTHORIZATION MyAuth;
```

``` sourceCode
DROP TABLE sample_sensor;
```

``` sourceCode
DROP TABLE sample_local_table;
```
