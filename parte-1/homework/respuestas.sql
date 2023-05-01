--------------------------------------------CLASE 1:----------------------------------------------------------------------
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

--------------------------------------------CLASE 2:----------------------------------------------------------------------
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
--Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select producto, moneda, avg((coalesce(venta,0)+coalesce(impuestos,0)+coalesce(descuento,0)+coalesce(creditos,0))) as promedio_precio 
from stg.order_line_sale
group by producto, moneda
order by producto


--14 Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, TO_CHAR(avg((abs(impuestos)/abs(venta)*100)), 'fm99D00%') as Percentage
FROM stg.order_line_sale
group by orden
order by orden


--------------------------------------------CLASE 3:----------------------------------------------------------------------
--1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, 
--mostrando la leyenda "Unknown" cuando no hay un color disponible
SELECT nombre,codigo_producto,categoria,COALESCE(color,'Unknown')
FROM stg.product_master
where LOWER(nombre) LIKE ANY (ARRAY['%sams%','%phil%'])

--2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select SM.pais,SM.provincia,sum(OLS.venta),sum(OLS.impuestos)
from stg.store_master as SM
left join stg.order_line_sale as OLS
on SM.codigo_tienda = OLS.tienda
group by SM.pais,SM.provincia
order by SM.pais

--3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select PM.subcategoria,OLS.moneda,sum(OLS.venta)
from stg.product_master as PM
left join stg.order_line_sale as OLS
on PM.codigo_producto = OLS.producto
group by PM.subcategoria,OLS.moneda
order by PM.subcategoria,OLS.moneda

--4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; \
--usar guion como separador y usarla para ordernar el resultado.
SELECT PM.subcategoria,SUM(OLS.cantidad) as unidades_vendidas,CONCAT(sm.pais,'-',sm.provincia) AS ubicacion_producto
from stg.order_line_sale as OLS
left join stg.product_master as PM  
on OLS.producto = PM.codigo_producto
left join stg.store_master as SM 
on OLS.tienda=SM.codigo_tienda
group by PM.subcategoria,OLS.cantidad,ubicacion_producto
order by ubicacion_producto 

--5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
SELECT SM.nombre, SM.fecha_apertura, SUM(SSC.conteo) as cantidad_entrada_personas
from stg.store_master as SM
left join stg.super_store_count as SSC
on SM.codigo_tienda=SSC.tienda
group by SM.nombre, SM.fecha_apertura

--6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
select SM.nombre, to_char(INV.fecha,'YYYY-MM') as mes,INV.sku as codigo_producto,AVG((coalesce(INV.final,0)+coalesce(INV.inicial))/2) as promedio_venta
from stg.store_master as SM
left join stg.inventory as INV
on SM.codigo_tienda=INV.tienda
group by SM.nombre, mes, codigo_producto
order by SM.nombre

--7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select coalesce(UPPER(PM.material),'Unknown') as material_producto, SUM(OLS.cantidad) as cantidades_vendidas
from stg.product_master as PM
left join stg.order_line_sale as OLS
on PM.codigo_producto=OLS.producto
group by material_producto

--8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
SELECT 
OLS.*,
case when OLS.moneda = 'ARS' then OLS.venta/AFR.cotizacion_usd_peso
     when OLS.moneda = 'URU' then OLS.venta/AFR.cotizacion_usd_uru
     when OLS.moneda = 'EUR' then OLS.venta/AFR.cotizacion_usd_eur
end AS valor_en_dolares
from stg.order_line_sale as OLS
left join stg.monthly_average_fx_rate as AFR
on date_part('month',OLS.fecha)=date_part('month',AFR.mes)
order by OLS.orden

--9. Calcular cantidad de ventas totales de la empresa en dolares.

--10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
SELECT 
OLS.*,
case when OLS.moneda = 'ARS' then (coalesce(OLS.venta,0)+coalesce(OLS.descuento,0))/AFR.cotizacion_usd_peso -- Se pone positivo ya que el valor de los descuentos se encuentra negativo en la tabla
     when OLS.moneda = 'URU' then (coalesce(OLS.venta,0)+coalesce(OLS.descuento,0))/AFR.cotizacion_usd_uru
     when OLS.moneda = 'EUR' then (coalesce(OLS.venta,0)+coalesce(OLS.descuento,0))/AFR.cotizacion_usd_eur
end AS margen_en_dolares
from stg.order_line_sale as OLS
left join stg.monthly_average_fx_rate as AFR
on date_part('month',OLS.fecha)=date_part('month',AFR.mes)
order by OLS.orden

--11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.


--------------------------------------------CLASE 4:----------------------------------------------------------------------

