S3 バケット ポリシーの設定
==========================

Teradata Vantage が Amazon S3 データを読み書きできるようにするには、クラウド管理者が、Amazon S3 バケット ポリシーが、バケットへのアクセスを許可するロールに対する次のアクションで設定されていることを確認する必要があります。

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:GetObject

**ヒント**: デモ ユース ケースの実行中に NOS を使用する場合は、Teradata が管理している Amazon S3 バケットにアクセスするようになっているため、ポリシーを設定する必要はありません。

**リソース**

-   [Amazon S3バケットへのアクセスを付与](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)
