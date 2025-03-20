Vantage Path: uso del análisis de rutas para el análisis del comportamiento sin codificación
--------------------------------------------------------------------------------------------

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

nPath es una extensión SQL diseñada para realizar análisis rápidos en datos ordenados.

Vantage Path ofrece interfaces de usuario que ayudan a los usuarios comerciales y a los científicos de datos a comprender los patrones de comportamiento de los clientes y a crear modelos predictivos avanzados. Los modelos utilizan el motor de aprendizaje automático de Vantage (ML Engine). Vantage Path incorpora las funciones analíticas nPath y Sessionize que se ejecutan dentro de ML Engine. Los usuarios seleccionan eventos y parámetros para explorar datos de eventos, identificar patrones y revelar recorridos de clientes.

De manera similar al caso de uso de nPath, Vantage Path ayuda a rastrear rutas que conducen a un resultado. Pero en lugar de escribir SQL, ¡solo se trata de apuntar y hacer clic!

### Ejemplo de baja de un cliente de telecomunicaciones

En la industria de las telecomunicaciones, abordar el cierre de cuentas, o la baja, es un esfuerzo enorme para ahorrar costes. El análisis nPath puede apuntar a formas de mejorar la retención al comprender el comportamiento del cliente.

El paso inicial consiste en crear una tabla de eventos para integrar las interacciones y transacciones que involucran al cliente. Al capturar los eventos, puede ver el recorrido del cliente, que puede haber implicado visitar una tienda, ir al sitio web, llamar a la línea de soporte, actualizar el servicio y cancelarlo.

Con el análisis nPath, ahora puede hacer clic en los eventos para responder preguntas comerciales, como:

-   ¿Qué rutas están tomando mis clientes en el sitio web?
-   ¿Qué rutas toman mis clientes antes de llamar a la línea de soporte?
-   ¿Qué rutas toman mis clientes antes de cancelar su servicio?

### Configuración

Seleccione **Cargar activos** para crear las tablas y cargar los datos necesarios en su cuenta (instancia de base de datos de Teradata) para este caso de uso. [Cargar activos](#data=%7B%22id%22:%22Telco%22%7D)

### Experiencia

El caso de uso completo tarda unos 5 minutos en ejecutarse.

1.  Abra el [Vantage Path](/path-analyzer).
2.  Seleccione la conexión del sistema y autentíquese.
3.  Seleccione la siguiente tabla de eventos: telco\_events.
4.  Seleccione parámetros adicionales o simplemente haga clic en “RUN” y analice los resultados.

### Agregar parámetros adicionales

Puede decidir utilizar parámetros adicionales para realizar un análisis más detallado.

Rutas principales para mostrar: define la cantidad de rutas que coinciden con el patrón que se mostrarán Evento A: evento inicial en el patrón de búsqueda Evento B: evento final en el patrón de búsqueda Recuento mínimo de eventos: cantidad mínima de eventos en el patrón de ruta Recuento máximo de eventos: cantidad máxima de eventos en el patrón de ruta

### Exportación de resultados

#### Ejemplo 1: “Exportar una lista de clientes que están en la ruta a la baja”.

Para “Crear segmento” debe existir una tabla en la fuente de datos de destino con la estructura que se muestra a continuación.

```sql
CREATE SET TABLE path_save_segment
(
     entity_id VARCHAR(100),
     path VARCHAR(2000)
);
```

#### Ejemplo 2: “Guardar la consulta del modelo”

Para “Guardar consulta”, debe existir una tabla en la fuente de datos de destino con la siguiente estructura.

```sql
CREATE SET TABLE path_segment_queries
(
 id        VARCHAR(100),
 name      VARCHAR(1000),
 query     VARCHAR(32000)
);
```

#### Ejemplo 3: “Operacionalizar los resultados con flujo de trabajo”

El flujo de trabajo se puede utilizar para ejecutar los resultados del análisis de ruta según un cronograma. El análisis de ruta se puede guardar y luego utilizar directamente en un nodo de ruta, o se puede exportar el SQL y colocarlo en un nodo SQL. Para utilizar el SQL en un flujo de trabajo, simplemente seleccione “Mostrar SQL” y copie el SQL desde la ventana de su navegador. Estos resultados se pueden pegar en cualquier nodo SQL [flujo de trabajo](/flujo%20de%20trabajo/). La función “Mostrar SQL” también puede ser útil para comprender cómo se construyó el SQL.

### Limpieza

Cuando haya terminado con este ejemplo, recuerde limpiar las tablas creadas:

```sql
DROP TABLE path_save_segment
```

```sql
DROP TABLE path_segment_queries
```
