Vergewissern Sie sich, dass Sie die notwendigen Voraussetzungen für Site-gleiche oder Site-übergreifende Wiederherstellungen erfüllen. Weitere Informationen finden Sie unter [Wiederherstellen einer Standardsicherung](https://docs.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Restoring-a-Standard-Backup).

Standardmäßig wird die aktuelle Site für die Wiederherstellung ausgewählt. Für eine Site-übergreifende Wiederherstellung wählen Sie eine andere Site zur Wiederherstellung der Sicherung aus.

Wählen Sie im Folgenden die erforderlichen Einstellungen für die Wiederherstellung Ihrer Sicherung aus.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>Option</th>
<th>Details</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Bei Verletzung der Zugriffsrechte fortfahren</td>
<td>Der Auftrag wird auch dann fortgesetzt, wenn die DUMP-Zugriffsrechte verletzt werden.</td>
</tr>
<tr class="even">
<td>Als Kopierauftrag ausführen</td>
<td>Stellt Daten in einer Datenbank wieder her, deren interne Datenbank-ID sich von derjenigen im Sicherungssatz unterscheidet. <strong>Nicht auswählen</strong>, wenn das Datenbanksystem ein Original ist und die Datenbank-ID mit den gespeicherten Sicherungen übereinstimmt.</td>
</tr>
<tr class="odd">
<td>Objekte während der Wiederherstellung auf der Ziel-Site durch Hinzufügen eines Suffixes umbenennen</td>
<td>Wählen Sie diese Option aus, um ein Suffix für umbenannte Tabellen hinzuzufügen, um sie vom Original zu unterscheiden.</td>
</tr>
<tr class="even">
<td>In einer anderen Datenbank auf der Zielsite wiederherstellen</td>
<td>Wählen Sie diese Option aus, um die Datenbank aus der verfügbaren Liste auszuwählen.</td>
</tr>
<tr class="odd">
<td>Statistiken überspringen</td>
<td>Wählen Sie diese Option aus, um das Sammeln von Statistiken während eines Sicherungs- oder Wiederherstellungsauftrags zu überspringen.</td>
</tr>
</tbody>
</table>

Sobald Sie die Einstellungen vorgenommen haben, wählen Sie die gewünschten Datenbanken und Tabellen auf der Registerkarte **OBJEKTE** aus, überprüfen die Zusammenfassung und führen die Wiederherstellung aus.

**Fehlgeschlagene Wiederherstellungsaufträge werden ausgeführt**

Wenn die Wiederherstellung des Auftrags fehlschlägt oder mit Fehlern abgeschlossen wird, können Sie den Auftrag erneut ausführen. Nachstehend finden Sie die zu befolgenden Schritte: 1. Wählen Sie auf der Registerkarte **AUFTRÄGE** den fehlgeschlagenen Auftrag aus. 2. Wählen Sie ![](../Images/more_vert_kebob-15px.svg) aus, um die Details der Fehler auf der Registerkarte ÜBERSICHT anzuzeigen. 3. Nehmen Sie auf der Registerkarte **EINSTELLUNGEN** nach Bedarf Änderungen an den Einstellungen vor. 4. Wählen Sie die fehlgeschlagenen Objekte auf der Registerkarte **OBJEKTE** aus und klicken Sie auf **SPEICHERN**. 5. Klicken Sie unter **AUSFÜHREN** auf ![](../Images/more_vert_kebob-15px.svg).
