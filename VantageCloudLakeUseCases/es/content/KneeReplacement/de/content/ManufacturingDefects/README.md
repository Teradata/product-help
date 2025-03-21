Analyse von Herstellungsfehlern
-------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

Sie sind Analyst bei einem großen Automobilhersteller. Beim Ausführen regelmäßiger Finanzberichte auf Teradata VantageCloud Lake haben wir ein ernstes Geschäftsproblem mit zunehmenden Garantiereparaturen festgestellt:

![png](costs.png)

Das Problem scheint durch den Austausch von Akkus verursacht zu werden – einige der teuersten und kritischsten Komponenten, die in unsere Elektrofahrzeugprodukte (EV) einfließen. Wir können die einzigartigen Funktionen von VantageCloud Lake nutzen, um sowohl die strukturierten als auch die halbstrukturierten Daten zu analysieren, die während des Herstellungsprozesses erfasst wurden, um die Grundursache zu isolieren und das Problem letztendlich zu beheben.

### Erfahrungswerte

Die Ausführung des Abschnitts „Erfahrungswerte“ dauert etwa 15 Minuten.

### Einrichtung

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden. [Objekte laden](#data=%7B%22id%22:%22EVCarBattery%22%7D)

### Exemplarische Vorgehensweise

------------------------------------------------------------------------

#### Schritt 1: Die Grundursache eingrenzen

Wir erstellen einen Bericht über alle Fahrzeuge, bei denen die Akkus ausgetauscht wurden, und kombinieren die Akku- und Fahrzeuginformationen mit dem Händler, der die Wartung durchgeführt hat. In diesem Beispiel befinden sich alle Daten in der Datenbank. In der realen Welt ist die Kombination unterschiedlicher Datensätze jedoch eine wichtige Voraussetzung für eine effektive Analyse. VantageCloud Lake ermöglicht es Benutzern, Daten aus verschiedenen Drittanbietersystemen, Data Lakes und Objektspeichern in großem Umfang zu kombinieren, um schnelle und detaillierte Analysen durchzuführen.

``` sourceCode
SELECT d.company, count(*)
FROM ev_dealers d, ev_badbatts bb,
ev_vehicles v
WHERE bb.vin = v.vin
AND v.dealer_id = d.id
GROUP BY d.company order by 2 desc
```

Als Nächstes gruppieren Sie die Daten nach Fahrzeugmodell. Wir verwenden dieselben Akkuteile in mehreren verschiedenen Modellen unserer Produktlinie:

``` sourceCode
SELECT v.model, count(*)
FROM ev_vehicles v, ev_badbatts bb
WHERE bb.vin = v.vin
GROUP BY v.model order by 2 desc
```

Hier gibt es nichts Besonderes.

Nachfolgend gruppieren Sie nach dem Montagewerk, aus dem die Autos stammen:

``` sourceCode
SELECT mfg.company, count(*)
FROM ev_mfg_plants mfg, ev_badbatts bb,
ev_vehicles v
WHERE bb.vin = v.vin
AND v.mfg_plant_id = mfg.id
GROUP BY mfg.company order by 2 desc
```

Wir sehen eine sehr hohe Anzahl fehlerhafter Autos aus demselben Montagewerk.

Finden Sie nun heraus, welche Akkuzellen in den Autos mit schlechten Batterien eingebaut sind. Nutzen Sie die Teilenummer, um die Daten zusammenzufassen.

``` sourceCode
SELECT DISTINCT bom.part_no, p.description, count(*)
FROM ev_bom bom, ev_badbatts bb, ev_parts p
WHERE bb.vin = bom.vin
AND bom.part_no = p.part_no
AND p.description LIKE 'Battery Cell%'
GROUP BY bom.part_no, p.description
```

Nach dem Ausführen dieser Abfrage scheint es, als hätten wir ein Problem mit part\_no 20rd0.

Mit VantageCloud Lake können Organisationen große Datenmengen in einem leistungs- und kostenoptimierten Objektspeicher speichern und analysieren. Für diese Demonstration speichern wir detaillierte Fertigungsdaten in unserem integrierten Data Warehouse. Prüfen Sie, ob es eine Korrelation zu den Chargennummern dieser Akkuzellen gibt:

``` sourceCode
SELECT bom.part_no, bom.lot_no, p.description, count(*)
FROM ev_bom bom, ev_badbatts bb, ev_parts p
WHERE bb.vin = bom.vin
AND p.part_no = bom.part_no
AND p.description LIKE 'Battery Cell%'
GROUP BY bom.part_no, bom.lot_no, p.description
ORDER BY count(*) DESC
```

Die obige Abfrage zeigt das zugrunde liegende Problem mit part\_no 20rd0. Die meisten Ausfälle sind auf die Akkucharge 4012 zurückzuführen (die an das Werk in Jackson geliefert wurde), die eine große Anzahl fehlerhafter Akkus enthält, die wir im Rahmen der Garantie ersetzen müssen. Diese Einblicke werden auf unserem Dashboard in unserem bevorzugten Business-Intelligence-Tool (BI) noch besser dargestellt, das direkt mit VantageCloud Lake verbunden ist und interaktive und iterative Analysen ermöglicht:

![png](dashboard.png)

Unsere modernen, vernetzten Elektrofahrzeuge liefern ebenfalls detaillierte Sensordaten. Wir können uns die Temperatursensordaten für die betreffende Akkucharge ansehen:

![png](4102temps.png)

Vergleichen Sie diese Daten mit einer durchschnittlichen Akkucharge:

![png](avgtemps.png)

Je nach Modell/Chargennummer der einzelnen Akkupacks können Sie deutlich erkennen, dass es bei unseren Akkupacks zu höheren Temperaturen/Überhitzung kommt. Jetzt kennen wir die Ursache für unsere gestiegenen Garantiekosten. Um das Problem zu lösen, müssen wir jedoch noch weiter zurückgehen und uns ansehen, wie die Autos zusammengebaut und getestet wurden.

#### Schritt 2: Wir brauchen zusätzliche Daten – Zugriff auf Testergebnisse aus unserem Data Lake

Ausgehend von dieser Analyse möchten wir verstehen, wie wir fehlerhafte Akkus erkennen können, bevor sie in den Autos unserer Kunden landen. Dies wird uns helfen, in Zukunft teure Garantie-Reparaturzyklen und Unzufriedenheit bei unseren Kunden zu vermeiden.

Wenn die Autos hergestellt werden, speichern wir detaillierte Testberichte für die Teile und Unterbaugruppen, aus denen das Fahrzeug besteht. Diese Berichte sind umfangreich und in einem halbstrukturierten Format in unserem Data Lake gespeichert, der sich in einem Objektspeicher befindet.

Mit VantageCloud Lake können wir diese Daten nativ in großem Umfang abrufen und für unsere Analyse verwenden.

Erstellen Sie zunächst ein Autorisierungsobjekt zur Authentifizierung beim externen Objektspeicher. In der Praxis würden Sie die Leerzeichen durch die entsprechenden Anmeldeinformationen oder Identity and Access Management (IAM)-Rollen ersetzen, um auf die geschützten Ressourcen zuzugreifen. Hier erstellen wir ein leeres Objekt für den Zugriff auf eine öffentlich verfügbare Ressource:

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

Als Nächstes erstellen wir eine Fremdtabelle, um auf die JSON-formatierten Daten in Amazon S3 zuzugreifen. Eine Fremdtabelle ermöglicht uns den Zugriff auf die Remote-Daten, als wäre es eine normale Tabelle in der Datenbank:

``` sourceCode
CREATE FOREIGN TABLE test_reports , FALLBACK ,
     EXTERNAL SECURITY MyAuth
(
    Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
    payload JSON(16776192) INLINE LENGTH 64000 CHARACTER SET LATIN)
USING (
    Location ('/s3/s3.amazonaws.com/trial-datasets/EVCarBattery/')
), NO PRIMARY INDEX;
```

Als Drittes überprüfen wir eine Stichprobe von zehn Reihen, um die Daten zu validieren:

``` sourceCode
SELECT TOP 10 *
FROM test_reports
```

Durch das Hinzufügen einer benutzerfreundlichen Ansicht über der Fremdtabelle können wir JSON-Verarbeitungsfunktionen verwenden und die Daten in einem einfacheren Format darstellen. Diese Funktionen werden recht häufig für die Verarbeitung halbstrukturierter Daten im großen Maßstab verwendet:

``` sourceCode
REPLACE VIEW test_reports_v AS
(SELECT vin, part_no, lot_no, CAST(test_report AS JSON) test_report
FROM TD_JSONSHRED(
    ON (
                SELECT payload.vin as vin, payload
                FROM test_reports)
            USING
            ROWEXPR('parts')
            COLEXPR('part_no', 'lot_no', 'test_report') 
            RETURNTYPES('VARCHAR(17)', 'VARCHAR(1000)', 'VARCHAR(10000)')
        ) AS d1 (vin, part_no, lot_no, test_report)
    )
```

Überprüfen Sie nun eine Stichprobe der verarbeiteten Daten, indem Sie die Ansicht abfragen:

``` sourceCode
SELECT TOP 10 *
FROM test_reports_v
```

#### Schritt 3: Nativ in Vantage auf die JSON-Testdaten für die Fertigung zugreifen und sie verknüpfen

Das sieht gut aus. Sehen wir uns nun die Testberichte an. Für verschiedene Teile werden beim Testen unterschiedliche Daten gemeldet. Die Testergebnisse für die einfachsten Teile sehen folgendermaßen aus:

``` sourceCode
SELECT TOP 1 test_report
FROM test_reports_v
WHERE part_no = '11400zn'
```

Im Gegensatz dazu enthält der Testbericht für einen Akku detaillierte Daten zur Leistung des Akkus nach dem Zusammenbau, aber vor dem Einbau in das Fahrzeug:

``` sourceCode
SELECT TOP 1 test_report
FROM test_reports_v
WHERE part_no = '20rdS0'
```

Wir möchten die Nenn- und Messkapazitäten zusammen mit den Teilenummern/Chargennummern nur für die Akkus vergleichen. Wir können die JSON-Daten einfach mit einer einfachen Punktnotation aufschlüsseln, um auf die benötigten Testergebnisse zuzugreifen.

``` sourceCode
SELECT TOP 10 tr.part_no, p.description, tr.lot_no, 
tr.test_report."Rated Capacity" AS rated_capacity,
tr.test_report."Static Capacity Test"."Measured Average Capacity" AS measured_capacity
FROM ev_parts p, test_reports_v tr
WHERE  p.part_no = tr.part_no
AND p.description LIKE 'Battery Cell%'
```

Wenn wir dies in unserem BI-Tool visualisieren, können wir sehen, dass diese Akkupacks innerhalb der Spezifikation liegen, die Reichweite jedoch viel geringer ist als bei den anderen Akkuchargen. Wir können unsere Annahmekriterien verschärfen und proaktive Analysen wie diese durchführen, um mögliche Qualitätsprobleme zu identifizieren, bevor die Autos fertiggestellt und an die Kunden ausgeliefert werden. Diese Initiativen werden die Produktqualität verbessern und sicherstellen, dass dies nicht noch einmal passiert.

![png](batterylotcapacity.png)

Indem wir VantageCloud Lake zur Analyse unserer integrierten Daten und des Data Lake verwenden, können wir praktisch jedem Geschäftsproblem schnell und einfach auf den Grund gehen.

#### Schritt 4: Bereinigen

Löschen Sie die Objekte, die wir in unserem eigenen Datenbankschema erstellt haben.

``` sourceCode
DROP TABLE test_reports;
```

``` sourceCode
DROP VIEW test_reports_v;
```

Dataset
-------

------------------------------------------------------------------------

**bom** – Stückliste – Enthält alle wichtigsten Teile, aus denen jedes Fahrzeug besteht:

-   `id`: eindeutige Kennung
-   `vin`: Fahrzeugidentifikationsnummer
-   `part_no`: Teilenummer
-   `vendor_id`: Hersteller, von dem das Teil hergestellt wurde (unbenutzt)
-   `lot_no`: Chargennummer vom Lieferanten
-   `quantity`: Wie viele dieser Teile sich im Fahrzeug befinden

**dealers** – Fahrzeugverkauf und -vertrieb:

-   `id`: eindeutige Kennung
-   `Company`: Firmenname
-   `StreetAddress`: Straße und Hausnummer
-   `City`: Ort
-   `State`: Bundesstaat
-   `ZipCode`: Postleitzahl
-   `Country`: Land
-   `EmailAddress`: Haupt-E-Mail-Adresse
-   `TelephoneNumber`: Telefonnummer
-   `DomainName`: URL der Unternehmenswebsite
-   `Latitude`: Breitengrad (Standort)
-   `Longitude`: Längengrad (Standort)

**mfg\_plants** – Produktionsanlagen:

-   `id`: eindeutige Kennung
-   `Company`: Name der Anlage
-   `StreetAddress`: Straße und Hausnummer
-   `City`: Ort
-   `State`: Bundesstaat
-   `ZipCode`: Postleitzahl
-   `Country`: Land
-   `EmailAddress`: Haupt-E-Mail-Adresse
-   `TelephoneNumber`: Telefonnummer
-   `DomainName`: URL der Werkswebsite
-   `Latitude`: Breitengrad (Standort)
-   `Longitude`: Längengrad (Standort)

**parts** – Hauptteileliste für alle Fahrzeuge:

-   `part_no`: eindeutige Teilenummer
-   `description`: Teilebeschreibung

**vehicles** – Fahrzeuge, die wir gebaut haben/bauen:

-   `vin`: eindeutige Kennung
-   `yr`: Modelljahr
-   `model`: Fahrzeugmodellcode
-   `customer_id`: Kunde/Käufer
-   `dealer_id`: Händler, bei dem das Fahrzeug verkauft/ausgeliefert wurde
-   `mfg_plant_id`: Werk, in dem das Fahrzeug montiert wurde
