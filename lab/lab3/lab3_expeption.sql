--bloque excepcion sql por precio bajo

DECLARE
	bajo EXCEPTION;

BEGIN
	FOR precio in (
	select Productos.Precio  from Productos
		)
	LOOP
		if precio>100 then
		RAISE bajo;
		END IF;

	END LOOP;

EXCEPTION
	when bajo then
	DBMS_OUTPUT.PUT_LINE('ERROR: EL PRECIO ES MENOR QUE 100');
	WHEN NO_DATA_FOUNT THEN
	DBMS_OUTPUT.PUT_LINE('ERROR: NO SE ENCONTRO EL DATO');
END;
/

