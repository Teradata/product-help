### Edit Job

With the right privileges, use this to edit the details of a backup job.

#### Job Priority

When two jobs are scheduled to run at the same time, the job with the higher Priority (1 to 5, where 1 is the highest) runs. Here's how it works:

- By default, every job is assigned a priority of 5.
- If two jobs with different priorities are scheduled to run at the same time, the job with the higher priority runs; the lower priority job does not.
- If two jobs with the same priority are scheduled to run at the same time, they both run.
- If a higher priority job is already running when a lower priority job is scheduled, the lower priority job does not run.
