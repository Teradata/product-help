Reemplazo total de rodilla: análisis de ruta
--------------------------------------------

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

Este libro de trabajo proporciona un guión de demostración básico que muestra las capacidades de Vantage Path. El público objetivo es el analista de negocios. El guión de demostración se ha diseñado de manera que la sección Exploración de la ruta hacia el reemplazo total de rodilla se pueda utilizar de forma aislada (por ejemplo, para una breve reunión informal de introducción) o en combinación con las otras secciones para una demostración más completa.

### Experiencia

La sección Experiencia tarda entre 7 y 10 minutos en ejecutarse.

El primer paso es abrir [Vantage Path](/path-analyzer).

### Configuración

Seleccione **Cargar activos** para crear las tablas y cargar los datos necesarios en su cuenta (instancia de base de datos de Teradata) para este caso de uso. [Cargar activos](#data=%7B%22id%22:%22KneeReplacement%22%7D)

### Tutorial

------------------------------------------------------------------------

#### Paso 1: Exploración de la ruta hacia el reemplazo total de rodilla

Voy a demostrar las capacidades de análisis de Vantage Path utilizando datos de atención médica. En concreto, vamos a analizar las rutas de procedimientos médicos más frecuentes para el reemplazo total de rodilla.

Usando el panel de la derecha estableceré los valores de la siguiente manera: - Dejar las rutas principales para mostrar como 25 - Seleccionar la fuente de datos: - Base de datos de eventos: retail\_sample\_data - Tabla de eventos: knee\_replacement

Elijo no establecer un filtro y, en su lugar, utilizar todos los eventos. Para el patrón de eventos: - Evento A: dejar como "Cualquier evento" - Evento B: cambiar de "Cualquier evento" a "Reemplazo total de rodilla"

Y dejaré Mínimo de eventos, Máximo de eventos y Permitir superposición como configuraciones predeterminadas.

Para este escenario de demostración, no necesito limitar el rango de fechas (sin embargo, este filtro podría ser útil en otras situaciones).

Por último, necesito seleccionar la columna de sesión (entity\_id) para indicar al análisis de ruta al que pertenecen los eventos en la misma ruta. Algunos análisis de rutas, como las de un sitio web, se cotejarán por session\_id. En este escenario, session\_id es igual al paciente (entity\_id).

Una vez introducida toda la información requerida por la consulta, puedo seleccionar el botón Ejecutar, momento en el cual se genera dinámicamente una consulta y se envía al sistema Vantage, y en poco tiempo, nos devolverá una visualización aquí en la interfaz.

#### Paso 2: Visualización

La visualización inicial que se devuelve resalta la ruta más común hacia el reemplazo total de rodilla.

Una vez que la visualización ha regresado, tengo varias opciones disponibles: - Puedo explorar manualmente expandiendo la ruta en cada nodo de interés (haciendo clic en un círculo naranja abierto como Artroscopia de rodilla). Los círculos de color naranja completo indican que se muestra la ruta completa para este nodo. - Expandir todo: muestra todas las rutas - Contraer todo: muestra solo el evento final (reemplazo total de rodilla) - Seleccionar dominante: resalta la ruta más popular

-   Puedo verificar las etiquetas de recuento de programas que muestran la cantidad de personas que han pasado por cada segmento de ruta específico (por ejemplo, desde pruebas de rango de movimiento hasta fisioterapia NEC).

-   También puedo alternar entre un diagrama de ruta y una lista de tabla de los eventos de ruta y el recuento. La lista de tabla es lo que se habría obtenido si hubiera ejecutado este análisis a través de una consulta directa en lugar de la interfaz.

Como puede ver al observar la ruta dominante, la biopsia de la articulación de la rodilla es el último paso más común antes del reemplazo total de rodilla. Exploremos esto más a fondo para ver si podemos identificar otras rutas que no hayan llevado al reemplazo total de rodilla. - Primero, exploremos las rutas desde la biopsia de la articulación de la rodilla seleccionando Biopsia de la articulación de la rodilla como Evento A y Cualquier evento para Evento B (Seleccionar Ejecutar). - Como se esperaba, la ruta dominante termina con el reemplazo total de rodilla, sin embargo, también hay otros procedimientos.

-   Dentro de Vantage Path podemos cambiar fácilmente la dirección de la ruta, y hagámoslo para explorar una ruta hacia la biopsia de la articulación de la rodilla.  
-   Sin embargo, antes de seleccionar Ejecutar, verificaremos la opción de anclaje final: esta opción garantizará que la biopsia de la articulación de la rodilla sea el último evento en la ruta y, por lo tanto, los pacientes no hayan pasado al reemplazo total de rodilla.
-   En esta visualización podemos ver la ruta más común para la biopsia de la articulación de la rodilla y es posible que nos interese realizar análisis adicionales en los pacientes en esta ruta.

Cuando se elige el dominante (o cualquier ruta, en realidad), tengo la capacidad de almacenar los resultados en una tabla para un análisis posterior mediante la función Crear segmento.

Si no continúa con la demostración del paso 3: Creación de segmento, simplemente omita la siguiente sección y pase a la conclusión.

#### Paso 3: Creación de segmento

Para demostrar la capacidad de Crear segmento, ya debe haber una tabla de salida creada en su base de datos personal (ya que se requiere acceso de escritura).

``` sourceCode
CREATE TABLE knee_replacement_path_export(
    entity_id    varchar(100),
    path        varchar(2000)
)
```

Si ya ha ejecutado la demostración y no ha vuelto a crear la tabla, asegúrese de que esta esté vacía. De lo contrario, Guardar segmento mostrará 0 filas insertadas.

El análisis de rutas permite la exploración visual y, a menudo, cuando se identifica una ruta interesante, las personas que la recorren resultan de interés para un análisis más profundo. Exploremos ahora la función Crear segmento.

Cuando hago clic en el botón Crear segmento, puedo elegir una base de datos (a la que tengo acceso de escritura) y una tabla (use la que creó en la configuración).

Ahora tengo algunas opciones: - Mostrar SQL: este es el SQL que ejecuta Vantage. Puedo copiar este SQL y pegarlo en una herramienta de consulta como Vantage Editor o Jupyter para una exploración más profunda. - Guardar segmento: se ejecuta la consulta y el resultado se guarda en la tabla especificada. Una vez que se completa la consulta, se mostrará la cantidad de filas.

    - Save Query –  with this option the query is given a name and the SQL is saved to a table on Vantage.

    - Now that I have saved a segment – let’s take a look at the resulting table. I am going to switch to Vantage Editor
    - If I view the insights from the knee_replacement_path_export table I can see that it has 2,757 records as well as the columns and ddl statement.
    - Running a simple select query I can see the result - Entity_id and Path (the dominant path selected).

-   El segmento guardado se puede utilizar como entrada para un análisis posterior, como la agrupación para ver si hay puntos en común entre los pacientes o potencialmente como entrada para un plan de tratamiento para estos pacientes que pueden ser candidatos para procedimientos menos invasivos.

#### Limpieza

Cuando haya terminado con este ejemplo, recuerde limpiar la tabla creada:

``` sourceCode
DROP TABLE knee_replacement_path_export
```

#### Conclusión

Como puede ver en esta breve demostración, Vantage Analyst ofrece una interfaz de usuario sencilla para realizar análisis de rutas como el que acabamos de ver. El análisis de rutas puede abarcar varios temas y distintas industrias.

Algunos ejemplos incluyen: - rutas de compra del cliente - rutas en línea hasta el abandono del carrito - rutas de quejas del cliente - rutas hasta la falla de la pieza

Conjunto de datos
-----------------

------------------------------------------------------------------------

El conjunto de datos **knee\_replacement** tiene 289.839 filas, cada una de las cuales representa un procedimiento al que se ha sometido un paciente. El conjunto de datos está desnormalizado, por lo que parte de la información del paciente se repite en cada fila:

-   `memberid`: identificador único del paciente
-   `proccode`: identificador del procedimiento
-   `diagcode`: diagnóstico original del paciente
-   `shortdesc`: breve descripción del procedimiento
-   `amount`: coste del procedimiento
-   `tstamp`: fecha y hora del procedimiento
-   `firstname`: nombre del paciente
-   `lastname`: apellido del paciente
-   `email`: dirección de correo electrónico del paciente
-   `state`: abreviatura del estado del paciente
