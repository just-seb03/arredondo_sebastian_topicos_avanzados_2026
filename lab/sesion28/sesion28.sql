CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_cliente_existe NUMBER;
BEGIN
    SAVEPOINT inicio_pedido;
    
    SELECT COUNT(*) INTO v_cliente_existe
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    
    IF v_cliente_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente no existe.');
    END IF;

    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES (104, p_cliente_id, p_total, p_fecha_pedido);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_pedido;
        RAISE;
END;
/


--actividad 2

CREATE INDEX idx_detalles_pedido_prod ON DetallesPedidos (PedidoID, ProductoID);

ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);

SELECT ClienteID, SUM(Total) AS TotalEnero
FROM Pedidos
WHERE FechaPedido >= TO_DATE('2025-01-01', 'YYYY-MM-DD') 
  AND FechaPedido < TO_DATE('2025-02-01', 'YYYY-MM-DD')
GROUP BY ClienteID;