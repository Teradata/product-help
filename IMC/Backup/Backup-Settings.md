### Settings

[Job Status](#job-status)

[Retained copies](#retained-copies)

[Job priority](#job-priority)

[Auto-abort](#auto-abort)

#### Job Status

Select **Enable** or **Disable** to enable or disable the backup job.

#### Retained copies

Select the number of backup copies to be maintained, between 1 and 30. Adding more backups may result in additional usage charges. If you reduce the number of retained backups, the next complete backup process deletes those excess backups. Deleted excess backups cannot be recovered.

#### Job priority

When two jobs are scheduled to run at the same time, the job with the higher priority runs, where 1 is the highest and 5 is the lowest.  Here's how it works:

- By default, every job is assigned a priority of 5.
- If two jobs with different priorities are scheduled to run at the same time, the job with the higher priority runs; the lower-priority job does not.
- If two jobs with the same priority are scheduled to run at the same time, they both run.

#### Auto-abort

To automatically abort a backup job after a certain amount of time, select the time.