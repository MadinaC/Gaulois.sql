
/*Nom des lieux qui finissent par 'um'.*/

SELECT 
   l.nom_lieu
FROM
    lieu l
    
WHERE 
    l.nom_lieu LIKE '%um'
/*2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).*/
SELECT 
     l.nom_lieu,
     COUNT(*) AS nombre_total
FROM 
    personnage p
   
INNER JOIN lieu l ON
   p.id_lieu = l.id_lieu
      
GROUP BY
   p.id_lieu,
   l.nom_lieu
   
ORDER BY 
   nombre_total DESC


/*3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.*/
SELECT 
     p.nom_personnage,
     s.nom_specialite,
     p.adresse_personnage,
     l.nom_lieu     
FROM 
    personnage p

INNER JOIN specialite s ON
           p.id_specialite = s.id_specialite 
INNER JOIN lieu l ON
            p.id_lieu = l.id_lieu
ORDER BY
    p.nom_personnage,
     s.nom_specialite,
     p.adresse_personnage,
     l.nom_lieu

/*4.Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).*/

SELECT 
     s.nom_specialite,
     COUNT(*) AS nombre_tot
FROM 
    specialite s
   
INNER JOIN personnage p ON
   s.id_specialite = p.id_specialite
      
GROUP BY
   s.nom_specialite
   
ORDER BY
    nombre_tot DESC
/*/*5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa)*/

SELECT 
	b.nom_bataille,
  	b.date_bataille,
	l.nom_lieu

FROM 
	bataille b
	
INNER JOIN 
    lieu l
ON  l.id_lieu = b.id_lieu


ORDER BY
   b.date_bataille ASC
/*6.Nom des potions + coût de réalisation de la potion (trié par coût décroissant).*/

CREATE OR REPLACE VIEW prix_tot_par_ing AS
SELECT

   p.nom_potion,
   i.nom_ingredient,
   i.cout_ingredient*c.qte AS prix_tot
  
   
FROM 	
	composer c
	
INNER JOIN 
  ingredient i 
ON  i.id_ingredient = c.id_ingredient

INNER JOIN
   potion p
ON p.id_potion =c.id_potion

ORDER BY 
 c.id_potion ASC,
 p.nom_potion
 
/*CREATE VIEW select `pt`.`nom_potion` AS `nom_potion`,sum(`pt`.`prix_tot`) AS `prix_total_par_portion` from `prix_tot_par_ing` `pt` group by `pt`.`nom_potion`*/

 SELECT 
 
 cp.nom_potion,
 cp.prix_total_par_portion

FROM 

    cout_portion cp
    
ORDER BY 
 cp.prix_total_par_portion DESC

 /*7Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.Tout d'abord on groupe de colonnes de  2 tables*/

 CREATE VIEW portion_sante AS
 SELECT 
    i.nom_ingredient,
    i.cout_ingredient,
    p.nom_potion,
    c.qte
 FROM 
  ingredient i
  
INNER JOIN 
   composer c ON
   
   c.id_ingredient = i.id_ingredient
INNER JOIN potion p ON

c.id_potion= p.id_potion

GROUP BY 
   i.nom_ingredient,
    i.cout_ingredient,
    p.nom_potion,
    c.qte,
    p.nom_potion
/*------------------*/
SELECT 
  ps.nom_potion,
  ps.nom_ingredient,
  ps.cout_ingredient,
  ps.qte
FROM 
	portion_sante ps

WHERE 
 ps.nom_potion = "Santé"
/*8.Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.*/
/*creer une vue pour recuper la collone" qt "du "prendre_casque" et aplliquer la fonction MAX*/
CREATE VIEW nom_pers_max_casque AS

SELECT
  p.nom_personnage,
  pc.id_casque,
  pc.qte ,
  b.nom_bataille
   
FROM 
	prendre_casque pc
	
INNER JOIN personnage p ON
	pc.id_personnage = p.id_personnage
	
INNER JOIN bataille b ON
    pc.id_bataille= b.id_bataille
  
WHERE 
	b.nom_bataille = "Bataille du village gaulois"
	
GROUP BY
	  p.nom_personnage,
  		pc.id_casque,
  		pc.qte ,
  		b.nom_bataille
/*utiliser la vue pour trouver le max */
   SELECT 
    npmc.nom_personnage,
    npmc.qte 
FROM
   nom_pers_max_casque npmc

WHERE 
    npmc.qte = (
    
     SELECT 
       MAX(qte)
     FROM 
        nom_pers_max_casque
        )

  /* 9Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).*/
CREATE VIEW 
  
 SELECT
	nom_personnage,
	bo.dose_boire
FROM
	boire bo
INNER JOIN personnage pe ON pe.id_personnage = bo.id_personnage

ORDER BY 
	bo.dose_boire DESC

 /*11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)*/
SELECT 
   ctc.nom_type_casque,
   ctc.somme_cout
FROM 
	cout_total_casque ctc
	
ORDER BY 
    ctc.somme_cout
/*je recupere les donnes de cette vue*  /*creer une vue pour recuper  la colonne  somme_cout*/
    CREATE VIEW cout_total_casque AS
SELECT
   tc.id_type_casque,
	tc.nom_type_casque,
	SUM(cs.cout_casque) AS somme_cout
  
FROM 
	casque cs 
INNER JOIN type_casque tc
ON  tc.id_type_casque = tc.id_type_casque
/*La manière simple de comprendre le GROUP BY c’est tout simplement d’assimiler qu’il va éviter de présenter plusieurs fois les mêmes lignes. C’est une méthode pour éviter les doublons*/
 GROUP  BY 
  tc.id_type_casque,
  tc.nom_type_casque
  

/*12. Nom des potions dont un des ingrédients est le poisson frais.*/

SELECT 
    p.nom_potion,
    c.id_ingredient,
    i.nom_ingredient
    
FROM 
 potion p

INNER JOIN composer c
ON c.id_potion = p.id_potion
INNER JOIN ingredient i
ON i.id_ingredient= c.id_ingredient

WHERE i.nom_ingredient LIKE  "%poisson frais%"

/*
13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.*/

CREATE VIEW tot_hab AS
SELECT 
  l.id_lieu,
 l.nom_lieu,
 COUNT(p.nom_personnage) AS nom_pers_par_vil
 
FROM lieu l

INNER JOIN  personnage p
ON p.id_lieu = l.id_lieu

WHERE l.nom_lieu != "village gaulois"

 /*utiliser la vue tot_hab*/
SELECT 
   th.nom_lieu,
   th.nom_pers_par_vil
FROM 
 tot_hab th
WHERE th.nom_pers_par_vil = (SELECT MAX(nom_pers_par_vil) FROM tot_hab)


/*14. Nom des personnages qui n'ont jamais bu aucune potion.*/
/*ans le langage SQL, la commande LEFT JOIN (aussi appelée LEFT OUTER JOIN) est un type de jointure entre 2 tables. Cela permet de lister tous les résultats de la table de gauche (left = gauche) même s’il n’y a pas de correspondance dans la deuxième tables.*/
SELECT 
	p.nom_personnage,
	b.dose_boire
FROM personnage p

LEFT JOIN boire b ON b.id_personnage = p.id_personnage
WHERE b.dose_boire IS NULL
GROUP BY 
	p.nom_personnage,
	b.dose_boire

/*15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.*/
SELECT 
	po.nom_potion,
	ab.id_personnage,
	p.nom_personnage
FROM 
	autoriser_boire ab
LEFT JOIN potion po ON po.id_potion = ab.id_potion
INNER JOIN personnage p ON p.id_personnage = ab.id_personnage
WHERE NOT po.nom_potion LIKE '%Magique%' OR ab.id_personnage IS NULL


/*Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.*/
INSERT INTO personnage (id_personnage, nom_personnage, adresse_personnage, image_personnage, id_lieu, id_specialite) VALUES
	(46, Champdeblix, ferme Hantassion,indisponible,5, 12)


/*B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine.*/

INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES
(1, 12);
/*C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.*/
DELETE FROM 
  casque  
WHERE id_type_casque= (
SELECT
      id_type_casque
FROM 
  type_casque 
WHERE nom_type_casque= "grec"
)

AND id_casque NOT IN (
 SELECT pc.id_casque 
 
FROM prendre_casque pc

)


/*D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.*/

/*La commande UPDATE permet d’effectuer des modifications sur des lignes existantes. Très souvent cette commande est utilisée avec WHERE pour spécifier sur quelles lignes doivent porter la ou les modifications.*/
UPDATE personnage 
SET  adresse_personnage = "Prison",
      id_lieu = (
		SELECT 
		  id_lieu 
		FROM lieu
		WHERE nom_lieu ="Condate")

WHERE nom_personnage= "Zérozérosix" 
 /*E. La potion 'Soupe' ne doit plus contenir de persil. */
DELETE 

FROM composer 

WHERE id_potion=  (
SELECT  id_potion 
FROM potion 
WHERE nom_potion ="Soupe"
)
AND id_ingredient  =(
SELECT id_ingredient
FROM ingredient 
WHERE nom_ingredient = "Persil"
  
)

/*F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !*/

UPDATE
  prendre_casque
SET  id_casque = (
SELECT id_casque
FROM casque
WHERE nom_casque= "Weisenau")

WHERE id_personnage = (
SELECT id_personnage 
FROM personnage
WHERE nom_personnage = "Obélix"
)
AND
 id_bataille  = (
SELECT id_bataille
FROM bataille 
WHERE nom_bataille = "Attaque de la banque postale"
)
AND 
id_casque = (
SELECT id_casque
FROM casque
WHERE nom_casque ="Ostrogoths"
)
   