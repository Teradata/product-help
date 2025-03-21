Verwaltung von Computing-Clustern mit SQL
-----------------------------------------

### Bevor Sie beginnen

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Einführung

Dieser Anwendungsfall führt Sie durch den Prozess der Erstellung und Verwaltung von Computing-Ressourcen mit SQL. Alternativ können viele dieser Aufgaben über die VantageCloud Lake Console-Benutzeroberfläche ausgeführt werden.

### Einrichtung

Für diesen Anwendungsfall sind die folgenden Berechtigungen erforderlich. Melden Sie sich bei Bedarf mit einem Administratorbenutzer wie „dbc“ beim Editor an, um diese Berechtigungen dem Datenbankbenutzer zu erteilen, der diesen Anwendungsfall ausführen wird.

``` sourceCode
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

### Computing-Gruppe erstellen

Für diese Übung erstellen wir Computing-Ressourcen für ein fiktives Forschungsprojekt. Eine Computing-Gruppe wird verwendet, um einer Geschäftsgruppe, Anwendung oder anderen Benutzergruppe die flexiblen Computing-Ressourcen zuzuordnen, die zur Verarbeitung der Arbeitslast verfügbar sind. Jede Computing-Gruppe enthält einen oder mehrere Cluster von Computing-Ressourcen, von denen jeder als Computing-Profil bezeichnet wird.

Das Argument QUERY\_STRATEGY definiert, welche Art von Arbeitslast in den zugehörigen Computing-Gruppen ausgeführt wird – entweder STANDARD (normale Abfragevorgänge) oder ANALYTIC (erweiterte Analysen, KI/ML oder Open Analytics Framework-Container).

``` sourceCode
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### Rollen für das Projekt erstellen

Wir können rollenbasierte Zugriffssteuerungen verwenden, um die Verwaltung von Benutzerberechtigungen zu vereinfachen. Hier erstellen wir zwei Rollen: \* Eine Administratorrolle, die über Berechtigungen zur Verwaltung der Computing-Ressourcen und der Benutzer verfügt, die auf sie zugreifen können. \* Eine Benutzerrolle, die den Zugriff auf die Ressourcen der Computing-Gruppe ermöglicht.

``` sourceCode
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### Benutzer zu Computing-Gruppenressourcen zuordnen

Benutzerabfragen können auf Computing-Ressourcen zugreifen, indem sie entweder eine Standardzuordnung zur Computing-Gruppe haben oder ihre Zuordnung pro Sitzung festlegen. In beiden Fällen muss der Benutzer über Berechtigungen für die Computing-Gruppe verfügen. Berechtigungen können direkt oder über rollenbasierten Zugriff zugewiesen werden.

Die folgende SQL-Anweisung zeigt, wie Sie: \* einen Benutzer mit einer Standard-Computing-Gruppe erstellen \* einen Benutzer so ändern, dass er eine Standard-Computing-Gruppe hat \* einem Benutzer verschiedene Rollen zuweisen \* einen Benutzer seine Computing-Gruppe für die jeweilige Sitzung festlegen lassen

``` sourceCode
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

### Computing-Ressourcen zu einer Gruppe zuweisen

Eine Computing-Gruppe enthält ein oder mehrere Computing-Profile, von denen zu einem bestimmten Zeitpunkt immer nur eines aktiv ist. Ein Computing-Profil beschreibt die zur Verarbeitung der Abfrage-Arbeitslast verfügbaren Computing-Ressourcen und zugehörigen Parameter. Jedes Computing-Profil beschreibt: \* Die Clustergröße, von „XSmall“ (ein Knoten) bis „XXLarge“ (64 Knoten) \* Eine Skalierungsrichtlinie, die die minimale und maximale Anzahl elastischer Clusterinstanzen definiert, auf die das Profil skaliert werden kann. Jede Instanz stellt einen Cluster der ausgewählten Größe dar (XSmall, Medium, Large usw.) \* Start- und Endzeiten im Crontab-Format. Diese Planungsfunktion ermöglicht eine detaillierte Kontrolle darüber, welches Computing-Profil der Gruppe zu einem bestimmten Zeitpunkt zur Verfügung steht. \* Eine Abkühlzeit, die definiert, wie lange Abfragen dauern dürfen, bevor ein Cluster heruntergefahren wird \* „initially\_suspended“ – ob der Computing-Cluster in den Ruhezustand versetzt wird, nachdem der Benutzer ihn erstellt hat. Computing-Profile können manuell mit SQL oder in der Konsolen-Benutzeroberfläche angehalten oder fortgesetzt werden.

``` sourceCode
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

### Weitere Abfragen

``` sourceCode
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

### Bereinigen

``` sourceCode
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
