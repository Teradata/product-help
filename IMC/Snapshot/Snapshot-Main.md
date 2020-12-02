### Snapshots

Snapshots are fast full-system backups used for data protection. They allow you to perform a full system backup and restore data into target public cloud Teradata systems with minimal downtime.

Because it is a virtual copy of data, a snapshot is not really complete until it has been replicated to another storage system. For example, you might use a snapshot to replicate a full system copy that you then bring up a second system in another region or zone.

Snapshots cannot perform object-level backups.

Click **Create Snapshot** to create a new snapshot.

Caution: Do not perform ETL operations while creating a snapshot to maintain data integrity and avoid extended recovery times.


#### Recovery

Snapshot recovery varies depending on your installation. Some installations have user-restore functionality, while others automatically open an incident.



