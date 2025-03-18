Vantage Path – Utilisation de l'analyse de chemin pour analyser le comportement sans codage
-------------------------------------------------------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

nPath est une extension SQL conçue pour analyser rapidement des données ordonnées.

Vantage Path fournit des interfaces utilisateur qui aident les utilisateurs professionnels et les experts en science des données à comprendre les tendances de comportement des clients et à créer des modèles prédictifs avancés. Les modèles utilisent Vantage Machine Learning Engine (ML Engine). Vantage Path intègre les fonctions d'analyse nPath et Sessionnaliser exécutées dans ML Engine. Les utilisateurs sélectionnent des événements et des paramètres pour explorer des données d'événements, identifier des tendances et révéler des parcours de clients.

Comme dans le cas d'utilisation de nPath, Vantage Path permet de suivre les chemins qui mènent à un résultat. Mais au lieu d'écrire du code SQL, il suffit de pointer et de cliquer !

### Exemple de taux de désabonnement d'un opérateur de télécommunications

Dans le secteur des télécommunications, la gestion de la fermeture de comptes ou du taux de désabonnement représente un effort considérable en termes d'économies. L'analyse nPath permet de cibler les moyens d'améliorer la fidélisation en comprenant le comportement des clients.

La première étape consiste à créer une table d'événements pour intégrer les interactions et les transactions impliquant le client. En capturant les événements, vous pouvez consulter le parcours du client, qui peut avoir impliqué une visite en magasin, un accès au site Web, un appel à l'assistance téléphonique, une mise à niveau du service et une annulation de celui-ci.

Grâce à l'analyse nPath, vous pouvez désormais cliquer sur les événements pour répondre à des questions commerciales, telles que :

-   Quels chemins empruntent mes clients sur le site Web ?
-   Quels chemins empruntent mes clients avant d'appeler l'assistance téléphonique ?
-   Quels chemins empruntent mes clients avant d'annuler leur service ?

### Configuration

Sélectionnez **Charger les actifs** pour créer les tables et charger les données requises dans votre compte (instance de base de données Teradata) pour ce cas d'utilisation. [Charger les actifs](#data=%7B%22id%22:%22Telco%22%7D)

### Expérience

L'ensemble du cas d'utilisation dure environ 5 minutes.

1.  Ouvrez le [Vantage Path](/path-analyzer).
2.  Sélectionnez la connexion système et authentifiez-vous.
3.  Sélectionnez la « Table d'événements » suivante : telco\_events.
4.  Sélectionnez des paramètres supplémentaires ou cliquez simplement sur « EXÉCUTER » et analysez les résultats.

### Ajout de paramètres supplémentaires

Vous pouvez décider d'utiliser des paramètres supplémentaires pour effectuer une analyse complémentaire.

Principaux chemins à afficher : définit le nombre de chemins correspondant à la tendance à afficher Événement A : événement initial dans la tendance de recherche Événement B : événement de fin dans la tendance de recherche Nombre minimal d'événements : nombre minimal d'événements dans la tendance du chemin Nombre maximal d'événements : nombre maximal d'événements dans la tendance du chemin

### Exportation des résultats

#### Exemple 1 – « Exporter une liste de clients qui sont sur le point de se désabonner. »

Afin de « créer un segment », il doit exister une table dans la source de données de destination avec la structure ci-dessous.

``` sourceCode
CREATE SET TABLE path_save_segment
(
     entity_id VARCHAR(100),
     path VARCHAR(2000)
);
```

#### Exemple 2 – « Enregistrer la requête du modèle »

Pour « enregistrer la requête », il doit exister une table dans la source de données de destination avec la structure ci-dessous.

``` sourceCode
CREATE SET TABLE path_segment_queries
(
 id        VARCHAR(100),
 name      VARCHAR(1000),
 query     VARCHAR(32000)
);
```

#### Exemple 3 – « Opérationnaliser les résultats avec le flux de travail »

Vous pouvez utiliser le flux de travail pour exécuter les résultats de l'analyse de chemin selon une planification. L'analyse de chemin peut être enregistrée, puis utilisée directement dans un nœud de chemin, ou le code SQL peut être exporté et placé dans un nœud SQL. Pour utiliser la requête SQL dans un flux de travail, cliquez simplement sur « Afficher le code SQL » et copiez ce dernier à partir de la fenêtre de votre navigateur. Ces résultats peuvent ensuite être collés dans n'importe quel nœud SQL [flux de travail](/flux%20de%20travail/). La fonctionnalité « Afficher le code SQL » peut également être utile pour comprendre comment ce dernier a été construit.

### Nettoyage

Lorsque vous avez terminé cet exemple, n'oubliez pas de nettoyer les tables créées :

``` sourceCode
DROP TABLE path_save_segment
```

``` sourceCode
DROP TABLE path_segment_queries
```
