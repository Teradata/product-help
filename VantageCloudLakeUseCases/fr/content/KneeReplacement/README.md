Remplacement total du genou – Analyse de chemin
-----------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

Ce manuel fournit un script de démo de base présentant les fonctionnalités de Vantage Path. Le public cible est l'analyste commercial. Le script de démo a été conçu de manière que la section « Exploration du chemin vers le remplacement total du genou » puisse être utilisée de manière isolée (par exemple, pour une brève réunion initiale informelle) ou en combinaison avec les autres sections pour permettre une démonstration plus complète.

### Expérience

La section Expérience dure environ de 7 à 10 minutes.

La première étape consiste à ouvrir [Vantage Path](/path-analyzer).

### Configuration

Sélectionnez **Charger les actifs** pour créer les tables et charger les données requises dans votre compte (instance de base de données Teradata) pour ce cas d'utilisation. [Charger les actifs](#data=%7B%22id%22:%22KneeReplacement%22%7D)

### Procédure pas à pas

------------------------------------------------------------------------

#### Étape 1 : Exploration du chemin vers le remplacement total du genou

Je vais démontrer les capacités d'analyse de Vantage Path à l'aide de données de santé. Plus précisément, nous allons examiner les chemins de procédures médicales les plus fréquents menant au remplacement total du genou.

En utilisant le panneau de droite, je vais définir les valeurs comme suit : - Laissez les chemins supérieurs afficher 25 - Sélectionnez la source de données : - Base de données des événements : retail\_sample\_data - Table des événements : knee\_replacement

Je choisis de ne pas définir de filtre et d'utiliser plutôt tous les événements. Pour la tendance des événements : - Événement A : laissez « Tout événement » - Événement B : remplacez « Tout événement » par « Remplacement total du genou »

Et je vais laisser les paramètres Nombre minimal d'événements, Nombre maximal d'événements et Autoriser le chevauchement comme paramètres par défaut.

Pour ce scénario de démo, je n'ai pas besoin de limiter la plage de dates (cependant, ce filtre pourrait être utile dans d'autres situations).

Enfin, je dois sélectionner la colonne de session (entity\_id) pour indiquer à l'analyse de chemin les événements qui appartiennent au même chemin. Certaines analyses de chemins, telles que les chemins sur un site Web, seront regroupées par session\_id. Dans ce scénario, session\_id est égal au patient (entity\_id).

Une fois que toutes les informations requises par la requête ont été saisies, je peux sélectionner le bouton Exécuter, auquel cas une requête est générée dynamiquement et envoyée au système Vantage et, en peu de temps, une visualisation nous sera renvoyée ici dans l'interface.

#### Étape 2 : Visualisation

La visualisation initiale renvoyée met en évidence le chemin le plus courant vers le remplacement total du genou.

Une fois la visualisation renvoyée, plusieurs options s'offrent à moi : - Je peux explorer manuellement en développant le chemin à chaque nœud d'intérêt (en cliquant sur un cercle orange ouvert, tel que Arthroscopie du genou). Les cercles oranges pleins indiquent que le chemin complet de ce nœud est affiché. - Tout développer - Afficher tous les chemins - Tout réduire : affiche uniquement l'événement de fin (remplacement total du genou) - Sélectionner dominant : met en évidence le chemin le plus populaire

-   Je peux cocher l'option Afficher les étiquettes de nombre qui indique le nombre de personnes qui sont passées par chaque segment de chemin spécifique (par exemple, du test d'amplitude des mouvements à la physiothérapie NEC).

-   Je peux également basculer entre un diagramme de chemin et une liste de tables répertoriant les événements de chemin et leur nombre. La liste de tables correspond à ce qui aurait été renvoyé si vous aviez exécuté cette analyse par le biais d'une requête directe plutôt que par l'interface.

Comme vous le constatez en observant le chemin dominant, la biopsie de l'articulation du genou est la dernière étape la plus courante avant le remplacement total du genou. Explorons cela plus en détail pour voir si nous pouvons identifier d'autres chemins qui n'ont pas conduit au remplacement total du genou. - Explorons d'abord les chemins à partir de la biopsie de l'articulation du genou en sélectionnant la biopsie de l'articulation du genou comme événement A et N'importe quel événement pour l'événement B (Sélectionner Exécuter). - Comme prévu, le chemin dominant aboutit au remplacement total du genou, mais il existe également d'autres procédures.

-   Dans Vantage Path, nous pouvons facilement changer la direction du chemin et le faire pour explorer un chemin vers la biopsie de l'articulation du genou.  
-   Cependant, avant de sélectionner Exécuter, nous allons vérifier l'option d'ancrage de fin – cette option garantira que la biopsie de l'articulation du genou est le dernier événement du chemin et que, par conséquent, les patients ne sont pas passés au remplacement total du genou.
-   Dans cette visualisation, nous constatons le chemin le plus courant vers la biopsie de l'articulation du genou et nous pourrions être intéressés par une analyse plus approfondie des patients sur ce chemin.

Lorsque le dominant (ou n'importe quel chemin d'ailleurs) est choisi, j'ai la possibilité de stocker les résultats dans une table pour permettre une analyse plus approfondie en utilisant la fonctionnalité Créer un segment

Si vous ne passez pas à l'étape 3 de la démo : Créer un segment, ignorez simplement la section suivante et passez à la conclusion.

#### Étape 3 : Créer un segment

Pour démontrer la fonctionnalité Créer un segment, une table de sortie doit déjà être créée dans votre base de données personnelle, (car un accès en écriture est requis).

``` sourceCode
CREATE TABLE knee_replacement_path_export(
    entity_id    varchar(100),
    path        varchar(2000)
)
```

Si vous avez déjà exécuté la démo et n'avez pas recréé la table , assurez-vous que la table est vide, sinon l'option Enregistrer le segment affiche 0 ligne insérée.

L'analyse de chemin permet une exploration visuelle et, souvent, lorsqu'un chemin intéressant est identifié, les personnes qui le suivent méritent une analyse plus approfondie. Explorons à présent la fonctionnalité Créer un segment.

Lorsque je clique sur le bouton Créer un segment, je peux choisir une base de données (à laquelle j'ai accès en écriture) et une table (utilisez celle que vous avez créée dans la configuration)

Je dispose désormais de quelques options : - Afficher le code SQL – il s'agit du code SQL exécuté par Vantage. Je peux copier ce code SQL et le coller dans un outil de requête, tel que Vantage Editor ou Jupyter pour approfondir l'analyse. - Enregistrer le segment : la requête est exécutée et la sortie est enregistrée dans la table spécifiée. Une fois la requête terminée, le nombre de lignes s'affiche

    - Save Query –  with this option the query is given a name and the SQL is saved to a table on Vantage.

    - Now that I have saved a segment – let’s take a look at the resulting table. I am going to switch to Vantage Editor
    - If I view the insights from the knee_replacement_path_export table I can see that it has 2,757 records as well as the columns and ddl statement.
    - Running a simple select query I can see the result - Entity_id and Path (the dominant path selected).

-   Le segment enregistré peut être utilisé comme entrée pour approfondir l'analyse, comme le regroupement pour voir s'il existe des points communs entre les patients ou potentiellement comme entrée pour un programme de soins, car ces patients peuvent être candidats à des procédures moins invasives.

#### Nettoyage

Lorsque vous avez terminé cet exemple, pensez à nettoyer la table créée :

``` sourceCode
DROP TABLE knee_replacement_path_export
```

#### Conclusion

Comme vous le constatez à partir de cette brève démonstration, Vantage Analyst propose une interface utilisateur simple pour effectuer une analyse de chemin, telle que celle que nous venons de voir. L'analyse de chemin peut couvrir plusieurs sujets et plusieurs secteurs.

Voici quelques exemples : - Chemins clients vers l'achat - Chemins en ligne vers l'abandon du panier - Chemins clients vers les plaintes - Chemins vers la défaillance de pièces

Ensemble de données
-------------------

------------------------------------------------------------------------

L'ensemble de données **knee\_replacement** comporte 289 839 lignes, chacune représentant une procédure effectuée par un patient. L'ensemble de données est dénormalisé, de sorte que certaines informations sur le patient sont répétées dans chaque ligne :

-   `memberid` : identifiant unique du patient
-   `proccode` : identifiant de la procédure
-   `diagcode` : diagnostic initial du patient
-   `shortdesc` : brève description de la procédure
-   `amount` : coût de la procédure
-   `tstamp` : date et heure de la procédure
-   `firstname` : prénom du patient
-   `lastname` : nom de famille du patient
-   `email` : adresse e-mail du patient
-   `state` : abréviation de l'état du patient
