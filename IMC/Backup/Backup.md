### Managing Backups
Site Admins and Super Site Admins can manage backups. 

By default, Teradata backs up your site daily and retains the two most recent full backups.

- [Change the Backup Schedule](#change-the-backup-schedule)
- [Restore from a Backup](#restore-from-a-backup)

#### Change the Backup Schedule
To see the schedule, click **View Details** under **Backups**.
Enter a change request in the console to make any of the following changes to your schedule:

- Enable weekly and monthly backups
- Enable auto-restart to rerun failed backups
- Cancel in-progress backups
- Suspend future backups
- Receive weekly backup reports by email
- Request NOSYNC option for backups

For other changes, contact Teradata.

#### Restore from a Backup
To restore a backup, enter a change request in the console. 

You can restore NewSQL Engine tables, databases, and full system-level data.
Restored data can be written to an alternate table or database if there is adequate space. For an additional
fee, you can restore data to somewhere other than the source platform.
