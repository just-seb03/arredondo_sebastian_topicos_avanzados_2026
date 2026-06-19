CREATE ROLE rol_usuario;
CREATE ROLE rol_admin;

GRANT SELECT, INSERT ON Productos TO rol_usuario;
GRANT SELECT, INSERT ON Pedidos TO rol_usuario;

GRANT ALL PRIVILEGES ON Productos, Pedidos, Clientes, DetallesPedidos TO rol_admin;

CREATE USER usuario1 IDENTIFIED BY user123;
GRANT rol_usuario TO usuario1;

CREATE USER admin1 IDENTIFIED BY admin123;
GRANT rol_admin TO admin1;


--actividad 2

EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

CREATE INDEX idx_pedidos_clienteid ON Pedidos(ClienteID);

EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);