### プロキシ サーバー (CMIC 上のServiceConnectのみ)

プロキシ サーバーを使用すると、送受信をサーバー経由でルーティングすることを要求できます。プロキシ サーバーを使用するには、プロキシ サーバーを有効にする必要があります。

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
<td>構成ファイルのURL</td>
<td>サイト固有の構成ファイルのURL。 最初は、IPアドレスとポート番号です。 ただし、Teradata UIの外部でカスタム構成を行った後は、代わりにホスト名を指定することもできます。</td>
</tr>
<tr class="even">
<td>HTTPプロキシまたはSOCKSプロキシ</td>
<td>ゲートウェイがHTTPまたはSOCKSプロキシサーバーを経由している場合は、ゲートウェイを有効にし、ホスト名またはIPアドレス、およびHTTP / SOCKSプロキシ構成のポートを入力します。</td>
</tr>
</tbody>
</table>

プロキシ資格情報を要求するには、**信頼証明を使用する** を選択し、ユーザー名とパスワードを入力します。
