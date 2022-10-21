## Compute Cluster Management with SQL

### Before You Begin

Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

The following is a summary of how to manage Compute Clusters in Vantage CloudLake with SQL.


### Setup 

The following permissions are required for this use case. 

```sql
GRANT CREATE COMPUTE GROUP TO "${username}";
GRANT DROP COMPUTE GROUP TO "${username}";

GRANT CREATE ROLE TO "${username}";
GRANT DROP ROLE TO "${username}";

GRANT CREATE COMPUTE PROFILE TO "${username}";
GRANT DROP COMPUTE PROFILE TO "${username}";
```

### Create a resource group for new research project

A Compute Cluster group contains one or more Compute Clusters and is used to form an association between the users and the resources for the user's queries.

The Query+Strategy policy is provided for future use.

```sql
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### Creating roles for the project

Two roles are provided. 
* An admin role to administrate the Compute Cluster group and the users in the group
* A user role which permits access to the Compute Cluster resources


```sql
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### Associating users with Compute Cluster resources

Users can access Compute Cluster resources by having the user associated with a Compute Cluster group.
The user can be created or modified to have a default association.
The user also can just be granted access and set it directly.

```sql
-- Create a new user
CREATE USER "${USER}" AS 
PASSWORD = "${PASSWORD}"
PERM=1e8
DEFAULT DATABASE = "${USER}"
COMPUTE GROUP = Research_Group;

-- Provide default Compute Cluster resources to an existing user
MODIFY USER "${USER}" AS COMPUTE GROUP = Research_Group;

-- Also provide access to the Compute Cluster resources
GRANT Research_Role TO "${USER}";

-- This user also can administrate the resources
GRANT Research_Admin_Role TO "${USER}";

-- User can set access to any specific group that they have access
SET SESSION COMPUTE GROUP Research_Group;
```

### Assign resources to a group

A Compute Cluster profile describes the resource policy.
A Compute Cluster consists of one or more instances defined using min and max.
Min represents always available count of instances or rank.
Max represents the elastic portion of instances that can be used.
Each instance represents a number of VM nodes such as EC2 instances. 
The number of VM nodes is controlled by the instance size descriptor such as Small, Medium, Large.
Each size has twice the number of VM nodes over the previous size: 2, 4, 8, 16, etc.
There are other options that can be specified for the policy
* initially_suspended hibernates the Compute Cluster after configuration until the user manually RESUMEs the Compute Cluster
* Start and End times can be specified for when the Compute Cluster is operational using cron tab format
* cooldown_period specifies how long the Compute Cluster continues to run after the End time so that queries can complete

```sql
-- View existing maps for available Compute Cluster sizes
SELECT * FROM DBC.ComputeMapsV ORDER BY NodeCount;

-- Provide resources for group
-- $MIN = 1
-- $MAX = MIN to X
-- $COOLDOWN = 1 to Y minutes
-- Create Compute Clusters where X=2 and Y=30 minutes

CREATE COMPUTE PROFILE Research_Resources
IN Research_Group, INSTANCE = TD_COMPUTE_SMALL
USING
MIN_COMPUTE_COUNT  ( 1 ) MAX_COMPUTE_COUNT  ( 2 ) SCALING_POLICY  ('STANDARD') INSTANCE_TYPE  ('STANDARD') 
INITIALLY_SUSPENDED  ('FALSE') START_TIME  ('') END_TIME  ('') COOLDOWN_PERIOD  ( 30 );
```

### Query Compute Cluster dictionary & Get status about the COMPUTE CLUSTER
 
```sql 
-- View existing maps for available Compute Cluster sizes
SELECT * FROM DBC.ComputeMaps ORDER BY NodeCount;

-- Display Compute Cluster Group Compute Cluster Policies
SELECT * FROM DBC.ComputeGroupsV;

-- Similar to the DBC.ComputeGroupsV view but it displays Compute Cluster group details for Compute Cluster groups to which the user has access
SELECT * FROM DBC.ComputeGroupsVX;

-- Provide Compute Cluster state information
SELECT * FROM DBC.ComputeProfilesV;

-- Similar to the DBC.COMPUTE GROUP view but it displays Compute Cluster profile details for Compute Cluster profiles to which the user has access.
SELECT * FROM DBC.ComputeStatusV;
```

### DELETE Compute Cluster profile

```sql
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```