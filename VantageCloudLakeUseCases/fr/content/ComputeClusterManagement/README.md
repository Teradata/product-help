Gestion des clusters de calcul à l'aide du code SQL
---------------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

Ce cas d'utilisation vous guide tout au long du processus de création et de gestion des ressources de calcul à l'aide du code SQL. La plupart de ces tâches peuvent également être effectuées à l'aide de l'interface utilisateur de VantageCloud Lake Console.

### Configuration

Les autorisations suivantes sont requises pour ce cas d'utilisation. Si nécessaire, connectez-vous à l'éditeur à l'aide d'un utilisateur administratif tel que « dbc » pour accorder ces autorisations à l'utilisateur de base de données qui exécute ce cas d'utilisation.

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

### Créer un groupe de calcul

Dans cet exercice, créons des ressources de calcul pour un projet de recherche fictif. Un groupe de calcul permet d'associer un groupe d'entreprises, une application ou un autre groupe d'utilisateurs aux ressources de calcul élastiques disponibles pour traiter la charge de travail. Chaque groupe de calcul contient un ou plusieurs clusters de ressources de calcul, chacun étant appelé profil de calcul.

L'argument QUERY\_STRATEGY définit le type de charge de travail exécuté sur les groupes de calcul associés, soit STANDARD (opérations de requête normales), soit ANALYTIC (conteneurs d'analyses avancées, d'intelligence artificielle ou d'apprentissage automatique, voire Open Analytics Framework)

```sql
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### Créer des rôles pour le projet

Nous pouvons utiliser des contrôles d'accès basés sur les rôles pour faciliter l'administration des autorisations des utilisateurs. Ici, nous créons deux rôles : \* Un rôle d'administrateur qui dispose des autorisations nécessaires pour administrer les ressources de calcul et les utilisateurs qui peuvent y accéder \* Un rôle d'utilisateur qui permet l'accès aux ressources du groupe de calcul

```sql
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### Associer des utilisateurs aux ressources du groupe de calcul

Les requêtes des utilisateurs peuvent accéder aux ressources de calcul à l'aide d'une association par défaut au groupe de calcul ou en définissant celle-ci session par session. Dans les deux cas, l'utilisateur doit disposer d'autorisations pour le groupe de calcul. Les autorisations peuvent être attribuées directement ou via un accès basé sur les rôles.

Le code SQL suivant montre comment : \* Créer un utilisateur à l'aide d'un groupe de calcul par défaut \* Modifier un utilisateur pour qu'il dispose d'un groupe de calcul par défaut \* Accorder différents rôles à un utilisateur \* Demander à un utilisateur de définir son groupe de calcul session par session

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

### Attribuer des ressources de calcul à un groupe

Un groupe de calcul contient un ou plusieurs profils de calcul, dont un seul est actif à un moment donné. Un profil de calcul décrit les ressources de calcul et les paramètres associés disponibles pour traiter la charge de travail des requêtes. Chaque profil de calcul décrit : \* La taille du cluster, de « Très petite » (un seul nœud) à « Très très grande » (64 nœuds) \* Une stratégie d'adaptation de la charge qui définit le nombre minimal et maximal d'instances de clusters élastiques que le profil peut atteindre. Chaque instance représente un cluster de la taille sélectionnée (Très petite, Moyenne, Grande, etc.) \* Heures de début et de fin au format crontab. Cette capacité de planification permet un contrôle précis du profil de calcul disponible pour le groupe à un moment donné. \* Une période de ralentissement qui définit la durée pendant laquelle les requêtes doivent se terminer avant qu'un cluster ne s'arrête \* initially\_suspended : indique si le cluster de calcul se met ou non en veille prolongée après sa création par l'utilisateur. Les profils de calcul peuvent être suspendus ou repris manuellement à l'aide du code SQL ou dans l'interface utilisateur de la console

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

### Requêtes supplémentaires

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

### Nettoyer

```sql
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
