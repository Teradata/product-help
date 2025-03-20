Zeitreihenanalyse – Analyse von Verbraucherbeschwerden in einem bestimmten Zeitraum
-----------------------------------------------------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

In diesem Beispiel analysieren wir die Anzahl der Beschwerden, die in einem bestimmten Zeitraum beim Consumer Financial Protection Bureau (CFPB) eingegangen sind.

Wie können wir Vantage verwenden, um Einblicke zu gewinnen und eine Geschichte hinter einem Dataset zu erzählen? In diesem Anwendungsfall sehen Sie, wie leistungsstark und einfach es ist, Antworten aus einem öffentlichen Dataset zu extrahieren, der über [Data.gov](http://data.gov) verfügbar ist. Wir verwenden SQL und ein Visualisierungstool, um die Anzahl der Beschwerden in einem bestimmten Zeitraum zu analysieren und die folgenden Fragen zu beantworten:

*Wie sind die Beschwerdetrends in einem bestimmten Zeitraum? Wie können wir die Sonderfälle im Dataset interpretieren?*

Durch die Beantwortung von Fragen wie den oben genannten erhalten wir ein tieferes Verständnis des Dataset und können in einfachen Worten erklären, wie sich die Anzahl der Beschwerden in einem bestimmten Zeitraum entwickelt. Im Abschnitt „Erkunden“ konzentrieren wir uns auf die Analyse der Anzahl der Beschwerden in einem bestimmten Zeitraum und die Identifizierung von Trends und Sonderfällen in den Zeitreihen, um die oben genannten Fragen zu beantworten.

### Erfahrungswerte

Die Ausführung des Abschnitts „Erfahrungswerte“ dauert etwa 5 Minuten.

### Einrichtung

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden. [Objekte laden](#data=%7B%22id%22:%22FinancialProtection%22%7D)

### Exemplarische Vorgehensweise

#### Schritt 1: Abfragen der Daten

Zählen Sie zunächst die Anzahl der Zeilen in der Tabelle.

```sql
select count(*) from fp_consumer_complaints;
```

Es sind knapp 1,3 Millionen Zeilen. Mit Vantage ist es kein Problem, große Datasets zu analysieren. Schauen wir uns also eine Stichprobe der Daten an.

```sql
select TOP 100 * from fp_consumer_complaints;
```

#### Schritt 2: Visualisierung der Daten

Aus der obigen Abfrage erkennen wir, dass dieser Dataset viele Informationen enthält. Um Einblicke zu gewinnen, müssen wir die Daten zunächst gruppieren.

Die erste Spalte ist **date\_received**. Dies ist das Datum, an dem die Beschwerden eingegangen sind. Das bedeutet, dass wir uns eine Zeitreihendarstellung der Daten ansehen können. Beginnen wir damit, die Anzahl der **complaint\_id** in einem bestimmten Zeitraum zu gruppieren, wobei wir **date\_received** als unsere Zeitachse verwenden.

```sql
select date_received, count(complaint_id) as counts
from fp_consumer_complaints
where date_received BETWEEN DATE '2017-03-01'
AND DATE '2019-03-01'
group by date_received;
```

Das ist großartig; wir haben jetzt die Anzahl der Beschwerden (**counts**) im Zeitverlauf (**date\_received**), aber wie können wir diese Daten interpretieren? Lassen Sie uns diese Zeitreihe in einem Diagramm darstellen.

![png](output_10_0.png)

Durch die Visualisierung der obigen Daten können wir erkennen, dass die Anzahl der Beschwerden in einem bestimmten Zeitraum stark schwankt und dass es mit der Zeit auch mehr Beschwerden zu geben scheint. Im Jahr 2017 gibt es auch einige ungewöhnliche Spitzen. Lassen Sie uns unsere Daten genauer betrachten. Wir beginnen mit einem Blick auf den allgemeinen Trend.

Gruppieren wir die Daten nach Monaten und zeichnen das obige Diagramm neu.

```sql
select extract(year from date_received) || extract(month from date_received) as month_date, count(complaint_id) as counts
from fp_consumer_complaints
group by month_date
order by month_date;
```

![png](output_13_0.png)

Betrachtet man die Beschwerden über Monate und Jahre hinweg, erkennt man einen klaren Aufwärtstrend. Eine Hypothese ist, dass die Menschen mit der Zeit bewusster werden und ihre Erfahrungen weitergeben. Die Medien können im Laufe der Zeit auch für die Beschwerdekanäle werben. Anhand dieser Grafik können wir deutlich erkennen, dass die oben erwähnten Spitzenwerte im Januar 2017 und im September 2017 erreicht wurden. Lassen Sie uns näher auf diese Daten eingehen und einige Einblicke im nächsten Schritt gewinnen.

#### Schritt 3: Gewinnen von Einblicken aus den Daten

Lassen Sie uns die beiden oben genannten Spitzen eingrenzen und genau sehen, wo sie auftreten. Dazu können wir ein weiteres Zeitreihendiagramm erstellen, dieses Mal nur für 2017.

```sql
select date_received, count(complaint_id) as counts
from fp_consumer_complaints
where year(date_received) = 2017
group by date_received
order by date_received;
```

![png](output_17_0.png)

Wenn wir uns die Spitzenwerte ansehen, stellen wir fest, dass sie vom 15. bis 21. Januar und in der ersten Septemberwoche auftraten. Um die tatsächlichen Daten der Spitzenwerte zu ermitteln, können wir die Abfrage so einschränken, dass mindestens 1.500 Beschwerden pro Tag erfasst werden.

```sql
select date_received,
    month(date_received) as month_date,
    count(complaint_id) as counts
from fp_consumer_complaints
where year(date_received) = 2017 and month_date in (1, 9)
group by date_received
having counts >= 1500
order by month_date, counts desc;
```

Sehen wir uns einige der Probleme an, die während dieser Zeit gemeldet wurden.

```sql
select date_received, company, count(company) as counts
from fp_consumer_complaints
where date_received in (
    date '2017-01-19',
    date '2017-01-20',
    date '2017-09-08',
    date '2017-09-09',
    date '2017-09-13'
)
group by date_received, company
having counts > 500
order by date_received, counts desc;
```

Interessanterweise richtete sich die große Mehrheit der Beschwerden gegen zwei Unternehmen: Navient Solutions und EQUIFAX. Diese scheinen in hohem Maße mit der Klage gegen Navient und dem Equifax-Datenleck zusammenzuhängen, die jeweils um diese Zeit herum stattfanden. Lassen Sie uns zusammenfassen, was passiert ist:

> Klage gegen Navient: Im Januar 2017 wurde Navient Solutions vom US-amerikanischen Consumer Financial Protection Bureau (CFPB) und den Generalstaatsanwälten von Illinois und Washington verklagt. Navient ist ein bedeutender Dienstleister für private und staatliche Studienkredite. Laut der CFPB hat Navient mindestens seit Januar 2010 „Zahlungen falsch zugewiesen, in Schwierigkeiten geratene Kreditnehmer zu mehreren Stundungen statt zu einkommensabhängigen Rückzahlungsplänen geführt und unklare Informationen darüber bereitgestellt, wie man sich erneut für einkommensabhängige Rückzahlungspläne anmelden und wie man sich für eine Freistellung durch einen Mitunterzeichner qualifizieren kann“.
>
> Equifax-Datenleck: Am 7. September 2017 gab Equifax bekannt, dass es zwischen Mitte Mai und Juli 2017 zu einem der größten Datenlecks in der Geschichte gekommen war. Zu den personenbezogenen Daten, auf die zugegriffen wurde, gehörten Namen, Sozialversicherungsnummern, Geburtsdaten, Adressen und Führerscheinnummern.

Lassen Sie uns nun einen Blick auf die wichtigsten Themen für Navient Solutions und Equifax in diesen Zeiträumen werfen, um unsere Hypothese zu bestätigen.

```sql
-- analyze top issues reported agains Navient Soultions on 2017-01-19 and 2017-01-20
select company, product, issue, count(issue) as counts
from fp_consumer_complaints
where date_received in (
    date '2017-01-19',
    date '2017-01-20') and
    company like 'Navient Solutions%'
group by company, product, issue
order by counts desc;
```

Wir beobachten, dass die beiden häufigsten Beschwerdegründe gegen Navient Solutions die beiden oben genannten Themen betreffen. Außerdem können wir aus den Spalten „Produkt“ und „Problem“ schließen, dass sie tatsächlich mit der Klage bezüglich der Studienkredite zusammenhängen. Lassen Sie uns nun dieselbe Analyse für die Equifax-Probleme durchführen.

```sql
-- analyze top issues reported agains Navient Soultions on 2017-01-19 and 2017-01-20
select
    company,
    product,
    issue,
    count(issue) as counts
from fp_consumer_complaints
where date_received in (
    date '2017-09-08',
    date '2017-09-09',
    date '2017-09-13') and
        company like 'EQUIFAX%'
group by company, product, issue
order by counts desc;
```

Auch hier können wir unsere Hypothese bestätigen. Die wichtigsten Themen sind der Missbrauch von Kreditauskünften, Betrugswarnungen, Identitätsdiebstahl usw. Dies scheint wirklich mit dem Equifax-Datenleck zusammenzuhängen, das etwa zur gleichen Zeit stattgefunden hat.

Dataset
-------

------------------------------------------------------------------------

Die Datenbank für Verbraucherbeschwerden enthält Beschwerdedaten, die beim Consumer Financial Protection Bureau (CFPB) zu Finanzprodukten und -dienstleistungen eingegangen sind, darunter Bankkonten, Kreditkarten, Kreditauskünfte, Inkasso, Geldtransfers, Hypotheken, Studienkredite und andere Arten von Verbraucherkrediten. Der Dataset wird täglich aktualisiert und enthält Informationen zum Anbieter, zur Beschwerde, zum Datum, zur Postleitzahl und mehr. Weitere Informationen zum Dataset finden Sie im Verbraucherbereich der [Data.gov](data.gov)-Website.

Der Dataset **fp\_consumer\_complaints** enthält 1.273.782 Zeilen, die jeweils eine eindeutige Verbraucherbeschwerde darstellen, und 18 Spalten, die die folgenden Merkmale darstellen:

-   `date_received`: Datum, an dem die Beschwerde beim CFPB eingegangen ist
-   `product`: Art des Produkts, das der Verbraucher in der Beschwerde angegeben hat
-   `sub_product`: Art des Unterprodukts, das der Verbraucher in der Beschwerde angegeben hat
-   `issue`: Problem, das der Verbraucher in der Beschwerde identifiziert hat
-   `sub_issue`: Unterproblem, das der Verbraucher in der Beschwerde identifiziert hat
-   `consumer_complaint_narrative`: vom Verbraucher übermittelte Beschreibung des „Vorfalls“ aus der Beschwerde
-   `company_public_response`: optionale, öffentlich zugängliche Antwort des Unternehmens auf die Beschwerde eines Verbrauchers
-   `company`: Beschwerde betrifft dieses Unternehmen
-   `state`: Bundesstaat der vom Verbraucher angegebenen Postanschrift
-   `zip_code`: vom Verbraucher angegebene Postleitzahl
-   `tags`: Daten, die die Suche und Sortierung von Beschwerden erleichtern, die von Verbrauchern oder in deren Namen eingereicht wurden
-   `consumer_consent_provided`: Angabe, ob der Verbraucher die Möglichkeit genutzt hat, seinen Beschwerdebericht zu veröffentlichen
-   `submitted_via`: wie die Beschwerde beim CFPB eingereicht wurde
-   `date_sent_to_company`: Datum, an dem das CFPB die Beschwerde an das Unternehmen gesendet hat
-   `company_response_to_consumer`: wie das Unternehmen reagiert hat
-   `timely_response`: ob das Unternehmen rechtzeitig reagiert hat
-   `consumer_disputed`: ob der Verbraucher die Antwort des Unternehmens bestritten hat
-   `complaint_id`: eindeutige Identifikationsnummer für eine Beschwerde

Erkunden
--------

Anhand dieses Beispiels haben wir gesehen, wie leistungsfähig und einfach es ist, Abfragen in Vantage auszuführen und wie man damit Erkenntnisse aus den Daten gewinnen und die Geschichte hinter einem Dataset erzählen kann. Hoffentlich haben Sie bemerkt, wie einfach es ist, mit Vantage eigene SQL-Abfragen zu schreiben.

Sie können Vantage weiter erkunden, um mithilfe des vorinstallierten Dataset weitere Erkenntnisse zu gewinnen und Antworten auf andere Fragen zu finden. Hier sind einige Vorschläge:

-   Was sind die häufigsten Arten von Beschwerden? Durch Gruppieren der Kategorie **Produkt** können wir diese Antwort erhalten. Wie ändert sich dies im Laufe der Zeit?
-   Wie reichen Kunden ihre Beschwerden ein? Zur Beantwortung dieser Frage kann auch die Spalte **submitted\_via** gruppiert werden.
-   Wie hoch ist der Anteil der strittigen Kundenbeschwerden? Durch die Aggregation der Anzahl von **customer\_disputed** können wir diese Frage beantworten.
-   Gibt es saisonale Schwankungen in den Daten? Was ist der Grund für saisonale Schwankungen? Wenn wir den Trend von der Reihe abziehen, können wir die saisonalen Schwankungen im Dataset analysieren. Werden die meisten Beschwerden unter der Woche oder am Wochenende eingereicht?
