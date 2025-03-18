Historique détaillé : accès aux données d'archives à partir des banques d'objets
--------------------------------------------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

Des réglementations de plus en plus strictes obligent les entreprises à conserver les données en ligne et à les rendre accessibles pendant de nombreuses années pour assurer la conformité réglementaire. Bien que les données les plus fréquemment consultées soient celles qui sont les plus récentes ou les plus actualisées, cela ne signifie pas que les informations les plus anciennes ne sont pas utiles ou pertinentes pour les cas d'utilisation commerciaux et analytiques. Les données historiques compilées au fil des années offrent une perspective riche de l'entreprise, comme les tendances à long terme et cycliques.

Teradata VantageCloud Lake offre une évolutivité, une simultanéité et des performances inégalées pour les entreprises les plus grandes et les plus exigeantes au monde pour analyser leurs données. La nécessité d'analyser fréquemment les informations plus anciennes diminue généralement à mesure que les données vieillissent. Avec le temps, les données historiques s'accumulent davantage que les données « chaudes » actuelles. Il est donc logique de les stocker dans une architecture présentant des caractéristiques de performances et de prix différentes, par exemple une banque d'objets, telle qu'Amazon S3 ou Microsoft Azure Blob Storage.

Certaines informations ne sont disponibles qu'en analysant ensemble les données historiques et actuelles. Leur stockage dans des systèmes distincts peut donc constituer un défi pour de nombreuses plateformes d'analyse. À l'inverse, Teradata VantageCloud Lake peut joindre de manière transparente toutes les informations historiques et actuelles de l'entrepôt de données et du stockage d'objets, sans que les utilisateurs aient à modifier leurs outils ou leurs requêtes. Par conséquent, les décideurs peuvent élaborer de meilleurs plans en répondant de manière rentable à des questions auxquelles il était auparavant impossible de répondre. Les analystes et les experts en science des données ont un accès transparent à des ensembles de données détaillés et complets, ce qui permet des analyses avancées et des résultats plus robustes de l'intelligence artificielle ou de l'apprentissage automatique.

### Expérience

La section Expérience dure environ 10 minutes.

### Configuration

Sélectionnez **Charger les actifs** pour créer les tables et charger les données requises dans votre compte (instance de base de données Teradata) pour ce cas d'utilisation. [Charger les actifs](#data=%7B%22id%22:%22SalesOffload%22%7D)

### Procédure pas à pas

#### Étape 1 : Interrogation des données

Voici nos données de ventes actuelles. Prenons quelques exemples de lignes : dans cet exemple, nous disposons d'informations sur le client, le magasin, le panier et les remises.

``` sourceCode
SELECT TOP 10 * 
FROM so_sales_fact
```

``` sourceCode
SELECT sales_date, sum(sales_quantity) as total 
FROM so_sales_fact
GROUP BY sales_date
ORDER BY sales_date ASC
```

![png](output_7_1.png)

Pour quelle période disposons-nous de données ?

``` sourceCode
SELECT MIN(sales_date) AS min_date, MAX(sales_date) AS max_date FROM so_sales_fact
```

Combien d'enregistrements avons-nous dans l'entrepôt de données (données de 2019) ?

``` sourceCode
SELECT COUNT(*)
FROM so_sales_fact
```

#### Étape 2 : Explorer les données historiques déchargées

Dans notre exemple, nous ne disposons que d’une année de données de ventes dans notre entrepôt de données, car il s'agit de loin de la plus demandée. Pour des raisons de conformité, de nombreuses entreprises doivent conserver jusqu'à 10 ans de données historiques. Pour ce scénario, les données plus anciennes ont été exportées depuis VantageCloud Lake chaque mois et chargées dans Amazon S3 pour les stocker plus longtemps. Grâce à VantageCloud Lake, nous pouvons accéder de manière transparente à ces données déchargées et les joindre au reste des données pour examiner les tendances à long terme et gérer facilement les besoins d'analyses, tels que les demandes d'audit. Cela inclut l'utilisation de requêtes et de rapports existants qui devraient autrement être réécrits.

Nous savons déjà où se trouve le compartiment contenant les données de ventes déchargées, examinons donc certaines de ses données. Grâce à la fonction READ\_NOS, nous pouvons obtenir la liste des fichiers et leurs tailles. L'élément RETURNTYPE dans la clause FROM nous permet d'indiquer à la fonction de renvoi des métadonnées de l'objet, du schéma ou des valeurs elles-mêmes.

Notez que ce compartiment S3 est lisible publiquement. Si nous utilisions une banque d'objets protégée, nous pourrions modifier l'élément AUTHORIZATION pour qu'il contienne les valeurs d'authentification appropriées ou utiliser un objet d'autorisation contenant ces informations.

``` sourceCode
SELECT location(char(255)), ObjectLength 
FROM (
 LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload'
 AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}'
 RETURNTYPE='NOSREAD_KEYS'
) as d 
ORDER BY 1
```

Combien y a-t-il de fichiers et de répertoires au total ?

``` sourceCode
SELECT COUNT(location(char(255))) as NumFiles
FROM (
 LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload'
 AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}'
 RETURNTYPE='NOSREAD_KEYS'
) as d 
ORDER BY 1
```

Inspectons l'un des fichiers pour mieux comprendre le format du fichier :

``` sourceCode
SELECT * FROM (
      LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload/2010/1/object_33_0_1.parquet'
      AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}'
      RETURNTYPE='NOSREAD_PARQUET_SCHEMA'
      )
AS d
```

#### Étape 3 : Créez une couche d'abstraction simple pour faciliter l'accès

Pour créer un objet d'autorisation, utilisez l'instruction suivante pour qu'il contienne les identifiants de votre banque d'objets externes. Dans ce cas d'utilisation, laissez les champs UTILISATEUR et MOT DE PASSE vides comme indiqué.

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

Créez une table étrangère et une vue dans VantageCloud Lake pour permettre aux analystes commerciaux et aux autres utilisateurs d'accéder facilement aux données historiques déchargées. Une table étrangère est un objet de la base de données qui peut faire office de table de base de données normale, mais qui pointe vers des données situées à un emplacement différent. Les définitions de table étrangère contiennent également une syntaxe étendue qui peut contribuer à optimiser le transfert de données, à les convertir à la volée, etc.

Le code SQL ci-dessous crée une table simple qui s'appuie sur la détection automatique des colonnes et des types de données :

``` sourceCode
CREATE FOREIGN TABLE sales_fact_offload
, EXTERNAL SECURITY MyAuth 
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN;
```

Inspectons certaines des lignes dans les fichiers déchargés.

``` sourceCode
SELECT TOP 10 *
FROM sales_fact_offload;
```

De combien de données disposons-nous ?

``` sourceCode
SELECT COUNT(*)
FROM sales_fact_offload;
```

OK, nous y sommes presque ! Nous voulons que les données ressemblent à une table native. Plaçons donc une vue en haut pour diviser les données en colonnes.

``` sourceCode
REPLACE VIEW sales_fact_offload_v as (  
SELECT 
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM sales_fact_offload);
```

Nous pouvons désormais interroger les données comme n'importe quelle autre table dans VantageCloud Lake, mais les données sont extraites au moment de l'exécution de la requête directement à partir de la banque d'objets. Nous disposons à présent d'une expérience d'analyses transparentes en prenant en charge la corrélation des ensembles de données basés sur la banque d'objets avec des ensembles de données structurés dans les tables relationnelles Teradata utilisant des compétences et des flux de travail SQL existants.

``` sourceCode
SELECT TOP 10 *
FROM sales_fact_offload_v;
```

Désormais, les utilisateurs peuvent accéder à toutes les données historiques de la banque d'objets. En utilisant une vue de base de données, nous pouvons faire abstraction de toute complexité sous-jacente liée à l'accès à la banque d'objets. Les utilisateurs verront les données comme s'il s'agissait de n'importe quel autre objet de la base de données, et VantageCloud Lake optimisera automatiquement l'exécution des requêtes et le transfert des données, optimisant ainsi les performances et le temps de réponse.

Nous devons souvent pouvoir examiner une partie de la grande quantité de données. Dans notre cas d'utilisation, nous avons supposé certains filtres courants, y compris l'année et le mois des transactions. C'est pourquoi nous les avons stockés selon les clés année et mois dans la banque d'objets. Nous pouvons redéfinir la table étrangère pour préfiltrer les données lors de leur lecture en fonction de ces conditions courantes.

#### Étape 4 : Optimiser la table étrangère et la vue pour permettre un accès efficace

S3 contient de nombreuses données. Optimisons la table étrangère afin de minimiser les données que nous devons lire lors de l'interrogation dans la banque d'objets. La conception d'un compartiment de banque d'objets et d'une structure de chemin est une première étape importante lors de la planification du stockage des données. Cela nécessite une connaissance des besoins de l'entreprise, des tendances attendues d'accès aux données, une compréhension des données et une sensibilité aux compromis. Dans notre cas, nous connaissons souvent la date approximative que nous examinons, alors utilisons cela à notre avantage.

``` sourceCode
DROP TABLE sales_fact_offload;
CREATE FOREIGN TABLE sales_fact_offload
, EXTERNAL SECURITY MyAuth 
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
PATHPATTERN ('$dir1/$year/$month')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN;
```

Nous avons redéfini notre table étrangère afin d'inclure un élément **PATHPATTERN**. Lors de l'examen des données historiques par date, cela nous permet de lire uniquement les fichiers dont nous avons besoin.

À présent, recréons notre vue conviviale qui permet ce filtrage de chemin. Comme indiqué ci-dessus, les vues de base de données nous permettent de faire abstraction de la complexité sous-jacente. Dans ce cas, nous mappons un chemin d'objet à des colonnes, donc lorsque les utilisateurs utilisent ces colonnes comme valeurs de filtre, VantageCloud Lake minimise automatiquement le transfert de données.

``` sourceCode
REPLACE VIEW sales_fact_offload_v as (  
SELECT 
    CAST($path.$year AS CHAR(4)) sales_year,
    CAST($path.$month AS CHAR(2)) sales_month,
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM sales_fact_offload);
```

``` sourceCode
SELECT TOP 10 *
FROM sales_fact_offload_v
WHERE sales_year = '2010'
AND sales_month = '9';
```

Cette fonction est idéale pour les cas d'utilisation dans lesquels nous connaissons le mois. Supposons que nous ayons besoin de voir ce qu'un client a acheté il y a de nombreuses années. Nous souhaiterons peut-être également générer un rapport sur les ventes historiques d'un magasin. Un analyste commercial peut facilement interroger ces données sans intervention informatique, sauvegardes ou autres silos de données difficiles d'accès.

Regardons les ventes du magasin 6 à partir d’août 2012 :

``` sourceCode
SELECT store_id, SUM(sales_quantity)
FROM sales_fact_offload_v
WHERE store_id = 6
AND sales_year = '2012'
AND sales_month = '8'
GROUP BY 1;
```

Joignons les données historiques aux données actuelles afin d'avoir une vue d'ensemble :

``` sourceCode
REPLACE VIEW sales_fact_all as (
SELECT sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
    FROM so_sales_fact
    UNION ALL
SELECT 
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM sales_fact_offload_v);
```

Enfin, réexécutons notre rapport sur les ventes au fil du temps. Le code est inchangé par rapport à celui ci-dessus, nous pouvons donc analyser toutes les données de ventes au-delà de l'année la plus récente.

``` sourceCode
SELECT sales_date, sum(sales_quantity) as total 
FROM sales_fact_all
GROUP BY sales_date
ORDER BY sales_date ASC;
```

![png](output_43_1.png)

Nous constatons que 2019 a été une année difficile, nous devons donc approfondir cette situation pour voir ce qui s'est passé. Mais grâce à VantageCloud Lake, nous pouvons analyser de manière rentable toutes nos données en déchargeant les données les plus « froides » et les moins demandées vers le stockage d'objets pour les conserver en toute sécurité.

#### Étape 5 : Nettoyer

Supprimez les objets que nous avons créés dans notre propre schéma de base de données.

``` sourceCode
DROP VIEW sales_fact_all;
```

``` sourceCode
DROP VIEW sales_fact_offload_v;
```

``` sourceCode
DROP TABLE sales_fact_offload;
```

Ensemble de données
-------------------

------------------------------------------------------------------------

L'ensemble de données **sales\_fact** contient environ 43 millions de lignes d'exemples de données de ventes :

-   `sales_date` : date à laquelle la commande a été traitée
-   `customer_id` : identifiant client
-   `store_id` : identifiant du magasin dans lequel la commande a été passée
-   `basket_id` : numéro de groupement ou de commande
-   `product_id` : identifiant du produit
-   `sales_quantity` : quantité du produit vendu
-   `discount_amount` : montant de remise ayant été accordé sur ce poste
