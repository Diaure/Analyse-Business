--- Stock des produits sous seuil critique : Identifier les produits dont le stock est faible pour éviter les ruptures. ---
--- Taux d’écoulement des stocks : Mesurer la rapidité avec laquelle les stocks sont vendus pour chaque produit. ---

select 
	p.productName AS productName,
	sum(od.quantityOrdered) AS QuantityOrdered,
    p.quantityInStock AS quantityInStock,
    p.productLine,
    rank() OVER (ORDER BY sum(od.quantityOrdered) desc )  AS rang_pdts,
	CASE 
        WHEN p.quantityInStock > 0 THEN ROUND(SUM(od.quantityOrdered) / p.quantityInStock, 2)
        ELSE NULL
    END AS taux_ecoulement_stock
from products p 
join orderdetails od on od.productCode = p.productCode 
group by p.productName, p.productLine, p.quantityInStock
order by QuantityOrdered desc;

--- Durée moyenne de traitement des commandes + commandes au-dessus de la moyenne de livraison. ---

create view duréee_traiment_moyen as (
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
