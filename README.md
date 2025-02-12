# Analyse Business : Entreprise de Modèles et Maquettes<br>
![test](https://github.com/Diaure/Analyse-Business/blob/master/03_Images/Picture1.png)<br>

## 🏢**Contexte**
Nous avons été mandatés par une entreprise spécialisée dans la vente de modèles et 
de maquettes.<br>
Souhaitant disposer d’un **`tableau de bord actualisable`**, le directeur de 
l’entreprise nous a fournit une [base de données](https://github.com/Diaure/Analyse-Business/tree/master/01_Data/queries.sql) répertoriant ses employés, produits, 
commandes et bien plus encore, <br> 
Le directeur souhaite  chaque matin, 
Cet outil lui permettra d’obtenir les informations les plus récentes afin de gérer 
efficacement son entreprise.<br>

## 🎯**Objectif & Enjeux**<br>
Concevoir un tableau de bord interactif centré sur quatre thématiques clés :

* 📈 **Ventes**<br>
* 💰 **Finances**<br>
* 🚛 **Logistique**<br>
* 👥 **Ressources humaines**<br>

## 🛠️**Outils Utilisés**

* **SQL** : Extraction et transformation des données

* **Power BI** : Visualisation et analyse des performances

## 📌**Indicateurs Clés de Performance (KPI)**<br>
Nous nous sommes basés sur ces [données transformées](https://github.com/Diaure/Analyse-Business/tree/master/01_Data/cleaned_data) pour identifier les KPIs ci-dessous.<br>
**1.** 👥 **Ressources Humaines**

* **Performance des représentants commerciaux** : Mesurer le chiffre d’affaires 
généré par chaque employé chargé des ventes.<br>
Meilleurs commerciaux : **Hernandez, Jennings et Castillo**.<br>

```
select
	e.employeeNumber, 
	e.lastname,
	e.firstname,
	YEAR(o.orderDate) AS salesYear,
	MONTH(o.orderDate) AS salesMonths,
	SUM(od.priceEach * od.quantityOrdered) AS sales_vendeur
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY salesMonths, salesYear, e.lastname, e.firstname, e.employeeNumber);
```

* **Performance des bureaux** : Mesurer le chiffre d’affaires généré par chaque 
bureau et représentant commercial.<br>


**2.** 📈 **Ventes**

* **Chiffre d’affaires global** : **`8,4M€`**, avec un panier moyen de **`30K€`**.

* **Top 5 des produits les plus vendus** : Ferrari 360 Spider (1992), Lincoln 
Berline (1937), 2001 Ferrari Enzo, 1913 Ford Model T Speedster, 1940s Ford truck.

* **Taux de retour clients** : **`98%`**, ce qui indique une bonne fidélisation.

```
create view Nombre_commandes_clients as (
SELECT
	c.customerNumber,
    c.customerName,
	count(distinct o.orderNumber) as nombre_orders
FROM customers c
join orders o on c.customerNumber = o.customerNumber
GROUP BY c.customerNumber
order by nombre_orders desc);

create view taux_retour_client as (
with nombre_commandes_client as (
SELECT
	c.customerNumber,
    c.customerName,
	count(distinct o.orderNumber) as nombre_orders
FROM customers c
join orders o on c.customerNumber = o.customerNumber
GROUP BY c.customerNumber
order by nombre_orders desc),

Clients_fideles as (
select count(customerNumber) from nombre_commandes_client where nombre_orders > 1)

select
	(select COUNT(*) from Clients_fideles) as clients_f,
    (select COUNT(*) from customers) as nombre_commandes_client,
    ROUND((select COUNT(*) from Clients_fideles) * 100.0 / (select COUNT(*) from customers), 2) as taux_de_retour);
```

* **Evolution trimestrielle des ventes** : Croissance significative en 2024 par 
rapport à 2023 et 2022.


**3.** 💰 **Finances**

* **Clients générant le plus de revenus** : Euro+ Shopping, Mini Gifts, etc.

* **Montant des créances** : **`446K€`** en attente, avec 12 clients concernés.

* **Taux de paiement par délai** : **`22%`** des paiements se font entre **`31 et 60 
jours`**, une part non négligeable est en retard.


**4.** 🚛**Logistique**

* ⚠️ **Stock critique** : Produits comme Suzuki XREO et Honda Civic ont des stocks 
élevés mais une faible rotation.

* ⏱ **Durée moyenne de traitement des commandes** : **`3,69 jours`**, avec **`53%`**
des commandes au-dessus du temps moyen de livraison.<br>

```
WITH traitement_commande AS (
    SELECT 
        orderNumber, 
        orderDate, 
        shippedDate, 
        DATEDIFF(shippedDate, orderDate) AS temps_traitement
    FROM orders
),
temps_moyen_traitement AS (
    SELECT 
        AVG(temps_traitement) AS temps_moyen_traitement
    FROM traitement_commande
)
SELECT 
    orderNumber, 
    orderDate, 
    shippedDate, 
    DATEDIFF(o.shippedDate, o.orderDate) AS temps_traitement,
    tmt.temps_moyen_traitement,
    CASE 
        WHEN DATEDIFF(o.shippedDate, o.orderDate) > tmt.temps_moyen_traitement THEN 'Au-dessus de la moyenne de livraison'
        ELSE 'En-dessous de la moyenne de livraison'
    END AS Status
FROM traitement_commande o
CROSS JOIN temps_moyen_traitement tmt
ORDER BY temps_traitement DESC);
```

## 📢**Synthèse des Recommandations**

📌 **Optimiser la gestion des créances** en mettant en place un suivi plus 
rigoureux des paiements clients et des relances anticipées.

🚀 **Réduire les délais de traitement** des commandes en améliorant la coordination
entre production et logistique.

🔄 **Améliorer la rotation des stocks** en mettant en place des promotions ciblées
pour écouler les produits à faible rotation.

📚 **Renforcer les performances commerciales** par des formations ciblées sur les 
représentants en sous-performance.

Vous trouverez le dashboard détaillé [ici](https://github.com/Diaure/Analyse-Business/blob/master/02_Dasboards/Analyse%20business_KPIs_solo.pbix), aussi en version [pdf](https://drive.google.com/file/d/1mturDTBMuOv12l7cLJSa9_MqjyGpEYnJ/view?usp=sharing).

## **Conclusion**

Ce projet vise à fournir un tableau de bord complet et interactif pour une prise 
de décision optimisée. Grâce à une analyse approfondie des ventes, finances, 
ressources humaines et logistique, l’entreprise pourra mieux piloter ses activités 
et améliorer ses performances.<br>

🤝 **Contributions**
👨‍💻 Équipe du Projet

**Aurélie GABU** - [Github](https://github.com/Diaure/Projects) / [LinkedIn](https://www.linkedin.com/in/aurelie-gabu/)
**Rogrigo** - [Github](https://github.com/hawdgeal) 

Nous encourageons les contributions à ce projet.<br> 
Si vous souhaitez proposer des améliorations, corriger des erreurs ou ajouter de 
nouvelles fonctionnalités, n'hésitez pas à soumettre une pull request.

