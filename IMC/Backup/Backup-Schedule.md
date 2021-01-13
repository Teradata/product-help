### Schedule

If there are the backup jobs scheduled to run, they are listed here.

Select **+**, then select the type and time to add a backup schedule.

Select ![more_vert_kebob-15px.svg](more_vert_kebob-15px.svg)>**Edit** or **Delete** to edit or delete a backup schedule.

- **Delta Run** is an incremental backup that **????**. **Full Run** is a full backup that **????** The first time you run the job, it will be a full backup, even if you select **Delta Run**.
- Select the time in UTC and frequency that you want the backup to run. If you select **Last Day of Month**, you cannot select any other days. In that case, you'd have to create two backup jobs.
- When you add a new schedule, the system warns you of conflicts with other schedules. Failure to correct those could result in skipped backups or other issues.