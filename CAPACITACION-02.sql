---CAPACITACION-02----
/*03/02/2023 Modulo 8 funciones integradas */
USE Northwind
 /*funciones escalares: opera una sola fila*/

--EX: EXTRAER EL AÑO Y MES DE UNA FECHA

SELECT ORDERID, orderdate, YEAR(orderdate) as año, month(orderdate)as mes
from Orders

-- DIAS TRANSCURRIDOS DESDE LA FECHA DE PEDIDO HASTA HOY

SELECT ORDERID, orderdate, DATEDIFF(dd,[OrderDate], GETDATE()) as diastrancurridos 
from Orders
go

-- funciones agregadas: toma uno o mas valores y devuelve un solo valor resumido 

SELECT COUNTRY, COUNT(*) FROM Customers
GROUP BY Country

-- categoria y número de productos por categoria
select c.categoryname, COUNT(p.productname)
from products as p join categories as c
on p.categoryid = c.CategoryID
group by c.CategoryName

--------------------------- funciones de ventana---------------------------------- 
--opera en un con categoryonjunto de filas
/* las funciones de ventana ademas de dar el total, da el detalle que origina ese total, devuelve 
los mismo datos mas una columna mas*/

select c.categoryname, p.productname,
count(p.productname) over ( partition by c.categoryname) as numero
from products as p join categories as c
on p.categoryid = c.categoryid
/* en la consulta anterior se muestra la categoría del conteo de productos por
cada categoria mas el nombre de cada producto que forma parte de la categoria.
*/

.----------------- funciones rowset: devuelve una tabla vivrtual-----------------------
--ejemplo
SELECT * FROM OPENQUERY([NOMBRE_DEL_SERVIDOR], 'select * from NOMBRE_DE_LA_BASE.NOMBRE_ESQUEMA.NOMBRE.TABLA')
-- LOS DATOS OBTENIDOS SON DE OTRO SERVIDOR


--------------------FUNCIONES DE CONVERSIÓN----------------------------
--pARA MANEJAR ENTEROS: TINY INT < SMALINT < INT < BIGINT


--- CONVERSION IMPLICITA

DECLARE @STRING VARCHAR (10);
SET @STRING = 1
SELECT @STRING + 'ES UN TEXTO'

declare @notastring int;
set @notastring = '1';
select @notastring + '1' -- aunque estoy enviando cadenas de texto , esta la convieerte a numero de manera automatica

------------ funcion cast----------------------------------
select 'el producto' + productname + ', tiene precio de:' 
+ CAST(unitprice as varchar(10)) as precio
from Products go -- se casteo el rpecio a texto o varchar

select CAST(SYSDATETIME()as date);
go

-------------------funcion convert----------------------------------------

select 'el producto' + productname + ', tiene precio de:' 
+ convert( varchar(10), unitprice) as precio
from Products go--la diferencia con cast es la sintaxis

select 'el producto' + productname + ', tiene precio de:' 
+ try_convert( varchar(1), unitprice) as precio
from Products go -- si no puede hacer la conversion arroja valor nulo

---------------funcion parse---------------------------------------
--convierte cadenas a tipos de fecha, hora y número

select parse ('monday, 13 december 2010' as datetime2 using 'en-us') as fecha
go
-------------------------funcion isnumeric-----------------------
--comprueba si una expresion de entrada es un tipo de dato valido
-- devuelve 1 si es valido 0 si no es valido

select productname, ISNUMERIC(productname) as validnumero,
unitprice, isnumeric(unitprice) as validarnumero2, categoryid
from Products



----------------funcion IIF----------------------------------------------
--devuelve uno de dos valores

select productname, unitprice, categoryid, discontinued
, IIF(discontinued = 0 , 'vigente','descontinuado') as status
from Products
-------------- FUNCION CHOOSE -------------------------------------------
--DEVUELVE UN ELEMENTO DE UNA LISTA SEGÚN LO ESPECIFICQADO POR UN VALOR DE INDICE
select productname, unitprice,
choose(CategoryID, 'beverages', 'condiments', 'confections', 'dairy products',
'grain/cereals', 'meat/poultry', 'produce', 'seafood') as category
from products
go

---------------------funcion isnull-----------------------------------------------
--reemplaza null con un valor especificado
select CompanyName, fax from Customers

select CompanyName, isnull(fax, '000-000') from Customers
-- si encuentra valores nulos en fax mostrara el telefono y si encuentra nuloen ambos mostrara 000-000
-----------------funcion coalesce------------------------------
-- devuelve el primer valor no null en una lista
select companyname, coalesce(fax, phone, '0000-0000')
from customers go

------------------nullif---------------------------------------------------------
--compwara dos campos, si ambos son iguaels arroja un valor nulo, de lo contrario arroja el primer argumento

select d.orderid, p.productname, p.unitprice as preciostock,
d.unitprice as precioventa,
nullif(d.unitprice, p.unitprice) as compareción
from [Order Details] as d join products as p
on d.productid=p.productid --cuando los precios son iguales arroja nulo , de lo contarrio arroja el rpecio en que se vendio



------------------------------------ SECCION 9 ----------------------------------------------------
------------------------FUNCIONES DE AGREGADO-----------------------------------------------
--devuelve un valor escalar
--ignora los valores null
-- se puede utilizar en select, having y order by

select country, COUNT(*) from customers
group by Country

select COUNT(country), count(distinct country) 
from customers
group by Country

-- sum, min max, avg, count
--estadisticas : stdev, var, varp
--null puede causar resultados incorrectos por lo quese puede utilizar isnull o coalesce para reemplazar nulls


---------------------------------MODULO 10-----------------------------------------------

--------SUBCONSULTAS------------------------------------------------------


select t.companyname, t.total
from
(
SELECT c.customerid, c.companyname, c.country, o.orderid, o.orderdate, p.productname,
d.unitprice, d.quantity, (d.unitprice * d.quantity) as total 
from customers as c join orders as o 
on c.CustomerID=o.CustomerID join [Order Details] as d
on o.OrderID=d.OrderID join products as p
on d.ProductID=p.ProductID 
) as t


select companyname, country, phone, fax from customers
where customerid in (
select distinct customerid from orders) --- asi se obtienen sololos clientes uqe han ordenado 

--como ver los clientes queno han ordenado
select companyname, country, phone, fax from customers
where customerid  not in (
select distinct customerid from orders)

-- subquery devuelto como un scalar calculando filapor fila 
select productname, unitprice, (select avg(unitprice) from products) as promedop
from Products
go
--------------como correlacionar la consulta interna con la externa-----------------------
-- la consulta externa se filtra por la consulta interna pero la ocnsulta externa traslada parametro a la consulta interna
-- no se pueden ejecutar por separad ya que se acepta un valor de la consulta externa

--ej: todas la ordenes donde se pidieron mas de 20 unidades de producto
-- es de buena rctica realizr laconsulta interna primero

select o.customerid, o.orderid, o.orderdate from orders as o
where
(
select d.quantity from [dbo].[Order Details] as d
WHERE d.ProductID=23 and o.orderid=d.OrderID --- este es elparametro en común
) > 20 -- estas son las ordeenes donde se compraron mas de 20 del producto 23


--subquery conresultadode multiples valores
select c.companyname, c.country, c.contactname
from customers as c where c.CustomerId in 
(select distinct customerid from orders)
go --- datos de los clienes que han ordenado


select c.companyname, c.country, c.contactname
from customers as c where exists 
(select o.customerid from orders as o 
where c.customerid=o.CustomerID)--para la consulta externa se pone un parametro en comun
go --consulta correlacionada, si elc onjunto de datos de query interno es valido se ejecuta
--el externo

----------------------------------------MODULO 11 ------------------------------------------
--CREACION DE VIEWS : son consulas que quedan guardadas como tablas.
create view ventas (compañia, factura, fecha, producto, precio, cantidad) -- se puede cambiar el nombre a las columnas}
as
select c.companyname, o.orderid, o.orderdate, p.productname
, d.unitprice, d.quantity
from Customers as c
join Orders as o on c.CustomerID=o.CustomerID
join [Order Details] as d on d.OrderID=o.OrderID
join products as p on p.ProductID=d.ProductID
go
-- las views se pueden concultar como si fueran tablas.
-- drop view ventas
select * from ventas


-----------------------funciones con valores de tabla en linea----------------------------
--Los fvt SE DENOMINAN expresiones de tabla con definiciones almacenadas en una base de datos
-- los fvt devuelven una tabla virtual a la consulta de llamada
-- a diferencia de las vistas los fvt´s permiten parametros de entrada

create function ventas_productos (@idproducto int )-- este es elparametro 
returns table 
as
return( --toda la sentencia se encierra dentro de un return
select c.companyname, o.orderid, o.orderdate, p.ProductID, p.productname
, d.unitprice, d.quantity
from Customers as c
join Orders as o on c.CustomerID=o.CustomerID
join [Order Details] as d on d.OrderID=o.OrderID
join products as p on p.ProductID=d.ProductID
where p.productid=@idproducto) --aqui seusa el parametro
go
--despues se puede utilizar la funcion
select * from ventas_productos(23) -- se debe de indicar el parametro que se quiere ver
-- para modificar se hace un alter


------------------------------tablas derivadas--------------------------------
--las tablas derivadas no quedan almacenadas.
select t.jefe, count(t.subalterno) from
(select j.firstname+ ' ' + j.lastname as jefe,
s.firstname+ ' ' +s.lastname as subalterno
from employees as j join employees as s
on j.EmployeeID=s.ReportsTo) as t (jefe, subalterno)
group by t.jefe -- con esto se sabe cuantos subalternos tiene cada jefe
go-- en este join se hace un join con la misma tabla, para sabe cuantos subalternos tiene cada jefe

---------------------Common table expression---------------------------------
-- es una tabla derivada que se le asigna un nombre
-- se utliza la clausula WITH
with CTE_YEAR AS (
SELECT customerid, YEAR(orderdate) as yearorder
from Orders) -- el cte soloe xiste en tiempo de ejecucion
select yearorder, count(distinct customerid)
from CTE_YEAR
group by yearorder


select t.jefe, count(t.subalterno) from
(select j.firstname+ ' ' + j.lastname as jefe,
s.firstname+ ' ' +s.lastname as subalterno
from employees as j join employees as s
on j.EmployeeID=s.ReportsTo) as t (jefe, subalterno)
group by t.jefe 
go

---------------------------Modulo 12 --------------------------------------------------
-----------operadores de conjuntos-----------------------------------------
--interacciones entre conjuntos
-- ambos conjuntos deben tener el mismo numero de columnas compatibles
-- columnas compatibles quieres decir que tienen el mismo tipo de dato
---union
--customaers son similares ensus atributos
create view contactcatalog-- se puede crear una vista que una clientes y proveedores
as
select companyname, contactname, city , country from Customers
union all -- union all incluye todos los elementos hasta los repetidos, union no
select companyname, contactname, city , country from suppliers

--intersect devuelve solo filas iguales de ambos conjuntos
-- exepts devuelve filas distintas de dos conjntos
select customerid from Customers
intersect
select customerid from Orders -- se interceptn o tienen las mismas 89 filas

select customerid from Customers
EXCEPT
select customerid from Orders -- TIENEN 3 FILAS DISTINTAS , tres clientes que no han ordenado

--------cross aply y outer apply

-- permiten hacer join entre dos conjuntos
-- la tabla derecha es una tabla derivadoa o una funcion con valores de tabla en linea
-- primero se crea la funcion de tabla en linea
-- en esta caso la funcion regresa la ordenes hechas por un cliente sei ingresa el codigo de un cliente
--y la funcion regresa las ordenes hechas

create function fn_cliente_ordens (@codigocliente varchar(5))
returns table 
as
return (
select orderid, orderdate from orders
where customerid=@codigocliente
)
--revisar funcion
select * from fn_cliente_ordens('anton') 

-- en el ejercicio se quiere crear un join entre la funcion creada y la tabla customers
-- no es posible usar inner join hay que usar cross apply

select c.customerid, c.companyname, c.country, o.orderid, o.orderdate
from customers as c 
cross apply fn_cliente_ordens(c.CustomerID) as o -- se nombra la funcion y en vez de escribir el parametro se escribe la columna
 -- al ejecutar se obtiene lo equivalente a un inner join, los clientes con sus respectivas ordenes

 ------------- seccion 13-------------------------------------
 --funciones de ventana
 --funcion over permite crear la ventan
 -- las funciones de ventana permiten hacer operaciones que permiten simplificar las ocnsultas
 -- donde se nesecitan encontrar totales acumulados, promedios móviles o la falta de datos

------------------- modulo 14---------------------------
--funcion pivot y unpivot
-- pivot permite crear una tabla de referencia cruzada
-- pivot gira una expersioncon de valores de tablas cpnviertindo los valores de un a column aen avrias columnas
-- hace una operacion de sumarizacion de los valores
-- unpivot hace lo contrario
select categoryname, [1996], [1997], [1998] from
(select  c.categoryname, year(o.OrderDate) as año
, d.unitprice * d.quantity as parcial
from orders as o join [Order Details] as d on o.orderid=d.orderid
join products as p on d.ProductID=p.ProductID
join categories as c on c.categoryid=p.CategoryID) as t  -- primero se raliza la consult ainterna
pivot (sum (parcial) for año in ([1996], [1997], [1998])) as pvt

-- como solo existen tres años pivot permite que los tres años se vuelvan columnas
--- la funcion pivot se puede realizar de manera mas sencilla usando una view

create view  view_detallesventa --- primero se crea la view
as 
select  c.categoryname, year(o.OrderDate) as año
, d.unitprice * d.quantity as parcial
from orders as o join [Order Details] as d on o.orderid=d.orderid
join products as p on d.ProductID=p.ProductID
join categories as c on c.categoryid=p.CategoryID

create view detallesventa_pivot
as
select * from view_detallesventa 
pivot (sum (parcial) for año in ([1996], [1997], [1998])) as pvt

select * from detallesventa_pivot

-- unpivot

select * from detallesventa_pivot
unpivot (parcial for año in ([1996], [1997], [1998]) ) as upvt

---------- funncion pivot combinada con SQL dinámico
-- pivot convierte los valores en columnas
-- si se quieren columnas dinamicas se debe de programar

declare @años nvarchar (400)
set @años= ''
select @años=@años + '[' + t.año + '],' from -- el select ssirve para pasar los resultados a la variable
(select distinct cast((DATEPART(yyyy, orderdate)) as varchar (200)) as año
from orders) as t-- este query devuelve los años nada mas
set @años=left(@años,len(@años)-1) -- asi se le quita la coma que tiene de más
select @años
EXECUTE('select * from view_detallesventa pivot(sum(PARCIAL) for año in ('+@años+')) --ahora en vez de excribir los años, se concatena la variable creada
as pvt') -- SE CREA UN STRING Y SE EXECUTA esto permite hacer una concatenacion y que valores se generen a trevés de una funcion
--- se vuelve dinamico, por que si la funcion se le agregan más año la variable creada los recoge y no hay que escribirlos uno por uno
-- se debe de tener en cuenta que el primer select (select@años=@años) devuelve los años
-- un select es una integracion ya que devuelve cifra por cifra concatenando los datos

















