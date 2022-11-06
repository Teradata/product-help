添加用于 SSO 的符合 SAML 2.0 或 OIDC 标准的身份提供程序，并注意以下事项：

-   **域**：电子邮件客户端的域

-   **SSO 协议**: OpenID Connect (OIDC) 或 SAML 2.0

    -   对于 OIDC:
        -   从 Vantage 控制台 IDP 页面获取重定向 URL，并完成 IDP 应用程序配置。
    -   对于 SAML 配置字段，请使用以下值:
        -   标识符 (实体 ID): https://login.customer.teradata.com
        -   回复 URL: https://login.customer.teradata.com/sp/ACS.saml2

-   **声明**: 用于建立用户映射的 Vantage 帐户用户名和电子邮件属性

    -   主题声明: 对于 OIDC，使用 `sub`；对于 SAML 2.0，使用 `SAML_SUBJECT`

配置身份提供程序后，必须从控制台注销，然后使用公司凭据重新登录。
