--- Performance des représentants commerciaux, Mesurer le chiffre d’affaires généré par chaque employé chargé des ventes. ---

create view liste_vendeurs as (
select employeeNumber, lastName, firstName from employees);

create view ca_représentants_mensuel as (
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

create view ca_global_représentant as (
select
	e.employeeNumber, 
	e.lastname,
	e.firstname,
	SUM(od.priceEach * od.quantityOrdered) AS sales_vendeur
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY e.lastname, e.firstname, e.employeeNumber);

 --- Ratio commandes/paiements par représentant commercial ---
SELECT 
    e.employeeNumber,
	e.lastname,
	e.firstname,
    od.orderNumber,
    o.customerNumber,
    c.customerName,
    SUM(od.quantityOrdered * od.priceEach) AS montant_commande
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
join employees e ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY od.orderNumber
;

create view paiement_tot_par_client_emp as (
SELECT
	p.customerNumber,
	c.customerName,
	e.employeeNumber,
	e.lastname,
	e.firstname,
	SUM(amount) AS tot_paiement_client
FROM payments p
join customers c on c.customerNumber = p.customerNumber
join employees e ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY p.customerNumber);

CREATE VIEW montanttot_cmde_par_client_emp as (
SELECT
    o.customerNumber,
	c.customerName,
	e.employeeNumber,
    e.lastname,
	e.firstname,
    SUM(od.quantityOrdered * od.priceEach) AS montant_total_commande
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
join employees e ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY o.customerNumber);

create view ipaye_client_emp as (
select 
	paiement_tot_par_client_emp.customerNumber,
    paiement_tot_par_client_emp.customerName,
    paiement_tot_par_client_emp.lastname,
    paiement_tot_par_client_emp.firstname,
    montant_total_commande,
    tot_paiement_client,
    montant_total_commande - tot_paiement_client AS solde_à_régler
FROM paiement_tot_par_client_emp
JOIN montanttot_cmde_par_client_emp on paiement_tot_par_client_emp.customerName = montanttot_cmde_par_client_emp.customerName
);

--- Lise chaque bureau ---

select officeCode, city, state, country from offices;

--- Performance des bureaux : Mesurer le chiffre d’affaire généré par chaque bureau ---

create view ca_bureaus_an as (
select
	o.officeCode,
    o.city,
    o.country,
    YEAR(ord.orderDate) AS salesYear,
    SUM(od.quantityOrdered * od.priceEach) AS chiffre_d_affaires
from offices o
join employees e on e.officeCode = o.officeCode
join customers c on c.salesRepEmployeeNumber = e.employeeNumber
join orders ord on c.customerNumber = ord.customerNumber
JOIN orderdetails od ON ord.orderNumber = od.orderNumber
group by o.officeCode, o.country, salesYear);



