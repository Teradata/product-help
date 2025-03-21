Gestión de clúster de computación con SQL
-----------------------------------------

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

Este caso de uso lo guía a través del proceso de creación y administración de recursos computacionales mediante SQL. De manera alternativa, muchas de estas tareas se pueden realizar mediante la interfaz de usuario de la consola de VantageCloud Lake.

### Configuración

Para este caso de uso se requieren los siguientes permisos. Si es necesario, conéctese al editor con un usuario administrativo como “dbc” para otorgar estos permisos al usuario de la base de datos que ejecutará este caso de uso.

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

### Crear un grupo de cálculo

Para este ejercicio, crearemos recursos computacionales para un proyecto de investigación ficticio. Un grupo computacional se utiliza para asociar un grupo empresarial, una aplicación u otro grupo de usuarios con los recursos informáticos elásticos disponibles para procesar la carga de trabajo. Cada grupo computacional contiene uno o más clústeres de recursos computacionales, cada uno de los cuales se denomina perfil computacional.

El argumento QUERY\_STRATEGY define qué tipo de carga de trabajo se ejecutará en los grupos computacionales asociados: STANDARD (operaciones de consulta normales) o ANALYTIC (análisis avanzados, IA/ML o contenedores de Open Analytics Framework).

``` sourceCode
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### Crear roles para el proyecto

Podemos utilizar controles de acceso basados en roles para facilitar la administración de los permisos de los usuarios. Aquí creamos dos roles: \* Un rol de administrador que tiene permisos para administrar los recursos computacionales y los usuarios que pueden acceder a ellos \* Un rol de usuario que permite el acceso a los recursos del grupo computacional

``` sourceCode
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### Asociar usuarios con recursos del grupo computacional

Las consultas de usuario pueden acceder a los recursos computacionales ya sea mediante una asociación predeterminada con el grupo computacional o configurando su asociación por sesión. En ambos casos, el usuario debe tener permisos para el grupo computacional. Los permisos se pueden asignar directamente o mediante acceso basado en roles.

El siguiente SQL muestra cómo: \* Crear un usuario con un grupo computacional predeterminado \* Modificar un usuario para que tenga un grupo computacional predeterminado \* Otorgar varios roles a un usuario \* Hacer que un usuario configure su grupo computacional por sesión

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

### Asignar recursos computacionales a un grupo

Un grupo computacional contiene uno o más perfiles computacionales, de los cuales solo uno está activo en un momento determinado. Un perfil computacional describe los recursos correspondientes y los parámetros asociados disponibles para procesar la carga de trabajo de consultas. Cada perfil computacional describe: \* El tamaño del clúster, desde “XSmall” (un nodo) hasta XXLarge (64 nodos) \* Una política de escalamiento que define la cantidad mínima y máxima de instancias de clúster elástico a las que se puede escalar el perfil. Cada instancia representa un clúster del tamaño seleccionado (XSmall, Medium, Large, etc.) \* Horas de inicio y finalización en formato crontab. Esta capacidad de programación permite un control detallado sobre qué perfil computacional está disponible para el grupo en un momento determinado. \* Un período de recuperación que define cuánto antes deben finalizar las consultas para que se apague un clúster \* initially\_suspended: si el clúster computacional hiberna después de que el usuario lo crea. Los perfiles computacionales se pueden suspender o reanudar manualmente mediante SQL o en la interfaz de usuario de la consola

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

### Consultas adicionales

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

### Limpiar

``` sourceCode
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
