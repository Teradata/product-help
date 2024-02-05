## Compute Cluster Management with SQL

### Before You Begin

Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

This use case guides you through the process of creating and managing compute resources using SQL. Alternatively, many of these tasks can be performed using the VantageCloud Lake Console UI.

### Setup 

The following permissions are required for this use case. If necessary, connect to the Editor with an administrative user such as “dbc” to grant these permissions to the database user who will be executing this use case.

```sql
GRANT CREATE COMPUTE GROUP TO "${username}" WITH GRANT OPTION;
GRANT DROP COMPUTE GROUP TO "${username}" WITH GRANT OPTION;

GRANT CREATE ROLE TO "${username}" WITH GRANT OPTION;
GRANT DROP ROLE TO "${username}" WITH GRANT OPTION;

GRANT CREATE COMPUTE PROFILE TO "${username}" WITH GRANT OPTION;
GRANT DROP COMPUTE PROFILE TO "${username}" WITH GRANT OPTION;

GRANT SELECT ON DBC.ComputeGroupsV TO "${username}";
GRANT SELECT ON DBC.ComputeProfilesV TO "${username}";
GRANT SELECT ON DBC.ComputeStatusV TO "${username}";
GRANT SELECT ON DBC.ComputeMaps TO "${username}";
GRANT SELECT ON DBC.ComputeMapsV TO "${username}";
```

### Create a compute group

For this exercise, let’s create compute resources for a fictional research project. A compute group is used to associate a business group, application, or other group of users with the elastic compute resources available to process workload. Each compute group contains one or more clusters of compute resources, each of which is called a compute profile.  

The QUERY_STRATEGY argument defines what type of workload will be run on the associated compute groups—either STANDARD (normal query operations) or ANALYTIC (advanced analytics, AI/ML, or Open Analytics Framework containers) 

```sql
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### Create roles for the project

We can use role-based access controls to provide easier administration of user permissions.  Here we create two roles: 
* An admin role that has permissions to administer the compute resources and users who can access them
* A user role that permits access to the compute group resources 


```sql
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### Associate users with compute group resources

User queries can access compute resources by either having a default association to the compute group or setting their association on a per-session basis. In both cases, the user must have permissions for the compute group. Permissions can be assigned directly or via role-based access.

The following SQL shows how to:
* Create a user with a default compute group 
* Modify a user to have a default compute group
* Grant various roles to a user
* Have a user set their compute group on a per-session basis

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

-- This user also can administer the resources
GRANT Research_Admin_Role TO "${USER}";

-- User can set access to any specific group that they have access
SET SESSION COMPUTE GROUP Research_Group;
```

### Assign compute resources to a group

A compute group contains one of more compute profiles—only one of which is active at any given time. A compute profile describes compute resources and associated parameters available to process query workload. Each compute profile describes: 
* The cluster size, from “XSmall” (one node) to XXLarge (64 nodes)
* A scaling policy that defines the minimum and maximum number of elastic cluster instances that the profile can scale to. Each instance represents a cluster of the selected size (XSmall, Medium, Large, etc.)
* Start and end times in crontab format. This scheduling capability allows for fine-grained control over which compute profile is available to the group at any given time.
* A cooldown period that defines how long queries have to finish before a cluster shuts down 
* initially_suspended—whether the compute cluster hibernates after the user creates it. Compute profiles can be manually suspended or resumed using SQL or in the Console UI

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

### Additional queries
 
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

### Clean up

```sql
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
