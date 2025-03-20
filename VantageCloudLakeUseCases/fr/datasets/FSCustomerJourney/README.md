Ensemble de données FSCustomerJourney
=====================================

L'ensemble de données FSCustomerJourney est utilisé dans les cas d'utilisation de commentaires des clients des services financiers.

Pour actualiser les données dans S3

    aws s3 rm s3://${S3_BUCKET}/FSCustomerJourney --recursive   

    aws s3 cp data/* s3://${S3_BUCKET}/FSCustomerJourney/ 

Étant donné que nous utilisons une autorisation, cela n'est pas nécessaire, mais si nous voulions rendre les fichiers accessibles au public, nous ajouterions cela à l'appel s3 cp

    --acl public-read    

Les fichiers SQl du dossier scripts sont idempotents, ce qui signifie que peu importe le nombre de fois que vous les exécutez, ils doivent pouvoir être réexécutés et que l'état des tables sera le même après chaque exécution. Pour ce faire, nous supprimons les objets et les recréons à chaque exécution. Lorsque la requête de suppression de l'objet est exécutée, nous ignorons toutes les erreurs indiquant que l'objet n'existe pas, mais nous devons gérer les erreurs lorsque l'utilisateur ne dispose pas des autorisations appropriées.
