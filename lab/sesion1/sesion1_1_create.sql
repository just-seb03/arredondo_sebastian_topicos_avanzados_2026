--CREACION DE TABLA INTERMEDIA ENTRE PEDIDOS Y PRODUCTOS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos (
	PedidoID NUMBER,
	ProductoID NUMBER,
	Cantidad NUMBER,
	CONSTRAINT pk_pedidos_productos PRIMARY KEY (PedidoID, ProductoID),
	CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos (PedidoID),
	CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos (ProductoID),
    	)';
	DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos Creada.');
END;
/
--INSERCCION DE DATOS EN TABLA INTERMEDIA
BEGIN
    DBMS_OUTPUT.PUT_LINE('INSERTANDO DATOS EN DetallesPedidos...');
    INSERT INTO DetallesPedidos VALUES (101, 1,10);
    INSERT INTO DetallesPedidos VALUES (101,2,2);
    INSERT INTO DetallesPedidos VALUES (103,2,24);
    DBMS_OUTPUT.PUT_LINE('Datos creados');
END;
/
COMMIT;

