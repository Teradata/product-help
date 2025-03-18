Vantage Path – Pfadanalyse zur Verhaltensanalyse ohne Codierung nutzen
----------------------------------------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

nPath ist eine SQL-Erweiterung, die für die schnelle Analyse geordneter Daten entwickelt wurde.

Vantage Path bietet Benutzeroberflächen, die Geschäftsbenutzern und Data Scientists helfen, Muster im Kundenverhalten zu verstehen und erweiterte Vorhersagemodelle zu erstellen. Die Modelle verwenden die Vantage Machine Learning Engine (ML Engine). Vantage Path enthält die analytischen Funktionen „nPath“ und „In Sitzungen aufteilen“, die innerhalb der ML Engine ausgeführt werden. Benutzer wählen Ereignisse und Parameter aus, um Ereignisdaten zu untersuchen, Muster zu erkennen und Customer Journeys zu ermitteln.

Ähnlich wie der nPath-Anwendungsfall hilft Vantage Path dabei, Pfade zu verfolgen, die zu einem Ergebnis führen. Dabei müssen Sie aber nicht SQL schreiben, sondern einfach nur mit der Maus daraufzeigen und klicken!

### Beispiel für Kundenabwanderung bei Telekommunikationsunternehmen

In der Telekommunikationsbranche ist die Bekämpfung von Kontoauflösungen oder Abwanderungen ein enormer Kosteneinsparungsfaktor. Die nPath-Analyse kann Wege aufzeigen, wie die Kundenbindung durch das Verständnis des Kundenverhaltens verbessert werden kann.

Der erste Schritt besteht darin, eine Ereignistabelle zu erstellen, um Interaktionen und Transaktionen mit dem Kunden zu integrieren. Durch die Erfassung der Ereignisse können Sie die Customer Journey anzeigen, die möglicherweise den Besuch eines Geschäfts, den Besuch der Website, den Anruf bei der Support-Hotline, das Upgrade des Dienstes und die Kündigung des Dienstes umfasst.

Mithilfe der nPath-Analyse können Sie jetzt auf die Ereignisse klicken, um Geschäftsfragen zu beantworten. Beispiele:

-   Welche Pfade nehmen meine Kunden auf der Website?
-   Welche Pfade gehen meine Kunden, bevor sie die Support-Hotline anrufen?
-   Welche Pfade gehen meine Kunden, bevor sie ihren Dienst kündigen?

### Einrichtung

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden. [Objekte laden](#data=%7B%22id%22:%22Telco%22%7D)

### Erfahrungswerte

Die Ausführung des gesamten Anwendungsfalls dauert etwa 5 Minuten.

1.  Öffnen Sie [Vantage Path](/path-analyzer).
2.  Wählen Sie die Systemverbindung aus und authentifizieren Sie sich.
3.  Wählen Sie die folgende „Ereignistabelle“ aus: telco\_events.
4.  Wählen Sie zusätzliche Parameter aus oder klicken Sie einfach auf „AUSFÜHREN“ und analysieren Sie die Ergebnisse.

### Hinzufügen zusätzlicher Parameter

Sie können sich für die Verwendung zusätzlicher Parameter für weitere Analysen entscheiden.

Die wichtigsten anzuzeigenden Pfade: Definiert die Anzahl der anzuzeigenden Pfade mit Musterübereinstimmung. Ereignis A: Erstes Ereignis im Suchmuster. Ereignis B: Letztes Ereignis im Suchmuster. Minimale Ereignisanzahl: Minimale Anzahl von Ereignissen im Pfadmuster. Maximale Ereignisanzahl: Maximale Ereignisanzahl im Pfadmuster

### Exportieren von Ergebnissen

#### Beispiel 1 – „Exportieren Sie eine Liste der Kunden, die kurz vor der Kundenabwanderung stehen.“

Um ein „Segment erstellen“ zu können, muss in der Zieldatenquelle eine Tabelle mit der folgenden Struktur vorhanden sein.

``` sourceCode
CREATE SET TABLE path_save_segment
(
     entity_id VARCHAR(100),
     path VARCHAR(2000)
);
```

#### Beispiel 2 – „Modellabfrage speichern“

Um eine „Abfrage speichern“ zu können, muss in der Zieldatenquelle eine Tabelle mit der folgenden Struktur vorhanden sein.

``` sourceCode
CREATE SET TABLE path_segment_queries
(
 id        VARCHAR(100),
 name      VARCHAR(1000),
 query     VARCHAR(32000)
);
```

#### Beispiel 3 – „Ergebnisse mit Arbeitsablauf operationalisieren“

Mit einem Arbeitsablauf können die Ergebnisse der Pfadanalyse nach einem Zeitplan ausgeführt werden. Die Pfadanalyse kann entweder gespeichert und dann direkt in einem Pfadknoten verwendet werden, oder der SQL-Code kann exportiert und in einem SQL-Knoten platziert werden. Um den SQL-Code in einem Arbeitsablauf zu verwenden, klicken Sie einfach auf „SQL anzeigen“ und kopieren Sie den SQL-Code aus Ihrem Browserfenster. Diese Ergebnisse können dann in jeden [Arbeitsablauf](/Arbeitsablauf/)-SQL-Knoten eingefügt werden. Die Funktion „SQL anzeigen“ kann auch hilfreich sein, um zu verstehen, wie der SQL-Code erstellt wurde.

### Bereinigen

Wenn Sie mit diesem Beispiel fertig sind, denken Sie daran, die erstellten Tabellen zu bereinigen:

``` sourceCode
DROP TABLE path_save_segment
```

``` sourceCode
DROP TABLE path_segment_queries
```
