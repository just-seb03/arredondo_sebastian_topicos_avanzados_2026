CREATE OR REPLACE PROCEDURE aumentar_precio_simple(
    p_id IN NUMBER, 
    p_porcentaje IN NUMBER
) AS
BEGIN
    UPDATE Productos
    SET Precio = Precio + (Precio * p_porcentaje / 100)
    WHERE ProductoID = p_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('no se encontro la id');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Precio actualizado.');
    END IF;
    
    COMMIT;
END;
/



CREATE OR REPLACE PROCEDURE contar_pedidos_simple(
    p_cliente_id IN NUMBER, 
    p_conteo OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_conteo
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
END;
/
