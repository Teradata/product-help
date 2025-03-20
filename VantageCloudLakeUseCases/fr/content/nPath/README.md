Analyse de chemin à l'aide de nPath : identifiez les comportements en fonction des tendances
--------------------------------------------------------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

nPath est une extension SQL conçue pour effectuer une analyse rapide et flexible sur des données ordonnées à grande échelle.

Les clauses de nPath vous permettent d'exprimer des requêtes de cheminement complexes et des relations d'ordre qui pourraient autrement nécessiter l'écriture de jointures multiniveaux de relations dans le code SQL de l'American National Standards Institute (ANSI). Grâce à nPath, vous indiquez un ordre souhaité, puis spécifiez une tendance qui sera mise en correspondance dans les données ordonnées. Pour chaque correspondance de la tendance dans la séquence de lignes, nPath calcule un agrégat SQL sur les lignes correspondantes.

L'analyse nPath permet de suivre les chemins qui mènent à un résultat, y compris celui du comportement des clients :

-   Path-to-purchase
-   Analyse des paniers abandonnés
-   Chemin vers le taux de désabonnement
-   Parcours des patients, comme la réadmission à l'hôpital
-   Chemins menant à une activité frauduleuse

### Exemple de taux de désabonnement d'un opérateur de télécommunications

------------------------------------------------------------------------

Dans le secteur des télécommunications, la gestion de la fermeture de comptes ou du taux de désabonnement représente un effort considérable en termes d'économies. L'utilisation de l'analyse nPath permet de cibler les moyens d'améliorer la fidélisation en comprenant le comportement des clients.

La première étape consiste à créer une table d'événements pour intégrer les interactions et les transactions impliquant le client. En capturant les événements, vous pouvez analyser le parcours du client, qui peut avoir impliqué une visite en magasin, un accès au site Web, un appel à l'assistance téléphonique, une mise à niveau du service et une annulation de celui-ci.

Grâce à l'analyse nPath, vous pouvez analyser ces événements de manière très simple pour répondre à des questions commerciales telles que :

-   Quels chemins empruntent mes clients sur le site Web ?
-   Quels chemins empruntent mes clients avant d'appeler l'assistance téléphonique ?
-   Quels chemins empruntent mes clients avant d'annuler leur service ?

### Expérience

L'ensemble du cas d'utilisation dure environ 7 minutes.

### Configuration

Sélectionnez **Charger les actifs** pour créer les tables et charger les données requises dans votre compte (instance de base de données Teradata) pour ce cas d'utilisation. [Charger les actifs](#data=%7B%22id%22:%22Telco%22%7D)

### Exemples

------------------------------------------------------------------------

#### Exemple n° 1 – Tous les chemins

Il s'agit d'une requête courante lors de la première exploration des chemins dans les données. Elle renvoie un ensemble de résultats minimal ; la seule colonne de résultats requise est la sortie ACCUMULATE() pour le chemin. L'ajout de entity\_id permet de revenir aux données d'origine, si nécessaire.

La fonction nPath utilise une table d'entrée composée d'événements, de l'horodatage de l'événement et de toute autre information, telle que l'ID de session, l'ID d'utilisateur, etc. Nous fournissons divers arguments à la clause USING pour contrôler le comportement de correspondance des tendances.

La tendance peut être ajustée pour plus de spécificité. Par exemple, pour contrôler le nombre d'événements dans le chemin, remplacez A\* par A{3,6} pour les chemins avec au moins trois événements et au plus six événements :

```sql
SELECT * FROM npath
( 
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp
   USING 
     Mode (NonOverlapping)
     Pattern ('A*') 
     Symbols 
     (
         true as A 
     )
     Result 
     (
         FIRST ( entity_id of ANY (A) ) AS customer_id,
         ACCUMULATE (event of any(A) ) AS path
     )
)
SAMPLE 1000
;
```

Vous pouvez définir d'autres colonnes dans la clause de résultats pour enrichir ces derniers. Voici quelques exemples courants qui peuvent vous aider.

#### Exemple n° 2 – Chemins vers l'événement

En utilisant une tendance composée de plusieurs symboles (O et A ci-dessous), nous pouvons créer une correspondance plus complexe, dans ce cas, des événements menant à CONTESTATION DE FACTURE, avec un minimum de deux événements et un maximum de six événements avant la soumission. Notez que nous pouvons ajouter un code SQL standard à la requête, dans ce cas, une clause ORDER BY à la fin.

```sql
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('O{2,6}.A')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Exemple n° 3 : Inverser le sens du chemin

En redéfinissant simplement la tendance sur A.O{1,3}, nous pouvons trouver les chemins empruntés après l'action de soumission de l'application, avec au moins un événement et au plus trois événements pour comprendre le comportement du client après la soumission.

```sql
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('A.O{1,3}')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )
     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### Exemple n° 4 : chemins principaux

En enveloppant la requête nPath avec des clauses SQL COUNT/GROUP BY et en ordonnant par valeur décroissante, nous pouvons rapidement trouver les meilleurs chemins.

Notez également la syntaxe nPath PATTERN ci-dessous. Ici, nous filtrons par chemins qui possèdent au moins trois correspondances, sans nombre maximal de correspondances. La syntaxe est **{min, max}**.

```sql
SELECT path, count(*) as cnt
FROM npath
(
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         true  as A
     )
     Pattern ('A{3,}')

     Result
     (
         FIRST ( entity_id of ANY (A) )                  AS customer_id,
         FIRST ( session_id of ANY(A))                   AS session_id,
         COUNT ( * of any (A) )                          AS cnt,
         FIRST ( event of ANY (A) )                      AS first_event,
         LAST  ( event of ANY (A) )                      AS last_event,
         ACCUMULATE (event of any(A) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
group by 1
order by count(*) desc
SAMPLE 50
;
```

#### Exemple n° 5 : Sessionnaliser

Dans de nombreux cas, les données ne divisent pas les événements d'utilisateurs en sessions facilement définissables. Bien que les données numériques puissent contenir ces informations, nous devons créer une limite sur ce qui constitue une session utilisateur ou d'entité lorsque nous combinons plusieurs canaux ou sources de données. La fonction sessionnaliser mappe chaque événement d'une session à un identifiant de session unique. Une session est une séquence d'événements d'un utilisateur séparés par une durée maximale en secondes.

Cette fonction est utile à la fois pour la sessionnalisation et pour détecter l'activité des robots d'indexation (bots). Les données d'événements basées sur les robots peuvent être automatiquement filtrées de la fonction par une valeur de « décalage de clic » si vous le souhaitez.

Vous pouvez également utiliser la fonction sessionnaliser avec nPath pour améliorer la détection de tendance.

```sql
select *
from Sessionize
(
    on (select * from telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
    partition by entity_id
    order by datestamp
    using
    TimeColumn('datestamp')
    TimeOut(1200) -- 1200 seconds (20 minutes)
)
order by datestamp
SAMPLE 100
;
```

Ensemble de données
-------------------

------------------------------------------------------------------------

**telco\_events** - Exemples d'événements clients d'un opérateur de télécommunications :

-   `entity_id` : identifiant unique du client
-   `datestamp` : heure et date de l'événement
-   `session_id` : identifiant de la session
-   `event` : interaction avec l'événement ou le client
