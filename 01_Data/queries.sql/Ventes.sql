--- Chiffre d’affaires par mois et par région + taux d’évolution mensuel : Suivre les revenus générés par région et par mois pour identifier les tendances géographiques---

create view evolution_ventes_mensuel_region as (
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(o.orderDate, '%Y-%m') AS monthYear,
        c.country AS region,                          
        SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
    FROM 
        orders o
    JOIN 
        orderdetails od ON o.orderNumber = od.orderNumber
    JOIN 
        customers c ON c.customerNumber = o.customerNumber
    GROUP BY 
        DATE_FORMAT(o.orderDate, '%Y-%m'), c.country 
),
RevenueWithGrowth AS (
    SELECT 
        mr.monthYear,
        mr.region,
        mr.totalRevenue,
        LAG(mr.totalRevenue) OVER (PARTITION BY mr.region ORDER BY mr.monthYear) AS previousRevenue,
        CASE 
            WHEN LAG(mr.totalRevenue) OVER (PARTITION BY mr.region ORDER BY mr.monthYear) IS NULL THEN NULL
            ELSE 
                ((mr.totalRevenue - LAG(mr.totalRevenue) OVER (PARTITION BY mr.region ORDER BY mr.monthYear)) / 
                 LAG(mr.totalRevenue) OVER (PARTITION BY mr.region ORDER BY mr.monthYear)) * 100
        END AS growthRate
    FROM 
        MonthlyRevenue mr
)
SELECT 
    monthYear,
    region,
    totalRevenue,
    ROUND(growthRate, 2) AS growthRate -- Arrondi du taux d'évolution
FROM 
    RevenueWithGrowth
ORDER BY 
    region, monthYear);
    
--- Produits les plus/moins vendus par catégorie : Identifier les produits les plus performants dans chaque catégorie.---

create view ventes_margebrute_par_prod_categ as (
SELECT 
    pl.productLine, 
    productName,
    year(o.orderDate) as years,
    SUM(od.quantityOrdered) AS totalSold,
    SUM(od.quantityOrdered * od.priceEach) AS ventes,
    SUM(od.quantityOrdered * p.buyPrice) AS achats,
    ((SUM(od.quantityOrdered * od.priceEach)) - (SUM(od.quantityOrdered * p.buyPrice))) AS marge_brute
FROM productlines pl 
JOIN products p ON pl.productLine = p.productLine
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine, productName, year(o.orderDate)
); 

--- Produits les plus/moins vendus par catégorie : Identifier les produits les plus performants dans chaque catégorie.---

create view panier_moyen as (
SELECT
	c.country as region,
    count(distinct o.orderNumber) as totalOrders,
    SUM(od.quantityOrdered * od.priceEach) AS ventes_totales,
    round(SUM(od.quantityOrdered * od.priceEach) / count(distinct o.orderNumber), 2) as panier_moyen
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
GROUP BY c.country
order by panier_moyen desc);

--- Taux de retour des clients (repeat customers) : Mesurer la fidélité des clients en identifiant ceux qui passent plusieurs commandes.---

--- Nombre de commandes par clients ---

create view Nombre_commandes_clients as (
SELECT
	c.customerNumber,
    c.customerName,
	count(distinct o.orderNumber) as nombre_orders
FROM customers c
join orders o on c.customerNumber = o.customerNumber
GROUP BY c.customerNumber
order by nombre_orders desc);

--- Taux de retour ---

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



