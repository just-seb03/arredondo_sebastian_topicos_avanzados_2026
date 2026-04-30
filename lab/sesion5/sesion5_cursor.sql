--bloque que usa cursores para listar datos de clientes por orden

DECLARE
    CURSOR cliente_cursor IS
        SELECT Nombre, Ciudad
        FROM Clientes
        ORDER BY Nombre;

    v_nombre Clientes.Nombre%TYPE;
    v_ciudad Clientes.Ciudad%TYPE;
BEGIN
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_nombre, v_ciudad;
        EXIT WHEN cliente_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_nombre || ', Ciudad: ' || v_ciudad);
    END LOOP;
    CLOSE cliente_cursor; 
END;
/

-- bloque que aumenta 10% a los pedidos de los clientes

DECLARE
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;

    v_pedido_id Pedidos.PedidoID%TYPE;
    v_total_old Pedidos.Total%TYPE;
    v_nuevo_total NUMBER;
BEGIN
    OPEN pedido_cursor(1);
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total_old;
        EXIT WHEN pedido_cursor%NOTFOUND;

        v_nuevo_total := v_total_old * 1.10;

        UPDATE Pedidos
        SET Total = v_nuevo_total
        WHERE CURRENT OF pedido_cursor;

        DBMS_OUTPUT.PUT_LINE('SE ACTUALIZO UN PEDIDO');
    END LOOP;
    CLOSE pedido_cursor;

    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ALGO PASA PERO NO SE QUE'); 
        IF pedido_cursor%ISOPEN THEN
            CLOSE pedido_cursor; 
        END IF;
END;
/
