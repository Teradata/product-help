### Snapshots

A snapshot is a virtual copy of data. It is not complete until it has been replicated to another storage system. For example, you might use a snapshot to replicate a full system copy and bring up a second system in another region or zone.

Snapshot recovery varies depending on your installation. Some installations have user-restore functionality, while others automatically open an incident. 

**Notice:** To maintain data integrity and avoid extended recovery times, do not perform ETL operations while creating a snapshot. 

The database pauses and resumes automatically while the snapshot is being created.