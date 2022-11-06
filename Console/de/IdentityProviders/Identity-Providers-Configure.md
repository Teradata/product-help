Fügen Sie einen SAML 2.0- oder OIDC-kompatiblen Identitätsanbieter für SSO hinzu und beachten Sie dabei die folgenden Punkte:

-   **Domäne**: Domäne des E-Mail-Clients

-   **SSO-Protokoll**: OpenID Connect (OIDC) oder SAML 2.0

    -   Für OIDC:
        -   Rufen Sie die Umleitungs-URL über die Seite „Vantage-Konsolen-IDP“ ab und schließen Sie die Konfiguration der IDP-Anwendung ab.
    -   Verwenden Sie für SAML-Konfigurationsfelder die folgenden Werte:
        -   Bezeichner (Entitäts-ID): https://login.customer.teradata.com
        -   Antwort-URL: https://login.customer.teradata.com/sp/ACS.saml2

-   **Ansprüche**: Benutzername des Vantage-Kontos und E-Mail-Attribute zum Einrichten von Benutzerzuordnungen

    -   Forderung: Verwenden Sie `sub` für OIDC und `SAML_SUBJECT` für SAML 2.0

Nachdem Sie den Identitätsanbieter konfiguriert haben, müssen Sie sich bei der Konsole abmelden und anschließend mit Ihren Unternehmensanmeldeinformationen wieder anmelden.
