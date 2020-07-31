### Advanced SQL Engine

Site Admins and Super Site Admins can select **Change** to perform SQL Engine operations, such as starting and stopping the database and scaling the instance size.

[Elasticity](#Elasticity)

Keep in mind that:

- Your site isn't available during these operations, so schedule them at a time that minimally impacts users.
- Scaling up or out and expanding volume may incur additional costs.
- After you expand storage volume you can't decrease it.
- Scaling your system restarts the DB, resulting in several minutes of downtime.

If applicable, Hot-Standby Nodes (HSN)s for high availability are listed.

**Tip:** The icon in the Advanced SQL Engine card stops spinning when the operation finishes.

#### Elasticity

- **Stop/Start**: Storage costs are not affected by stopping or starting the instance.
- **Scale Up/Down**: Adjust the instance size. Scaling up incurs additional cost.
- **Scale Out/In**: Adjust the instance quantity. Scaling out incurs additional cost.
- **Expand Storage**: Increase the EBS volume (raw, permanent storage) in 1 TB increments. After you expand storage, you cannot decrease it.

Trial and LIVE Users: You may scale out and in between 3 and 4 nodes. You may scale up and down between 4xl and 8xl.

LIVE Users: Because elasticity operations affect other users on the system, perform this only when needed. Remember to scale down any systems you scale up.   

