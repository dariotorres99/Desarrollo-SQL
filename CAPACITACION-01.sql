USE Northwind
go

select 'hola mundo'
select GETDate()
select * 
from Customers

/* Bases de datos del sistema

Master: base de datos de la base deaos, todo objeto creado se registra aqui. 
hay que hacer back up con frecuencia. 
Si se llegan a corromper las bases datos hay que hacer back up a master.

Model: plantilla que sirve como modelo para cualquier base datos mal especificado.
MSDB: base de datos del agente que maneja las tareas programadas.
temdb: todo objeto temporal se guarda aca.


/* La implementacion de código SQL en microsoft se conoce como transact.
las instrucciones transact se pueden clasificar en tres categorías:

DML: declaraciones para consultar y modificar datos, select,insert update, delete

DDL: DECLARACIONES PARA DEFINICIONES DE OBJETOS, CREATE, ALTER , DROP.
DCL: declaraciones de permiso de seguridad */ */

SELECT  CustomerID, CompanyName, ContactName, Country
FROM Customers
where CustomerID = 'ABCD1'

insert into Customers (CustomerID, CompanyName, ContactName, Country)
values ('ABCD1', 'VISOAL', 'Victor Cardenas', 'Guuatemala')
go

UPDATE Customers set CompanyName = 'Visoa, S.A'
WHERE CustomerID = 'ABCD1'

DECLARE @MIPRIMERAVARIABLE VARCHAR (100)
SET @MIPRIMERAVARIABLE = 'bien venido a nuestro curso'
select @MIPRIMERAVARIABLE
/* las variables locales en T-SQL almacenan temporalmente un valor 
de un tipo de datos especifico el nombre comienza con @, si lleva @@ son funciones del sistema */
-- Para dividir el código en batches se utiliza GO
/*TEORIA DE CONJUNTOS:
UN CONJUNTO ES UN conjunto, cada fila es una entidad y cada columna es un atributo.
uso de proceso declarativo basado en conjunto (filtracion de datoscon WHERE)
elementos del conjunto deben ser unico (UNIQUE KEY)
SIN OREDN DEFINIDO PARA RESULTADO DE CONJUNTO. (para ordenaar se debe usar un order by.)*/

sp_help customers --asi se obtiene informacion principalde la tabla.

/*Logica del predicado: base matemática para el modelo de base de datos relacional.
esta es una expresion verdadera o falsa. tambien es conocida como expresion booleana. */
/* cuando se utilizan funciones de agregado como COUNT() SE debe de usar un group by 
en este tipo de queries no se utiliza where, se utiliza HAVING Y despues se pone el order by*/

select country, COUNT(*) AS CONTEO
from Customers 
WHERE Country IN ('MEXICO', 'argentina', 'brazil')
group by Country
having COUNT (*) > 10
order by CONTEO


/*ORDEN DE CONSULTA
select
from 
WHERE
GROUP BY
HAVING
ORDER BY
*/ 

/* ORDEN en FROM : NOMBRE_SERVIDOR.nOMBRE_BASE_DEDATOS.dbo.NOMBRE_ESQUEMA*/

---funcion case
select productname, categoryid from Products
select productname,
    case categoryID
	WHEN 1 THEN 'BEBIDA'
	WHEN 2 THEN 'LACTEOS'
	WHEN 3 THEN 'CONDIMENTOS'
	WHEN 4 THEN 'OTROS'
	ELSE 'NO EN VENTA'
	END AS CATEGORY
FROM PRODUCTS
order by productname
GO
/* RESUMEN MODILO 3 
-ELIMINACIÓN DE DUPLICADOS USANDO DISTINCT
USO DE ALIAS DE COLUMNAS Y DE TABLA
ESCRIBIENDO EXPRESIONES SIMPLES 
uso de escalares para hacer calculos
*/

---------------------MODULO 4----------------------------------

/* lA CLAUSULA FROM PUEDE CONTENER TABLAS Y OPERADORES
El conjunto de resultados de la cláusula FROM es una tabla virtual
la calusula from puede establecer alias de tablas para su usos posteriores

-Cros Join: combina todas las filas en ambas tablas
- Inner join: muestra las filas donde las tablas coinciden (producto cartesiano)
- Outer join : se conservan todas las filas de la tabla designada, coincidiendo con las filas
de otra tabla recuperada adicionando las filas donde no coinciden. */

select * from customers
select * from Orders

SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName,
Customers.country, orders.orderid, orders.orderdate
from customers inner join orders
on customers.customerid = orders.customerid

SELECT C.CustomerID, C.CompanyName, C.ContactName,
C.country, o.orderid, o.orderdate
from customers as c , orders as o
where c.customerid = o.customerid
--- Se realizar la mismo consulta sin usar inner join e igualando las tablas en WHERE
---INNER JOIN A MÁS DE DOS TABLAS
--- La palabra inner se puede omitir

SELECT C.CustomerID, C.CompanyName, C.ContactName,
C.country, o.orderid, o.orderdate, p.ProductID, d.UnitPrice, d.Quantity
from customers as c INNER JOIN orders as o
ON c.customerid = o.customerid
INNER JOIN [Order Details] as d
on o.OrderID = d.OrderID
inner join products as p
on d.ProductID=p.ProductID

----- OUTER JOIN------

SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName,
Customers.country, orders.orderid, orders.orderdate
from customers LEFT OUTER join orders
on customers.customerid = orders.customerid

--LA CLAUSULA LEFT RIGHT O FULL DESIGNA QUE ABLA SE CONSERVA
--- el full outer join es la combinacion de los datos que coinciden los datos que no coinciden

SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName,
Customers.country, orders.orderid, orders.orderdate
from customers  full outer join orders
on customers.customerid = orders.customerid

--- cross join 
-- es un producto cartesiono que es el resultado de la combinacion de cada elemento de la tabla A
--con la tabla B
-- el cross join no nesecita un campo en comun

SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName,
Customers.country, orders.orderid, orders.orderdate
from customers  cross join orders
---on customers.customerid = orders.customerid
-- casi nunca se utiliza el cross join
-- el self join como tal no existe
-- para crear un consulta de una tabla que este relacionada con sigo misma se utiliza el self join

select j.firstname + '' + j.lastname as jefe
, s.firstname + '' + s.lastname
from Employees as j join employees as s 
on j.employeeid = s.ReportsTo

---------- SECCION 5 ------------------

--- COMO ORDENAR Y FILTRAR DATOS

SELECT *
FROM Suppliers
WHERE Country = 'japan'

Select *
from Suppliers
where CompanyName like '_a%' -- a es la segunda letra

Select *
from Suppliers
where CompanyName like '_a%' -- a es la segunda letra

Select *
from Suppliers
where CompanyName like '[A-C]%' -- LOS QUE NO COMIENZAN CON A B O C

Select *
from Products
where UNITPRICE BETWEEN 20 AND 25 -- RANGO DE PRECIOS ENTRE 20 Y 25

Select *
from Categories
where CATEGORYNAME IN ('CONDIMENTS', 'dairy products')

----logica de tres valores
select productname, unitprice
from Products order by unitprice desc offset 10 rows
fetch next 10 rows only --- se indice que salte las primeras 10 filas y presente las proximas 10
--- fetch con ciclo
declare @i int =0
while @i > 10
begin --aqui se empieza el ciclo
    select lastname + ' , ' + firstname from Employees -- se concatena dos columnas
	order by LastName asc offset @i rows
	fetch next 2 rows only
	set @i = @i + 2
end --- asi se crea paginacion de 2 en 2 filas


--- manejo de valores nulos
select companyname, phone
, fax = case
        when fax is null then 'no tiene'
		else fax
		end
from customers
go

select companyname, isnull(fax,0) from customers -- si el valor es nulo isnull sustituye el valor

select companyname, phone, fax, coalesce(fax, phone , 'no tiene') as mediocomunicacion
from customers -- coalesce permite agregar parametros que intentara colocar los valores en dependencia si son nulos.

-------------------SECCION 6---------------------
-- TIPOS DE DATOS

declare @variable as varchar (150)

-- con la funcion cast se convierte el tipo de dato
/* SQL server solo permite dos tipos de datos de caracteres:
- regular: char, varchar
-unicode:nchar,nvarchar
-text esta obsoleto, utilizar varchar (max) en su lugar
la diferccnia entre char y varchar es la longitud de los caracteres, los var se ajustan.
-- collation: es la intercalación que es una coleccion de propiedades de caracteres 
-- concat sirve para unir dos textos 
funciones comunes que modifican cadenas de texto:
substring: regresa parte del texto
left, right : regresan la parte izquierda o derecha del texto
len: regresa la longitud de la variable en caracteres
replace: reempleza todas los match de un valor especifico de una variable string
*/

select companyname, upper(companyname) as mayusculas
, lower(companyname) as minusculas, substring(companyname,5,5) as porciontexto
,len(companyname) numeroletras from suppliers
go

/* predicado like
% representa una cadena de cualquier longitud
_ representaun solo caracter
[] representa un solo carcer dentro del rango especificado
