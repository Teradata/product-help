Assurez-vous que vous remplissez les conditions requises pour les restaurations sur le même site ou sur plusieurs sites, le cas échéant. Pour plus d'informations, reportez-vous à la section [Restauration d'une sauvegarde standard](https://docs.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Restoring-a-Standard-Backup).

Par défaut, le site actuel est sélectionné pour la restauration. Pour la restauration sur plusieurs sites, sélectionnez un autre site pour restaurer la sauvegarde.

Pour restaurer votre sauvegarde, sélectionnez les paramètres nécessaires parmi les suivants.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>Option</th>
<th>Détails</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Poursuivre sur violation des droits d’accès</td>
<td>La tâche se poursuit même en cas de violation des droits d’accès DUMP.</td>
</tr>
<tr class="even">
<td>Exécuter en tant que tâche de copie</td>
<td>Restaure les données dans une base de données avec un ID de base de données interne autre que celui inclus dans le jeu de sauvegarde. <strong>Ne pas sélectionner</strong> cette option lorsque le système de base de données est d’origine et que l’ID de base de données correspond aux sauvegardes enregistrées.</td>
</tr>
<tr class="odd">
<td>Renommer les objets pendant la restauration sur le site cible en ajoutant un suffixe</td>
<td>Sélectionnez cette option pour ajouter un suffixe aux tables renommées afin de les différencier de l’original.</td>
</tr>
<tr class="even">
<td>Restaurer vers une autre base de données sur le site cible</td>
<td>Sélectionnez cette option pour choisir la base de données dans la liste disponible.</td>
</tr>
<tr class="odd">
<td>Ignorer les statistiques</td>
<td>Sélectionnez cette option pour ignorer la collecte de statistiques pendant une tâche de sauvegarde ou de restauration.</td>
</tr>
</tbody>
</table>

Une fois que vous en avez terminé avec les paramètres, sélectionnez les bases de données et les tables requises dans l’onglet **OBJETS**, vérifiez le résumé et exécutez la restauration.

**Exécution des tâches de restauration en échec**

Si la restauration de la tâche échoue ou se termine avec des erreurs, vous pouvez réexécuter la tâche. Voici les étapes à suivre : 1. Dans l’onglet**TÂCHES**, sélectionnez la tâche en échec. 2. Sélectionnez ![](../Images/more_vert_kebob-15px.svg) pour afficher les détails des erreurs dans l’onglet PRÉSENTATION. 3. Dans l’onglet **PARAMÈTRES**, effectuez des modifications dans les paramètres, si nécessaire. 4. Sélectionnez les objets ayant échoué dans l’onglet **OBJETS** et cliquez sur **ENREGISTRER**. 5. Cliquez sur **EXÉCUTER** à partir de ![](../Images/more_vert_kebob-15px.svg).
