# Schedules in Data Protection Pages
Select **+**,  then select the type and time to add a backup schedule.

Select ![../Images/more_vert_kebob-15px.svg](../Images/more_vert_kebob-15px.svg) > **Edit** or ![../Images/more_vert_kebob-15px.svg](../Images/more_vert_kebob-15px.svg) > **Delete** to edit or delete a backup schedule respetively.
- **Delta Run** is an incremental backup that includes only changes. **Full Run** backs up everything. The first time you run the job, it will be a full backup, even if you select Delta Run.
- Select the time in UTC and frequency that you want the backup to run. If you select **Last Day of Month**, you cannot select any other days. If you also want to run a backup on a day that is not the last day of the month, create a second backup.
- When you add a new schedule, the system warns if there are conflicts with other schedules. Failure to correct those could result in skipped backups or other issues.
