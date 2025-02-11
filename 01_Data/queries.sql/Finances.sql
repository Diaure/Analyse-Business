--- Clients générant le plus/moins de revenus : Identifier les clients générant le plus de revenus pour mieux les fidéliser---

SELECT
    c.customerNumber,
	c.customerName,
	c.country as region,
    SUM(od.quantityOrdered * od.priceEach) AS revenu_total
FROM customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName, c.country
order by revenu_total desc;

--- Croissance des ventes par trimestre : Identifier les tendances saisonnières ou les opportunités de croissance.---

create view ventes_trimestre as (
SELECT
    productLine,
	c.country as region,
	DATE_FORMAT(o.orderDate, '%Y-%m') AS monthYear,
    SUM(od.quantityOrdered * od.priceEach) AS revenu_total,
    SUM(od.quantityOrdered) as quantity_sold
FROM products p
join orderdetails od ON p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
join customers c ON c.customerNumber = o.customerNumber
GROUP BY productLine, region, monthYear
order by revenu_total desc);

--- Montant moyen des paiements + clients en dessous de la moyenne : Évaluer la capacité de paiement des clients.---

--- paiement moyen par clients ---
create view paiement_moyen_clients as (
select 
	payments.customerNumber,
    customerName,
    avg(amount) as paiement_moyen
 from payments 
 join customers on customers.customerNumber = payments.customerNumber
 group by customerNumber, customerName);
 
 --- delai de paiement par clients ---
 
 create view delai_paiement as (
select 
	p.customerNumber,
    c.customerName,
    o.orderNumber,
    o.orderDate,
    p.paymentDate,
    DATEDIFF(paymentDate, orderDate) AS delai_paiement,
    CASE 
		WHEN DATEDIFF(paymentDate, orderDate) < 0 THEN 'negative days'
		WHEN DATEDIFF(paymentDate, orderDate) <= 7 THEN '0-7 days'
		WHEN DATEDIFF(paymentDate, orderDate) <= 14 THEN '8-14 days'
		WHEN DATEDIFF(paymentDate, orderDate) <= 30 THEN '15-30 days'
		WHEN DATEDIFF(paymentDate, orderDate) <= 60 THEN '31-60 days'
		ELSE '60+ days'
	END AS nbr_jours_paiement
 from payments p
 join customers c on c.customerNumber = p.customerNumber
 join orders o on o.customerNumber = c.customerNumber
 group by p.customerNumber, c.customerName, o.orderNumber, o.orderDate, p.paymentDate);
    
    
