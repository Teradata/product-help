### ポリシーサーバー (CMIC 上のServiceConnectのみ)

ポリシーサーバーにより、ServiceConnectを介してリモート アクセスを制御することができます。この機能は、Teradataから取得してから有効にする必要があります。

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
<td>ポリシーサーバーのホスト名またはIPアドレス</td>
</tr>
<tr class="even">
<td>ポート</td>
<td>8009</td>
</tr>
<tr class="odd">
<td>SSLを使用する</td>
<td>SSLは、接続のセキュリティ保護に役立ちます。暗号スイート名または<strong>すべて</strong>を入力して、検証します。</td>
</tr>
<tr class="even">
<td>HTTPプロキシまたはSOCKSプロキシ</td>
<td>ゲートウェイがHTTPまたはSOCKSプロキシサーバーを経由している場合は、ゲートウェイを有効にし、ホストIPアドレスまたは名前、およびHTTP/SOCKSプロキシ構成のポートを入力します。</td>
</tr>
</tbody>
</table>

プロキシ資格情報を要求するには、**信頼証明を使用する**を選択し、ユーザー名とパスワードを入力します。
