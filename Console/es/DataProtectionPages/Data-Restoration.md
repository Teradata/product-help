Asegúrese de cumplir los requisitos previos necesarios para las restauraciones en el mismo sitio o entre sitios, según corresponda. Consulte [Restauración de una copia de seguridad estándar](https://docs.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Restoring-a-Standard-Backup) para obtener más información.

De forma predeterminada, el sitio actual está seleccionado para la restauración. Para la restauración entre sitios, seleccione un sitio diferente para restaurar la copia de seguridad.

Seleccione los ajustes necesarios entre los siguientes para restaurar su copia de seguridad.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>Opción</th>
<th>Detalles</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Continuar si se infringen los derechos de acceso</td>
<td>El trabajo continúa incluso cuando se produce una infracción de los derechos de acceso DUMP.</td>
</tr>
<tr class="even">
<td>Ejecutar como trabajo de copia</td>
<td>Restaura datos en una base de datos con un ID de base de datos interno diferente al del conjunto de copia de seguridad. <strong>No seleccionar</strong> esta opción cuando el sistema de la base de datos es original y el ID de la base de datos coincide con las copias de seguridad guardadas.</td>
</tr>
<tr class="odd">
<td>Cambiar el nombre de los objetos durante la restauración en el sitio de destino añadiendo un sufijo</td>
<td>Seleccione esta opción para agregar un sufijo a las tablas renombradas para diferenciarlas del original.</td>
</tr>
<tr class="even">
<td>Restaurar en otra base de datos del sitio de destino</td>
<td>Seleccione esta opción para elegir la base de datos de la lista disponible.</td>
</tr>
<tr class="odd">
<td>Omitir estadísticas</td>
<td>Seleccione esta opción para omitir la recopilación de estadísticas durante un trabajo de copia de seguridad o restauración.</td>
</tr>
</tbody>
</table>

Cuando haya terminado con la configuración, seleccione las bases de datos y tablas requeridas en la pestaña **OBJETOS**, verifique el resumen y ejecute la restauración.

**Ejecución de trabajos de restauración con errores**

Si la restauración del trabajo falla o se completa con errores, puede volver a ejecutar el trabajo. Deben seguirse estos pasos: 1. En la pestaña **TRABAJOS**, seleccione el trabajo con errores. 2. Seleccione ![](../Images/more_vert_kebob-15px.svg) para ver los detalles de los errores en la pestaña INFORMACIÓN GENERAL. 3. En la pestaña **CONFIGURACIÓN**, realice cambios en la configuración, según sea necesario. 4. Seleccione los objetos con errores en la pestaña **OBJETOS** y haga clic en **GUARDAR**. 5. Haga clic en **EJECUTAR** desde ![](../Images/more_vert_kebob-15px.svg).
