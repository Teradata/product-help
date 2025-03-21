Künstliches Kniegelenk – Pfadanalyse
------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

Dieses Arbeitsbuch enthält ein grundlegendes Demoskript, das die Funktionen von Vantage Path vorführt. Die Zielgruppe sind Unternehmensanalysten. Das Demoskript wurde so konzipiert, dass der Abschnitt „Auf dem Weg zum künstlichen Kniegelenk“ sowohl einzeln (z. B. für ein kurzes informelles Einführungstreffen) als auch in Kombination mit den anderen Abschnitten für eine umfassendere Demonstration verwendet werden kann.

### Erfahrungswerte

Die Ausführung des Abschnitts „Erfahrungswerte“ dauert etwa 7–10 Minuten.

Öffnen Sie zunächst [Vantage Path](/path-analyzer).

### Einrichtung

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden. [Objekte laden](#data=%7B%22id%22:%22KneeReplacement%22%7D)

### Exemplarische Vorgehensweise

------------------------------------------------------------------------

#### Schritt 1: Auf dem Weg zum künstlichen Kniegelenk

Ich werde die Vantage Path-Analysefunktionen anhand von Gesundheitsdaten demonstrieren. Insbesondere werden wir uns die häufigsten medizinischen Verfahren auf dem Weg zum künstlichen Kniegelenk ansehen.

Über das rechte Feld werde ich die Werte wie folgt einstellen: – Behalten Sie für die Option „Oberste Pfade für die Anzeige“ den Wert 25 bei – Wählen Sie die Datenquelle aus: – Ereignisdatenbank: retail\_sample\_data – Ereignistabelle: knee\_replacement

Ich habe mich entschieden, keinen Filter zu setzen und stattdessen „Alle Ereignisse“ zu verwenden. Für das Ereignismuster: – Ereignis A – als „Jedes Ereignis“ belassen – Ereignis B – von „Jedes Ereignis“ in „Künstliches Kniegelenk“ ändern

Und ich belasse „Min. Anzahl Ereignisse“, „Max. Anzahl Ereignisse“ und „Überlappung zulassen“ als Standardeinstellungen.

Für dieses Demoszenario muss ich den Datumsbereich nicht einschränken (dieser Filter könnte jedoch in anderen Situationen nützlich sein).

Schließlich muss ich die Sitzungsspalte (entity\_id) auswählen, um der Pfadanalyse mitzuteilen, welche Ereignisse zum selben Pfad gehören. Einige Pfadanalysen, wie z. B. Pfade auf einer Website, werden nach session\_id zusammengefasst. In diesem Szenario entspricht die session\_id dem Patienten (entity\_id).

Sobald alle für die Abfrage erforderlichen Informationen eingegeben wurden, kann ich auf die Schaltfläche „Ausführen“ klicken. Daraufhin wird dynamisch eine Abfrage generiert und an das Vantage-System gesendet. In Kürze wird uns hier in der Benutzeroberfläche eine Visualisierung zurückgegeben.

#### Schritt 2: Visualisierung

Die zurückgegebene erste Visualisierung hebt den gängigsten Weg zum künstlichen Kniegelenk hervor.

Sobald die Visualisierung zurückgegeben wurde, stehen mir mehrere Optionen zur Verfügung: – Ich kann den Pfad bei jedem gewünschten Knoten manuell erweitern (indem ich auf einen offenen orangefarbenen Kreis wie „Kniearthroskopie“ klicke). Die durchgezogenen orangefarbenen Kreise zeigen an, dass der vollständige Pfad für diesen Knoten angezeigt wird. – Alle erweitern – Alle Pfade anzeigen – Alle reduzieren – Nur das Endereignis (künstliches Kniegelenk) wird angezeigt – Dominante auswählen – Hebt den beliebtesten Pfad hervor

-   Ich kann die Option „Anzahl der Zählungen anzeigen“ überprüfen, die die Anzahl der Personen anzeigt, die jeden spezifischen Pfadabschnitt durchlaufen haben (z. B. „Beweglichkeitstest“ bis „Physiotherapie NEC“).

-   Ich kann auch zwischen einem Pfaddiagramm und einer tabellarischen Auflistung der Pfadereignisse und -anzahl wechseln. Die tabellarische Auflistung ist das, was Sie erhalten hätten, wenn Sie diese Analyse über eine direkte Abfrage statt über die Benutzeroberfläche ausgeführt hätten.

Wie Sie beim Betrachten des dominanten Pfads sehen können, ist die Kniegelenkbiopsie der häufigste letzte Schritt vor dem Schritt „Künstliches Kniegelenk“. Lassen Sie uns dies weiter untersuchen, um zu sehen, ob wir andere Pfade identifizieren können, die nicht zum Schritt „Künstliches Kniegelenk“ geführt haben. – Lassen Sie uns zunächst die Pfade der „Kniegelenkbiopsie“ untersuchen, indem wir „Kniegelenkbiopsie“ als Ereignis A und „Beliebiges Ereignis“ für Ereignis B auswählen („Ausführen“ auswählen). – Wie erwartet, endet der dominante Pfad mit dem Schritt „Künstliches Kniegelenk“, es gibt jedoch auch andere Verfahren.

-   Innerhalb von Vantage Path können wir die Richtung des Pfads problemlos ändern. Lassen Sie uns dies tun, um einen „Pfad zur Kniegelenkbiopsie“ zu erkunden.  
-   Bevor wir jedoch „Ausführen“ auswählen, aktivieren wir die Option „Endanker“. Diese Option stellt sicher, dass die Kniegelenkbiopsie das letzte Ereignis im Pfad ist und die Patienten daher nicht ein künstliches Kniegelenk erhalten.
-   In dieser Visualisierung sehen wir den gängigsten Weg zur „Kniegelenkbiopsie“ und wir sind möglicherweise daran interessiert, bei den Patienten, die diesen Weg einschlagen, weitere Analysen durchzuführen.

Wenn der Pfad „Dominant“ (oder ein anderer Pfad) ausgewählt wird, kann ich die Ergebnisse in einer Tabelle speichern und mithilfe der Funktion „Segment erstellen“ weiter analysieren.

Wenn Sie nicht mit Schritt 3: „Segment erstellen“, der Demo fortfahren, überspringen Sie einfach den nächsten Abschnitt und gehen Sie zum Fazit über.

#### Schritt 3: Segment erstellen

Um die Funktion „Segment erstellen“ zu demonstrieren, muss in Ihrer persönlichen Datenbank bereits eine Ausgabetabelle erstellt worden sein (da Schreibzugriff erforderlich ist).

``` sourceCode
CREATE TABLE knee_replacement_path_export(
    entity_id    varchar(100),
    path        varchar(2000)
)
```

Wenn Sie die Demo bereits ausgeführt und die Tabelle nicht neu erstellt haben, stellen Sie sicher, dass die Tabelle leer ist. Andernfalls wird bei „Segment speichern“ angezeigt, dass 0 Zeilen eingefügt werden.

Die Pfadanalyse ermöglicht eine visuelle Untersuchung. Wenn ein interessant erscheinender Pfad identifiziert wird, werden die Personen auf diesem Pfad häufig für eine weitere Analyse herangezogen. Schauen wir uns nun die Funktion „Segment erstellen“ näher an.

Wenn ich auf die Schaltfläche „Segment erstellen“ klicke, kann ich eine Datenbank (auf die ich Schreibzugriff habe) und eine Tabelle auswählen – (Verwenden Sie die, die Sie unter „Einrichtung“ erstellt haben).

Mir stehen jetzt einige Optionen zur Verfügung: – SQL anzeigen – dies ist der SQL-Code, der von Vantage ausgeführt wird. Ich kann diesen SQL-Code kopieren und zur weiteren Untersuchung in ein Abfragetool wie Vantage Editor oder Jupyter einfügen. – Segment speichern – die Abfrage wird ausgeführt und die Ausgabe in der angegebenen Tabelle gespeichert. Sobald die Abfrage abgeschlossen ist, wird die Anzahl der Zeilen angezeigt

    - Save Query –  with this option the query is given a name and the SQL is saved to a table on Vantage.

    - Now that I have saved a segment – let’s take a look at the resulting table. I am going to switch to Vantage Editor
    - If I view the insights from the knee_replacement_path_export table I can see that it has 2,757 records as well as the columns and ddl statement.
    - Running a simple select query I can see the result - Entity_id and Path (the dominant path selected).

-   Das gespeicherte Segment kann als Eingabe für weitere Analysen verwendet werden, z. B. zum Clustering, um zu sehen, ob es Gemeinsamkeiten zwischen den Patienten gibt, oder möglicherweise als Input für einen Behandlungsplan, denn diese Patienten könnten Kandidaten für weniger invasive Verfahren sein.

#### Bereinigen

Wenn Sie mit diesem Beispiel fertig sind, denken Sie daran, die erstellte Tabelle zu bereinigen:

``` sourceCode
DROP TABLE knee_replacement_path_export
```

#### Fazit

Wie Sie dieser kurzen Demonstration entnehmen können, bietet Vantage Analyst eine benutzerfreundliche Oberfläche zur Durchführung von Pfadanalysen wie der gerade gezeigten. Pfadanalysen können mehrere Themen und Branchen umfassen.

Beispiele: – Kundenpfade zum Kauf – Online-Pfade zum Warenkorbabbruch – Kundenpfade zu Beschwerden – Pfade zum Teileausfall

Dataset
-------

------------------------------------------------------------------------

Der Dataset **knee\_replacement** hat 289.839 Zeilen, die jeweils einen Eingriff darstellen, den ein Patient vornehmen ließ. Der Dataset ist denormalisiert, sodass einige Patienteninformationen in jeder Zeile wiederholt werden:

-   `memberid`: eindeutige Patientenkennung
-   `proccode`: Prozedurkennung
-   `diagcode`: ursprüngliche Diagnose des Patienten
-   `shortdesc`: kurze Beschreibung des Verfahrens
-   `amount`: Kosten des Verfahrens
-   `tstamp`: Datum und Uhrzeit des Verfahrens
-   `firstname`: Vorname des Patienten
-   `lastname`: Nachname des Patienten
-   `email`: E-Mail-Adresse des Patienten
-   `state`: Abkürzung des Bundesstaates für den Patienten
