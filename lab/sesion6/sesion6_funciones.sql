CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) 
RETURN NUMBER 
IS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    -- Intentamos obtener la fecha de nacimiento del cliente
    SELECT FechaNacimiento INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    -- Calculamos la edad en años
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    
    RETURN v_edad;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: El cliente con ID ' || p_cliente_id || ' no existe.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error inesperado: ' || SQLERRM);
        RETURN NULL;
END;
/
