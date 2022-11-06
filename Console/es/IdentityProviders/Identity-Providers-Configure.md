Añade un proveedor de identidad compatible con SAML 2.0 u OIDC para el SSO con las siguientes especificaciones:

-   **Dominio**: dominio del cliente de correo electrónico

-   **Protocolo SSO**: OpenID Connect (OIDC) o SAML 2.0

    -   Para OIDC:
        -   Obtén la URL de redirección desde la página del IDP de Vantage Console y completa la configuración de tu aplicación de IDP.
    -   Para los campos de configuración de SAML, usa los valores siguientes:
        -   Identificador (ID de entidad): https://login.customer.teradata.com
        -   URL de respuesta: https://login.customer.teradata.com/sp/ACS.saml2

-   **Reclamaciones**: atributos de nombre de usuario y correo electrónico de cuenta de Vantage para establecer la asignación de usuarios

    -   Reclamación de asunto: usa `sub` para OIDC y `SAML_SUBJECT` para SAML 2.0

Después de configurar el proveedor de identidad, debes cerrar la sesión de Console y luego volver a iniciarla con tus credenciales corporativas.
