-- Sebastian Arredondo 

-- Pregunta1
    --Una relacion mucho a muchos establece que ambos atributos pueden contener al menos 1 atributo de su atributo conector
    --esto con el fin de sumarear objetos o caracteristicas que pueden ser o no dependientes o unicas en su "dueño".
    --un ejemplo seria la relacion entre un producto de un supermercado y un cliente. muchos clientes pueden comprar el mismp
    --producto y el mismo cliente puede tener varios del mismo.
    --dentro del sql de la evaluacion se puede presenciar este tipo de relacion entre la tabla agente e incidente tal que
    --se define que un agente puede tener varios incidente como tambien un tipo de incidente puede ocurrirle a varios agentes distintos.

-- Pregunta2
    --Una vista es basicamente una tabla nueva el cual utiliza tablas ya existentes para su creacion usando consultas.
    --Su aplicacion se basa en visualizar o sumarear de forma mas legible datos los cuales sus atributos estan esparcidos
    --por diversas tablas. por ejemplo las que basan sus datos en indentificadores relacionales entre tablas ajenas
    --La consulta propuesta seria la siguiente:
        CREATE OR REPLACE VIEW agente_incidente FROM
            SELECT Incidentes.Descripcion, sum(Asignaciones.Horas)
                From Asignaciones
                JOIN Incidentes on Incidentes.IncidenteID=Asignaciones.IncidenteID
                group by Incidentes.Descripcion

-- Pregunta3
    --Las exepciones predefinidas son condicionales estandar de las reglas de negocio cuyo fin es identificar 
    --Conflictos que  puedan afectar la salida o entrada de datos en alguna consulta.
    --Estas excepciones son estandar y manejan casos concretos y generales, como error de dato, de tipo o error de 
    --falta de existencia.
    --Un ejemplo de aquello seria optar por:
            CREATE PROCEDURE test(
                    dato INT) as
                BEGIN
                    select tabla.datos into dato
                    from tabla
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: NO SE ENCONTRO EL DATO');
-- Pregunta4
    --un cursor tiene como fin iterar y almacenar datos entrantes para su posterior uso. hay que verlo como los directorios 
    --tmp del sistema. estos con el fin de poder hacer consultas complejas sin peligrar los errores relacionados con
    --row multiple, a la vez al tener la info almacenada, %NOTFOUND da la posibilidad de finalizar cuando la iteracion
    --llega al final de la tabla, %ISOPEN es una forma de comprobar si luego de una excepcion o conflicto el cursos sigue corriendo

--ejercicio1

CREATE PROCEDURE especialidades(
    nombre VARCHAR2
    horas NUMBER
) as
BEGIN 
    DECLARE
        CURSOR horas_cursor(horas NUMBER) IS
            SELECT Asignaciones.Horas
            FROM Asignaciones
            JOIN Incidentes on Incidentes.IncidenteID=Asignaciones.IncidenteID
            JOIN Agentes on Agentes.AgenteID=Asignaciones.AgenteID
            WHERE Horas>=30
            FOR UPDATE;
        BEGIN 
            OPEN horas_cursor()
            LOOP
            FETCH horas_cursor into horas;
            DBMS_OUTPUT.PUT_LINE(nombre, horas)
            END LOOP;
            CLOSE horas_cursor
    end;
    /

--ejercicio2
    DECLARE
    CURSOR horas_cursor(p_cliente_id NUMBER) IS
        SELECT horas
        FROM Asignaciones
        join Incidentes ON Incidentes.IncidenteID = Asignaciones.IncidenteID
        where Incidentes.Severidad="Critical"
        FOR UPDATE;

    a_horas NUMBER;
    a_horas_total NUMBER;
BEGIN
    OPEN horas_cursor(1);
    LOOP
        FETCH horas_cursor INTO a_horas;
        EXIT WHEN horas_cursor%NOTFOUND;

        a_horas_total := a_horas * 1.10;

        UPDATE Asignaciones
        SET Total = a_horas_total
        WHERE CURRENT OF horas_cursor;

        DBMS_OUTPUT.PUT_LINE('SE ACTUALIZO UN INCIDENTE');
    END LOOP;
    CLOSE horas_cursor;}

    COMMIT; 

--ejercicio3

CREATE OR REPLACE TYPE incidente_obj as objet (
    incidente_id NUMBER,
    descripcion VARCHAR2(4000),
    MEMBER FUNCTION get_reporte RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY incidente_obj AS
    MEMBER FUNCTION get_reporte RETURN VARCHAR2 IS
    BEGIN
        RETURN self.incidente_id;
    END;
END;
/

CREATE TABLE incidentes_tabla_obj OF incidente_obj;

insert into incidentes_tabla_obj
SELECT incidente_obj(incidente_id, descripcion) FROM Incidentes;

SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_incidentes IS SELECT VALUE(i) FROM incidentes_tabla_obj i;
    v_inc incidente_obj;
BEGIN
        OPEN c_incidentes;
        LOOP
        FETCH c_incidentes INTO v_inc;
        EXIT WHEN c_incidentes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_inc.get_reporte());
        END LOOP;
        CLOSE c_incidentes;
END;
/

        

