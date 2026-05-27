CREATE OR REPLACE FUNCTION calcular_promedio_precio_producto(p_id_producto IN NUMBER) RETURN NUMBER AS
	v_precio_promedio NUMBER;
BEGIN
	SELECT AVG(p.Precio * d.Cantidad) INTO v_precio_promedio
	FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.ProductoID = p_id_producto;
	RETURN NVL(v_precio_promedio, 0);
END;
/
-- Procedimiento
CREATE OR REPLACE PROCEDURE incrementar_precios_alto_valor(p_porcentaje_incremento IN NUMBER) AS
	CURSOR cur_productos IS
    	SELECT ProductoID, Precio
    	FROM Productos;
BEGIN
	FOR reg_producto IN cur_productos LOOP
    	IF calcular_promedio_precio_producto(reg_producto.ProductoID) > 500 THEN
        	UPDATE Productos
        	SET Precio = reg_producto.Precio * (1 + p_porcentaje_incremento / 100)
        	WHERE ProductoID = reg_producto.ProductoID;
        	DBMS_OUTPUT.PUT_LINE('Producto ' || reg_producto.ProductoID || ' actualizado.');
    	END IF;
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC incrementar_precios_alto_valor(10);



CREATE TABLE AuditoriaPedidos (
	AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PedidoID NUMBER,
	ClienteID NUMBER,
	Total NUMBER,
	FechaEliminacion DATE
);

CREATE OR REPLACE TRIGGER auditar_eliminacion_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaPedidos (PedidoID, ClienteID, Total, FechaEliminacion)
	VALUES (:OLD.PedidoID, :OLD.ClienteID, :OLD.Total, SYSDATE);
END;
/
DELETE FROM Pedidos WHERE PedidoID = 102;
SELECT * FROM AuditoriaPedidos;
