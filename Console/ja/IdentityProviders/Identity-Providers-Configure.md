ID プロバイダを追加
===================

次のことを考慮して、SSO 用に SAML 2.0 または OIDC に準拠した ID プロバイダを追加します。

-   **ドメイン**: 電子メール クライアントのドメイン

-   **SSO プロトコル**: OpenID Connect (OIDC) または SAML 2.0

    -   OIDC の場合:
        -   Vantage コンソール IDP ページからリダイレクト URL を取得し、IDP アプリケーション構成を行います。
    -   SAML 構成フィールドで、以下の値を使用します。
        -   識別子 (エンティティ ID): https://login.customer.teradata.com
        -   返信 URL: https://login.customer.teradata.com/sp/ACS.saml2

-   **クレーム**: ユーザー マッピングを構築するための Vantage アカウント ユーザー名および電子メールの属性

    -   クレーム件名: OIDC には `sub` を、SAML 2.0 には `SAML_SUBJECT` を使用します。

ID プロバイダを設定した後に、コンソールをログアウトしてから、自分の企業認証情報を使用してログインし直す必要があります。

詳細については、[フェデレーション認証の構成](https://docs.teradata.com/search/all?query=Configuring+Federated+Authentication&content-lang=en-US)を参照してください。
