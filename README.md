# Présentation

Le présent repo contient la solution  de l'épreuve Keobiz.

Les codes sont testés sur une scratch org 

# Les fichiers

- [Classes Apex]
Dans le dossier classes, le code de la solution est dans les classes : AccountTriggerHandler et Account_CC (qui contient les méthodes statiques pour la partie traitement et sauvegarde)

Au niveau de la classe AccountTriggerHandler, les deux principales méthodes sont : afterUpdate et commitChanges, l'utilisaton de cette dernière permet de reposer les DML ainsi que les requête jusqu'à la fin. La classe hérite de classe abstraite TriggerHandler utile pour avoir un nivau d'abstraction permettant de développer 

la classe Account_CC est un helper utilisée par  AccountTriggerHandler

- [Trigger] AccouuntTrigger

- [NamedCredentials] pour la configuration du Endpoint

- [Tests]
La classes de test sont organisées dans un dossier séparé, pour faciliter la partie DevOps : déploiement, validation, sonar, ...

