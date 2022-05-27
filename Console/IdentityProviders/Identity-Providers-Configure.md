# Add Identity Provider

Add a SAML 2.0- or OIDC-compliant identity provider for SSO with the following considerations:

- **Domain**: Domain of the email client
- **SSO Protocol**: OpenID Connect (OIDC) or SAML 2.0

  - For OIDC:
    - Get the redirect URL from Vantage Console IDP page and complete your IDP application configuration.


  - For SAML configuration fields, use below values:
    - Identifier (Entity ID): https://login.customer.teradata.com
    - Reply URL: https://login.customer.teradata.com/sp/ACS.saml2

- **Claims**: Vantage account user name and Email attributes to establish user mapping

  - Subject claim: Use `sub` for OIDC and `SAML_SUBJECT` for SAML 2.0


 
After you configure the identity provider, you must log out of Console then log back in using your corporate credentials.

See [Configuring Federated Authentication](https://docs.teradata.com/search/all?query=Configuring+Federated+Authentication&content-lang=en-US) for more details.
