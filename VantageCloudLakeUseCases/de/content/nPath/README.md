Pfadanalyse mit nPath: Verhaltensweisen anhand von Mustern erkennen
-------------------------------------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

nPath ist eine SQL-Erweiterung, die für die schnelle und flexible Analyse geordneter Daten im großen Maßstab entwickelt wurde.

Mit den Klauseln in nPath können Sie komplizierte Pfadabfragen und Ordnungsbeziehungen ausdrücken, für die Sie sonst möglicherweise mehrstufige Verknüpfungen von Beziehungen in ANSI-SQL (American National Standards Institute) schreiben müssten. Mit nPath geben Sie eine gewünschte Reihenfolge an und legen dann ein Muster fest, das mit den geordneten Daten abgeglichen wird. Für jede Übereinstimmung des Musters in der Zeilenfolge berechnet nPath eine SQL-Aggregation über die übereinstimmenden Zeilen.

Die nPath-Analyse hilft dabei, Pfade zu verfolgen, die zu einem Ergebnis führen, einschließlich des Kundenverhaltens:

-   Path-to-purchase
-   Analyse abgebrochener Warenkörbe
-   Abwanderungsgrund
-   Patientenerfahrungen, wie z. B. Krankenhaus-Wiederaufnahme
-   Pfade zu betrügerischen Aktivitäten

### Beispiel für Kundenabwanderung bei Telekommunikationsunternehmen

------------------------------------------------------------------------

In der Telekommunikationsbranche ist die Bekämpfung von Kontoauflösungen oder Abwanderungen ein enormer Kosteneinsparungsfaktor. Die nPath-Analyse kann Wege aufzeigen, wie die Kundenbindung durch das Verständnis des Kundenverhaltens verbessert werden kann.

Der erste Schritt besteht darin, eine Ereignistabelle zu erstellen, um Interaktionen und Transaktionen mit dem Kunden zu integrieren. Durch die Erfassung der Ereignisse können Sie die Customer Journey analysieren, die möglicherweise den Besuch eines Ladens, den Besuch der Website, den Anruf bei der Support-Hotline, die Aktualisierung des Dienstes und die Kündigung des Dienstes umfasst.

Mithilfe der nPath-Analyse können Sie diese Ereignisse auf sehr einfache Weise analysieren und so beispielsweise folgende geschäftliche Fragen beantworten:

-   Welche Pfade nehmen meine Kunden auf der Website?
-   Welche Pfade gehen meine Kunden, bevor sie die Support-Hotline anrufen?
-   Welche Pfade gehen meine Kunden, bevor sie ihren Dienst kündigen?

### Erfahrungswerte

Die Ausführung des gesamten Anwendungsfalls dauert etwa 7 Minuten.

### Einrichtung

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden. [Objekte laden](#data=%7B%22id%22:%22Telco%22%7D)

### Beispiele

------------------------------------------------------------------------

#### Beispiel Nr. 1 – Alle Pfade

Dies ist eine häufige Abfrage, wenn man sich zum ersten Mal mit Pfaden in den Daten befasst. Sie gibt einen minimalen Ergebnissatz zurück; die einzige erforderliche Ergebnisspalte ist die ACCUMULATE()-Ausgabe für den Pfad. Durch Hinzufügen der entity\_id können Sie bei Bedarf eine Verknüpfung zu den Originaldaten herstellen.

Die nPath-Funktion verwendet eine Eingabetabelle, die aus Ereignissen, dem Zeitstempel des Ereignisses und anderen Informationen wie Sitzungs-ID, Benutzer-ID usw. besteht. Wir stellen der USING-Klausel verschiedene Argumente zur Verfügung, um das Verhalten der Mustererkennung zu steuern.

Das Muster kann noch genauer abgestimmt werden. Um beispielsweise die Anzahl der Ereignisse im Pfad zu steuern, ersetzen Sie A\* durch A{3,6} für Pfade mit mindestens drei und höchstens sechs Ereignissen:

``` sourceCode
SELECT * FROM npath
( 
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp
   USING 
     Mode (NonOverlapping)
     Pattern ('A*') 
     Symbols 
     (
         true as A 
     )
     Result 
     (
         FIRST ( entity_id of ANY (A) ) AS customer_id,
         ACCUMULATE (event of any(A) ) AS path
     )
)
SAMPLE 1000
;
```

In der Ergebnisklausel können weitere Spalten definiert werden, um die Ergebnisse weiter zu verfeinern. Hier sind einige gängige Beispiele, die hilfreich sein können.

#### Beispiel Nr. 2 – Pfade zum Ereignis

Durch die Verwendung eines Musters, das aus mehreren Symbolen besteht (unten O und A), können wir eine komplexere Übereinstimmung erstellen – in diesem Fall Ereignisse, die zu einer ZAHLUNGSANFECHTUNG EINER RECHNUNG führen, mit mindestens zwei und höchstens sechs Ereignissen vor der Einreichung. Beachten Sie, dass wir der Abfrage Standard-SQL hinzufügen können – in diesem Fall eine ORDER BY-Klausel am Ende.

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('O{2,6}.A')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Beispiel Nr. 3: Umkehrung der Pfadrichtung

Durch einfaches Ändern des Musters in A.O{1,3} können wir Pfade finden, die nach der Einreichung des Antrags eingeschlagen wurden, mit mindestens einem und bis zu drei Ereignissen, um das Kundenverhalten nach der Einreichung zu verstehen.

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('A.O{1,3}')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )
     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Beispiel Nr. 4: Die wichtigsten Pfade

Durch Umschließen der nPath-Abfrage mit SQL COUNT/GROUP BY-Klauseln und Sortieren nach absteigendem Wert können wir die wichtigsten Pfade schnell finden.

Beachten Sie auch die nPath PATTERN-Syntax unten. Hier filtern wir nach Pfaden, die mindestens drei Übereinstimmungen aufweisen, ohne maximale Anzahl von Übereinstimmungen. Die Syntax lautet **{min, max}**.

``` sourceCode
SELECT path, count(*) as cnt
FROM npath
(
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         true  as A
     )
     Pattern ('A{3,}')

     Result
     (
         FIRST ( entity_id of ANY (A) )                  AS customer_id,
         FIRST ( session_id of ANY(A))                   AS session_id,
         COUNT ( * of any (A) )                          AS cnt,
         FIRST ( event of ANY (A) )                      AS first_event,
         LAST  ( event of ANY (A) )                      AS last_event,
         ACCUMULATE (event of any(A) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
group by 1
order by count(*) desc
SAMPLE 50
;
```

#### Beispiel Nr. 5: In Sitzungen aufteilen

In vielen Fällen werden die Daten die Benutzerereignisse nicht in leicht definierbare Sitzungen aufteilen. Auch wenn digitale Daten diese Informationen enthalten können, müssen wir bei der Kombination mehrerer Kanäle oder Datenquellen eine Grenze dafür ziehen, was eine Benutzer- oder Entitätssitzung ausmacht. Die Funktion zur Aufteilung in Sitzungen ordnet jedes Ereignis in einer Sitzung einer eindeutigen Sitzungskennung zu. Eine Sitzung ist eine Abfolge von Ereignissen eines Benutzers, die durch eine maximale Dauer in Sekunden voneinander getrennt sind.

Die Funktion ist sowohl für die Aufteilung in Sitzungen als auch für die Erkennung von Webcrawler-Aktivitäten (Bots) nützlich. Bot-basierte Ereignisdaten können auf Wunsch automatisch anhand eines Werts für die „Klickverzögerung“ aus der Funktion herausgefiltert werden.

Die Aufteilung in Sitzungen kann auch mit nPath zur verbesserten Mustererkennung verwendet werden.

``` sourceCode
select *
from Sessionize
(
    on (select * from telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
    partition by entity_id
    order by datestamp
    using
    TimeColumn('datestamp')
    TimeOut(1200) -- 1200 seconds (20 minutes)
)
order by datestamp
SAMPLE 100
;
```

Dataset
-------

------------------------------------------------------------------------

**telco\_events** – Beispiele für Kundenereignisse von Telekommunikationsunternehmen:

-   `entity_id`: eindeutige Kennung für den Kunden
-   `datestamp`: Uhrzeit und Datum des Ereignisses
-   `session_id`: Sitzungskennung
-   `event`: Ereignis oder Kundeninteraktion
