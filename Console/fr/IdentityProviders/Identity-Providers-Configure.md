Ajoutez un fournisseur d'identité compatible SAML 2.0 ou OIDC pour l'authentification unique (SSO) à l'aide des considérations suivantes :

-   **Domaine** : domaine du client de messagerie

-   **Protocole SSO** : OpenID Connect (OIDC) ou SAML 2.0

    -   Pour OIDC :
        -   Récupérez l‘URL de redirection sur la page IDP Vantage Console et effectuez la configuration de l‘application IDP.
    -   Pour les champs de configuration SAML, utilisez les valeurs ci-dessous :
        -   Identifiant (ID d’entité) : https://login.customer.teradata.com
        -   URL de réponse : https://login.customer.teradata.com/sp/ACS.saml2

-   **Revendications** : attributs E-mail et Nom d’utilisateur du compte Vantage pour établir le mappage d’utilisateur

    -   Réclamation au sujet : utilisez `sub` pour OIDC et `SAML_SUBJECT` pour SAML 2.0

Une fois le fournisseur d'identité configuré, vous devez vous déconnecter de la console, puis vous reconnecter à l'aide des informations d'identification de l'entreprise.
