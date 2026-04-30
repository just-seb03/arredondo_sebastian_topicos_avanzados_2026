CREATE OR REPLACE FUNCTION obtener_precio_promedio 
RETURN NUMBER AS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_promedio FROM Productos;
    RETURN v_promedio;
END;
/

SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();