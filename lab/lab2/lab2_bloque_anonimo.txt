--ESTE BLOQUE ANALIZA CADA DETALLEPEDIDO Y COMENTA SI SU VALOR ES MAYOR A 1000 O NO 

BEGIN
	FOR precio_total in (
		select dp.DetalleID, (dp.Cantidad + p.Precio) as carrito
		from DetallesPedidos dp
		inner join Productos p on dp.ProductoID = p.ProductoID
		)
	LOOP
		IF precio_total.carrito > 1000 then
			DBMS_OUTPUT.PUT_LINE('EL PEDIDO ' || precio_total.DetalleID || ' ES MAYOR A 1000');
		ELSE
			DBMS_OUTPUT.PUT_LINE('EL PEDIDO ' || precio_total.DetalleID || ' ES MENOR A 1000');
		END IF;
	END LOOP;
END;
/
