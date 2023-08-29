Make sure you meet the necessary prerequisites for same-site or cross-site restorations, as the case may be. See [Restoring a Standard Backup](https://docs.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Restoring-a-Standard-Backup) for more details.

By default, the current site is selected for restoration. For cross-site restoration, select a different site to restore the backup.

Select the necessary settings from the following for restoring your backup.

| Option  | Details  |
|---|---|
| Continue on access rights violation  |The job proceeds even when the DUMP access rights violation occurs.  |
| Run as copy job  |Restores data into a database with a different internal database ID than the one in the backup set. **Do not select** this option when the database system is original, and the database ID matches with the saved backups.   |
| Rename objects during restore on the target site by adding a suffix |Select to add a suffix for renamed tables to differentiate from the original.   |  
|Restore to a different database on the target site|Select to choose the database from the available list.|
|Skip statistics|Select to skip collecting statistics during a backup or restore job. |

Once done with settings, select the required databases and tables in the **OBJECTS** tab, verify the summary and run the restore.

**Running Failed Restore Jobs**

If the job restoration fails or completes with errors, you can rerun the job. The steps to follow are:
1.	In the **JOBS** tab, select the failed job.
2.	Select 
![../Images/more_vert_kebob-15px.svg](../Images/more_vert_kebob-15px.svg) to view the details of errors in the OVERVIEW tab.
3.	In the **SETTINGS** tab, make changes in the settings, as needed.
4.	Select the objects that failed in the **OBJECTS** tab and click **SAVE**.
5.	Click **RUN** from the ![../Images/more_vert_kebob-15px.svg](../Images/more_vert_kebob-15px.svg).
See [Disaster Recovery](https://docs-dev.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Disaster-Recovery) for more details.
