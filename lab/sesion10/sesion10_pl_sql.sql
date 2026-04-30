CREATE OR REPLACE PROCEDURE calcular_costo_detalle (
    p_DetalleID IN NUMBER,
    p_CostoTotal IN OUT NUMBER
) AS
BEGIN
    SELECT prod.Precio * det.Cantidad
    INTO p_CostoTotal
    FROM DetallesPedidos det, Productos prod
    WHERE det.ProductoID = prod.ProductoID
    AND det.DetalleID = p_DetalleID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_CostoTotal := 0;
        DBMS_OUTPUT.PUT_LINE('no existe detalle');
END;
/