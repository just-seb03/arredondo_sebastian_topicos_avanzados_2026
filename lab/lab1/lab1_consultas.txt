-- consultas simples

select * from Productos;
select Nombre from Clientes;


-- consultas con funciones agregadas

select sum(Total) as gasto_total from Pedidos;


select * from Pedidos
where Total = (
	select min(Total) from Pedidos
		);

-- consultas con expresiones regulares

select * from Clientes 
where REGEXP_LIKE(Nombre, '^J');

select * from Clientes
where REGEXP_LIKE(Nombre, 'ez$');


-- vistas

create or replace view total_clientes as
select Clientes.Nombre, sum(Pedidos.Total) as Total
from Clientes
inner join Pedidos on Clientes.ClienteID = Pedidos.ClienteID
group by Clientes.Nombre
order by Total desc;


create or replace view ventas_productos as
select Productos.Nombre as Producto, sum(DetallesPedidos.Cantidad) as Vendidos
from Productos
inner join DetallesPedidos on Productos.ProductoID = DetallesPedidos.ProductoID
group by Productos.Nombre;

