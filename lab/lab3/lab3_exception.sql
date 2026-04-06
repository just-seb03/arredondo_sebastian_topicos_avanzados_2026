--bloque excepcion sql por precio bajo

DECLARE
	bajo EXCEPTION;

BEGIN
	FOR precio in (
	select Productos.Precio  from Productos
		)
	LOOP
		if precio<100 then
		RAISE bajo;
		END IF;

	END LOOP;

EXCEPTION
	when bajo then
	DBMS_OUTPUT.PUT_LINE('ERROR: EL PRECIO ES MENOR QUE 100');
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('ERROR: NO SE ENCONTRO EL DATO');
END;
/


-- bloque excepcion sql para id duplicado

SET SERVEROUTPUT ON;

BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    VALUES (1, 'SIN NOMBRE', 'ITALIA', TO_DATE('1963-03-03', 'YYYY-MM-DD'));

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El ID YA EXISTE.');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ALGO PASA PERO NO SE QUE.');
END;
/
