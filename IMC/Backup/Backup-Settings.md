### Backup Settings

**Job Status**

Enable or disable the backup job.

**Retention Count**

The number of backup copies maintained.

Remember that adding more backups may result in additional usage charges.

If you reduce the number of retained backups, the next complete backup process deletes those excess backups. They cannot be recovered.

**Priority**

When two jobs are scheduled to run at the same time, the job with the higher Priority (1 to 5, where 1 is the highest) runs. Here's how it works:

- By default, every job is assigned a priority of 5.
- If two jobs with different priorities are scheduled to run at the same time, the job with the higher priority runs; the lower-priority job does not.
- If two jobs with the same priority are scheduled to run at the same time, they both run. 

**Auto Abort**

Set this to automatically abort a backup job after a certain amount of time. 