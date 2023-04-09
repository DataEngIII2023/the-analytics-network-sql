--CLASE 1:
--1
SELECT * FROM stg.product_master
WHERE  categoria = 'Electro'

--2
SELECT * FROM stg.product_master
WHERE  origen = 'China'

--3
SELECT * 
FROM stg.product_master

WHERE  categoria = 'Electro'
order by nombre

--4
SELECT * 
FROM stg.product_master

WHERE  subcategoria = 'TV' and is_active = true

--5
SELECT * 
FROM stg.store_master

WHERE  pais = 'Argentina'
order by fecha_apertura

--6
SELECT * 
FROM stg.order_line_sale

order by fecha desc
limit 5

--7
SELECT * 
FROM stg.super_store_count

order by fecha 
limit 10

--8
SELECT * 
FROM stg.product_master

WHERE  categoria = 'Electro' and not subsubcategoria in ('Soporte','Control remoto')

--9
SELECT * 
FROM stg.order_line_sale

WHERE  moneda in ('ARS','URU') -- tomando Pesos como Pesos Argentinos y Pesos Uruguayos
and venta > 100000

--10
SELECT * 
FROM stg.order_line_sale

WHERE  fecha between '2022-10-01' and '2022-10-31'

--11
SELECT * 
FROM stg.product_master

WHERE  ean is not null

--12
SELECT * 
FROM stg.order_line_sale

WHERE  fecha between '2022-10-01' and '2022-11-10'


CLASE 2:
--1 Cuales son los paises donde la empresa tiene tiendas?
SELECT distinct pais
FROM stg.store_master

--2 Cuantos productos por subcategoria tiene disponible para la venta?
SELECT subcategoria, count(1)
FROM stg.product_master
group by subcategoria

--3 Cuales son las ordenes de venta de Argentina de mayor a $100.000?
SELECT distinct orden  
FROM stg.order_line_sale
WHERE  venta > 100000

--4 Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
SELECT moneda, sum(descuento) as total_descuento
FROM stg.order_line_sale
WHERE  fecha between '2022-11-01' and '2022-11-30'
group by moneda

--5 Obtener los impuestos pagados en Europa durante el 2022.
SELECT moneda, sum(impuestos) as total_impuestos
FROM stg.order_line_sale
WHERE  fecha between '2022-01-01' and '2022-12-31' and moneda = 'EUR'
group by moneda

--6 En cuantas ordenes se utilizaron creditos?
SELECT count(creditos) 
FROM stg.order_line_sale

--7 Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT tienda, TO_CHAR(avg(abs(venta)/abs(descuento)), 'fm99D00%') as Percentage
FROM stg.order_line_sale
group by tienda

--8 Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, fecha,avg((final+inicial)/2) as aver
FROM stg.inventory
group by tienda, fecha
order by tienda,fecha

--9 Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
SELECT producto, sum(venta), TO_CHAR(avg(abs(venta)/abs(descuento)), 'fm99D00%') as Percentage
FROM stg.order_line_sale
WHERE  moneda = 'ARS'
group by producto
order by producto


--10 Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, 
--uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
SELECT tienda, sum(conteo) as entradas
FROM stg.market_count
group by tienda
UNION ALL
SELECT tienda, sum(conteo) as entradas
FROM stg.super_store_count
group by tienda
order by tienda

--11 Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select * 
from stg.product_master
where nombre like '%PHIL%' AND is_active IS TRUE


--12 Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
select tienda, moneda, sum(venta) as monto_vendido 
from stg.order_line_sale
group by tienda, moneda
order by monto_vendido DESC


--13 Cual es el precio promedio de venta de cada producto en las distintas monedas? 
Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select producto, moneda, avg((coalesce(venta,0)+coalesce(impuestos,0)+coalesce(descuento,0)+coalesce(creditos,0))) as promedio_precio 
from stg.order_line_sale
group by producto, moneda
order by producto


--14 Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, TO_CHAR(avg((abs(impuestos)/abs(venta)*100)), 'fm99D00%') as Percentage
FROM stg.order_line_sale
group by orden
order by orden


CLASE 3:
