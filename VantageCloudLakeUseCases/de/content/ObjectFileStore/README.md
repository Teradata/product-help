### Speichern von Daten im VantageCloud Lake Edition-Objektdateisystem

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

Im Folgenden finden Sie eine Zusammenfassung zum Speichern von Daten im VantageCloud Lake Edition-Objektdateisystem (OFS).

### Einrichtung

Erstellen Sie eine Fremdtabelle mit Daten im S3-Bucket.

```sql
REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY DefaultAuth
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

Überprüfen Sie die Daten in der Fremdtabelle.

```sql
SELECT * FROM foreign_csvdata;
```

### Szenario 1

Wenn Sie eine vorhandene Fremdtabelle mit Daten im S3-Bucket haben und die Daten in eine neue OFS-Tabelle laden möchten, können Sie die folgende Anweisung verwenden.

```sql
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

Überprüfen Sie die Daten in der neuen OFS-Tabelle.

```sql
SELECT * FROM ofs_csvdata;
```

Löschen Sie die OFS-Tabelle.

```sql
DROP TABLE ofs_csvdata;
```

### Szenario 2

Wenn Sie über eine vorhandene OFS-Tabelle eines Lake-Dateisystems verfügen und Daten aus einer anderen Tabelle in diese laden möchten, können Sie die folgende Anweisung verwenden.

Erstellen Sie eine neue OFS-Tabelle.

```sql
CREATE MULTISET TABLE ofs_csvdata,
     STORAGE = TD_OFSSTORAGE
     (
      site_no INTEGER,
      datetime TIMESTAMP(0),
      Precipitation DECIMAL(3,2),
      GageHeight DECIMAL(3,2),
      Flow DECIMAL(3,2),
      GageHeight2 DECIMAL(3,2))
NO PRIMARY INDEX ;
```

Laden Sie Daten aus einer Fremdtabelle in die OFS-Tabelle.

```sql
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

Überprüfen Sie die Daten in der OFS-Tabelle.

```sql
SELECT * FROM ofs_csvdata;
```

Löschen Sie die Tabellen.

```sql
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### Szenario 3

Wenn Sie zum ersten Mal Daten aus einem Objektspeicher in eine neue OFS-Tabelle laden möchten, können Sie die folgende Anweisung verwenden.

Um diese Option zu verwenden, benötigen Sie die EXECUTE-Berechtigung für TD\_SYSFNLIB.READ\_NOS. Diese kann mit der folgenden Anweisung erteilt werden. Wenden Sie sich an Ihren Datenbankadministrator, um die Berechtigung zu erhalten.

```sql
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

```sql
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2
FROM (
LOCATION='/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'
AUTHORIZATION=DefaultAuth
) AS d
) WITH DATA;
```

Überprüfen Sie die Daten in der neuen OFS-Tabelle.

```sql
SELECT * FROM ofs_csvdata;
```

Löschen Sie die Tabellen.

```sql
DROP TABLE ofs_csvdata;
```
