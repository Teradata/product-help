### リモート認証 (CMIC上のServiceConnect のみ)

リモート認証は、ユーザーサービス（RADIUS）のネットワーク プロトコルであり、ポート1812で動作し、ネットワーク　サービスを使用するユーザーに認証、承認、およびアカウンティング管理を提供します。

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>設定</th>
<th>説明</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>ホスト</td>
<td>IPアドレスが静的な場合は、それを使用します。 それ以外の場合は、RADIUSサーバーをホストしているマシンの名前を使用します。</td>
</tr>
<tr class="even">
<td>ポート</td>
<td>デフォルトのRADIUSポートは1812です。別のポートを使用している場合は、値を変更してください。</td>
</tr>
<tr class="odd">
<td>アカウンティング ポート</td>
<td>RADIUSのデフォルトのアカウンティングポートは2813です。別のアカウンティングポートを使用している場合は、値を変更してください。</td>
</tr>
<tr class="even">
<td>リクエストの再試行回数</td>
<td>0 から 10</td>
</tr>
</tbody>
</table>
