Análisis de rutas con nPath: Identificar comportamientos basados en patrones
----------------------------------------------------------------------------

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

nPath es una extensión SQL diseñada para realizar análisis rápidos y flexibles de datos ordenados a escala masiva.

Las cláusulas de nPath permiten expresar consultas de rutas complejas y ordenar relaciones que, de otro modo, podrían requerir que escriba uniones de relaciones de varios niveles en SQL del American National Standards Institute (ANSI). Con nPath, usted indica un orden deseado y, luego, especifica un patrón que se buscará en los datos ordenados. Para cada coincidencia del patrón en la secuencia de filas, nPath calcula un agregado SQL sobre las filas coincidentes.

El análisis nPath ayuda a rastrear las rutas que conducen a un resultado, incluido el del comportamiento del cliente:

-   Path-to-purchase
-   Análisis de carritos abandonados
-   Ruta a la baja
-   Recorridos de pacientes, como el reingreso hospitalario
-   Rutas que conducen a actividad fraudulenta

### Ejemplo de baja de un cliente de telecomunicaciones

------------------------------------------------------------------------

En la industria de las telecomunicaciones, abordar el cierre de cuentas, o la baja, es un esfuerzo enorme para ahorrar costes. Con el uso del análisis nPath, se pueden identificar formas de mejorar la retención al comprender el comportamiento de los clientes.

El paso inicial consiste en crear una tabla de eventos para integrar las interacciones y transacciones que involucran al cliente. Al capturar los eventos, puede analizar la ruta del cliente, que puede haber implicado visitar una tienda, ir al sitio web, llamar a la línea de soporte, actualizar el servicio y cancelarlo.

Con el análisis nPath, puede analizar estos eventos de una manera muy sencilla para ayudar a responder preguntas comerciales como:

-   ¿Qué rutas están tomando mis clientes en el sitio web?
-   ¿Qué rutas toman mis clientes antes de llamar a la línea de soporte?
-   ¿Qué rutas toman mis clientes antes de cancelar su servicio?

### Experiencia

El caso de uso completo tarda aproximadamente 7 minutos en ejecutarse.

### Configuración

Seleccione **Cargar activos** para crear las tablas y cargar los datos necesarios en su cuenta (instancia de base de datos de Teradata) para este caso de uso. [Cargar activos](#data=%7B%22id%22:%22Telco%22%7D)

### Ejemplos

------------------------------------------------------------------------

#### Ejemplo n.° 1: todas las rutas

Esta es una consulta común cuando se exploran por primera vez las rutas en los datos. Devuelve un conjunto de resultados mínimo. La única columna de resultados requerida es la salida ACCUMULATE() para la ruta. Agregar el entity\_id ayuda a vincular nuevamente con los datos originales, si es necesario.

La función nPath tomará una tabla de entrada que consta de eventos, la marca de tiempo del evento y cualquier otra información, como ID de sesión, ID de usuario, etc. Proporcionamos varios argumentos a la cláusula USING para controlar el comportamiento de coincidencia de patrones.

El patrón se puede ajustar para lograr mayor especificidad. Por ejemplo, para controlar la cantidad de eventos en la ruta, reemplace A\* por A{3,6} para rutas con, al menos, tres eventos y como máximo, seis:

```sql
SELECT * FROM npath
( 
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp
   USING 
     Mode (NonOverlapping)
     Pattern ('A*') 
     Symbols 
     (
         true as A 
     )
     Result 
     (
         FIRST ( entity_id of ANY (A) ) AS customer_id,
         ACCUMULATE (event of any(A) ) AS path
     )
)
SAMPLE 1000
;
```

Se pueden definir más columnas en la cláusula de resultados para enriquecerlos. A continuación, se muestran algunos ejemplos comunes que pueden resultar útiles.

#### Ejemplo n.° 2: rutas hacia el evento

Al utilizar un patrón que consta de varios símbolos (O y A a continuación), podemos crear una coincidencia más compleja (en este caso, eventos que conducen a una DISPUTA DE FACTURA, con un mínimo de dos y un máximo de seis eventos antes del envío). Tenga en cuenta que podemos agregar SQL estándar a la consulta (en este caso, una cláusula ORDER BY al final).

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('O{2,6}.A')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Ejemplo n.° 3: invertir la dirección de la ruta

Simplemente cambiando el patrón a A.O{1,3}, podemos encontrar las rutas tomadas después de la acción de envío de la aplicación, con un mínimo de uno y hasta tres eventos para comprender el comportamiento del cliente después del envío.

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('A.O{1,3}')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )
     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Ejemplo n.° 4: rutas principales

Al envolver la consulta nPath con cláusulas SQL COUNT/GROUP BY y ordenar por valor descendente, podemos encontrar rápidamente las rutas principales.

Además, observe la sintaxis de nPath PATTERN que aparece a continuación. Aquí, filtramos por rutas que tienen al menos tres coincidencias, sin un número máximo de coincidencias. La sintaxis es **{min, max}**.

``` sourceCode
SELECT path, count(*) as cnt
FROM npath
(
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         true  as A
     )
     Pattern ('A{3,}')

     Result
     (
         FIRST ( entity_id of ANY (A) )                  AS customer_id,
         FIRST ( session_id of ANY(A))                   AS session_id,
         COUNT ( * of any (A) )                          AS cnt,
         FIRST ( event of ANY (A) )                      AS first_event,
         LAST  ( event of ANY (A) )                      AS last_event,
         ACCUMULATE (event of any(A) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
group by 1
order by count(*) desc
SAMPLE 50
;
```

#### Ejemplo n.° 5: Sessionize

En muchos casos, los datos no dividirán los eventos de usuario en sesiones fácilmente definibles. Si bien los datos digitales pueden tener esta información, cuando combinamos múltiples canales o fuentes de datos, necesitamos crear algún límite sobre lo que constituye una sesión de usuario o entidad. La función Sessionize asigna cada evento de una sesión a un identificador de sesión único. Una sesión es una secuencia de eventos de un usuario separados por una duración máxima en segundos.

La función es útil tanto para la creación de sesiones como para detectar la actividad de los robots (rastreadores web). Los datos de eventos basados en robots se pueden filtrar automáticamente de la función mediante un valor de "retraso de clic" si así se desea.

Sessionize también se puede utilizar con nPath para una mejor detección de patrones.

``` sourceCode
select *
from Sessionize
(
    on (select * from telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
    partition by entity_id
    order by datestamp
    using
    TimeColumn('datestamp')
    TimeOut(1200) -- 1200 seconds (20 minutes)
)
order by datestamp
SAMPLE 100
;
```

Conjunto de datos
-----------------

------------------------------------------------------------------------

**telco\_events**: ejemplos de eventos de clientes de Telco:

-   `entity_id`: identificador único del cliente
-   `datestamp`: hora y fecha del evento
-   `session_id`: identificador de sesión
-   `event`: evento o interacción con el cliente
