请根据具体情况，确保满足同一站点或跨站点恢复的必要先决条件。请参见 [恢复标准备份](https://docs.teradata.com/r/Teradata-VantageCloud-Enterprise/Data-Protection/Restoring-a-Standard-Backup) 了解更多详细信息。

默认情况下，选择当前站点进行恢复。对于跨站点恢复，请选择其他站点来恢复备份。

从下面选择恢复备份所必需的设置。

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>选项</th>
<th>详细信息</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>违反访问权限时继续</td>
<td>作业将继续，即使出现 DUMP 访问违规也是如此。</td>
</tr>
<tr class="even">
<td>作为副本作业运行</td>
<td>将数据恢复到内部数据库 ID 与备份集中的数据库 ID 不同的数据库中。当数据库系统为初始系统且数据库 ID 与保存的备份匹配时，<strong>不要选择</strong> 此选项。</td>
</tr>
<tr class="odd">
<td>在目标站点上执行恢复期间，通过添加后缀重命名对象</td>
<td>选择以为重命名的表添加后缀，以区别于初始表。</td>
</tr>
<tr class="even">
<td>恢复到目标站点上的另一个数据库</td>
<td>选择以从可用列表中选择数据库。</td>
</tr>
<tr class="odd">
<td>跳过统计数据</td>
<td>选择以在备份或恢复作业期间跳过统计数据收集操作。</td>
</tr>
</tbody>
</table>

完成设置后，在 **对象** 选项卡中选择所需的数据库和表，验证摘要并运行恢复操作。

**运行失败的恢复作业**

如果恢复作业失败或者完成时出现错误，可以重新运行该作业。具体步骤如下所示:1.在 **作业** 选项卡中，选择失败的作业。2.选择 ![](../Images/more_vert_kebob-15px.svg) 以在“概览”选项卡中查看错误详情。3.在 **设置** 选项卡中，根据需要更改设置。4.在 **对象** 选项卡中选择失败的对象，然后单击 **保存**。5.单击 **运行** 中的 ![](../Images/more_vert_kebob-15px.svg)。
