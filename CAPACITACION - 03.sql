--capacitacion 03
--06/02/2023
------------ modulo 15: procedimientos almacenados
-- como insertar valores en una tablas usan sp 
--- SQL dinámico hace referencia a el uso de la combinacion de concatenacion con variables 
--- para asi asignarles valor a las variables y la sentencia cambie y asi reutilizarlo

create procedure proc_insert_cliente (

@customerid              varchar(5), 
@companyname             varchar(100),
@contactname             varchar(100), 
@country                varchar(100))
as

insert into
Customers(customerid, CompanyName, contactname,Country)

values(
@customerid,
@companyname,  
@contactname,  
@country )  
go

exec proc_insert_cliente 'CHB33', 'visoal', 'victor cardenas', 'guatemala' -- si hay algun valor repetido va a haber conflicto con la llave primaria
--- consulta para ver si se insertaron los datos correctamente
select * from customers where customerid = 'CHB33'

-- EL SP ENCApSula UNA INSTRUCCION 



-----------------parametros de entrada y de salida con SP


create proc proc_cambio_pais @paisnuevo varchar (100), @paisviejo varchar(150),
@filasafectadas int output
as
UPDATE CUSTOMERS set country=@paisnuevo -- un procedimiento con parametros de entrada
where country=@paisviejo
set @filasafectadas=@@rowcount --asi se consiguen las filas afectadas
go

declare @variable int
exec proc_cambio_pais 'estados unidos' , 'USA', @VARIABLE output-- este es el parametro de salidase traslada el parametro de salida a la variable creada
select @variable -- se muestra la variable, que obtiene el valor que le asigna el procedimiento


--para desmotrar se hace un select
select * from customers
where country ='estados unidos'

-- los parametros se definen en el encabezado del código de procedimiento
--los parametros se pueden descubrir por medio de sys.parameters

select * from sys.parameters  WHERE object_id = 1074102867 --- ASI SE TIENE LOS PARAMETROS


select * FROM sys.objects WHERE NAME = 'proc_cambio_pais'

--Los parametros de salida permiten devolver valores de un procedimiento almacenado


-----------------------EJECUCION DE PROCEDIMIENTOS ALMACENADOS-------------------------

alter procedure proc_productionporfecha(@mes int, @año bigint)
as
select distinct p.productid, p.productname
from Products as p join [Order Details] as d on p.productid=d.ProductID
join orders as o on o.OrderID=d.orderid
where datepart (MM,o.orderdate)=@mes and datepart(yyyy, o.orderdate)=@año
go 

exec proc_productionporfecha 3 , 1997


create procedure proc_clientesporpais @pais varchar(100)
as
select customerid, companyname, contacttitle
from Customers 
where country=@pais 
go 

execute proc_clientesporpais 'venezuela'  --en el procedimiento se pusieron parametros
------ SQL DINAMICO
---  sql DINÁMICO ES CÓDIGO T-SQL ensamblado en una cadena de caracteres, interpretado como un comando y ejecutado
--- SQL dinamico proporciona flexibilidad para tareas administrativas

-- ejemlo de sql dinamico
declare @tablas varchar (100)
set @tabla='products'
exec ('select * from ' + @tabla )
--lo dinamico esta en que se puede mencionar a cualquier tabla 
-----------------------------MODULO 16 ----------------------------------
--ELEMENTOS DE PROGRAMCION T-SQL
-- CON set O select se le puede asignar un valor a una varieble

declare @tabla varchar (50) = 'customers';
set @tabla='categories' --aqui se asigna el valor
execute ('select * from ' + @tabla )
go -- el alcance de la variable llega hasta el go

declare @valor int;
select @valor=count(*) from orders
select @valor

--------------------------modulo 17 ------------------------------------------------

--Manejo de errores
-- se puede crear errores con  sp_addmessage

exec sp_addmessage 50001, 16 , 'la division entre 0 no esta definida'

-- se debe de crear sobre la base de datos master
raiserror (50001, 16, 1) -- asi se muesttra el error que se creo

select 810/0
select @@error --cuando se genera un error se crea una variable en el sistema que contiene el codigo del ultimo error

begin try 
select 80/0
end try
begin catch

select error_number() as numero_error,
ERROR_SEVERITY() as numeroseveridad,
error_state() as numeroestado
end catch

--------------------------------MODULO 18--------------------------------------
-- TRANSACCIONES Y MOTOR DE BASE DE DATOS


-- UNA TRANSACCION ES UN GRUPO DE TAREAS QUE DEFINEN UNA UNIDAD DE TRABAJO
-- NO SE RTERMINA UNA TERINACION PARCIAL

--CON LA FUNCION DEGIN Y COMMIT Y ROLL BACK TRANSACTION TRANSACTION SE MARCAN LOS PUNTOS DE PARTIDA Y CIERRE DE UNA TRANSACTION
-- CON EL ROLLBACK TRANSACTION SE ELIMINA LA TRANSACTION, DESHACIENDO TODA TRANSACION HECHA 
-- TODA TRANSACCION HECHA PASA POR EL LOAD DE TRANSACCIONES
-- esta es una bitacora que registra toda transaccion hecha y se espera laconfirmacion
-- solo escrito el commit queda guardad el registro
--para declarar un atransaccion se begin transaction para declararla
--hay un sp llamado sp_lock el cual indica los bloqueos con objetos que estan establecidos, con bloqueos se refiere a conexiones.
-- en sexirity > login se puede crear permisos de acceso

---------------------------modulo 19 ----------------------------------
--factores en el rendimiento de las consultas
--desplegandod atos dse rendimient de consulta
------------------MODULO 20 -----------------------------
--CONSULTAR LA METADATA

SELECT NAME , OBJECT_ID, SCHEMA_ID, TYPE, TYPE_DESCFROM SYS.TABLES











----