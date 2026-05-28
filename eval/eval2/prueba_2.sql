-- preguntas de teoria

--1 la diferencia entre un procedimiento almacenado y una función pl/SQL 
--es que un procedimiento almacenado es un bloque de código 
--que realiza una tarea específica y no devuelve un valor
--mientras que una función PL/SQL si devuelve un valor.

--un ejemplo de cada una respectoa la tabla asignaciones seria:
--procedimiento almacenado para registrar una asignacion
--CREATE OR REPLACE PROCEDURE registrar (
--  ID_agente    int,
--  ID_incidente int,
--  horas       iint,
--  rol         VARCHAR(100)
--)
--AS
--  Nueva NUMBER;
--BEGIN
--  SELECT MAX(asignacionID) + 1 INTO Nueva FROM Asignaciones;
--  INSERT INTO Asignaciones (asignacionID, AgenteID, IncidenteID, Horas, Rol)
--  VALUES (Nueva, ID_agente, ID_incidente, horas, rol);
--  COMMIT;

--pl/sql para calcular el total de horas asignadas a un agente
--CREATE OR REPLACE FUNCTION calcular_horas_agente(AgenteID IN NUMBER)
--RETURN NUMBER
--AS
--  Total int;
--BEGIN
--  SELECT SUM(horas) INTO Total
--  FROM Asignaciones
--  WHERE AgenteID = AgenteID;
--  RETURN Total;
--END;


-- 2. un parametro in out es un tipo de parametro que se 
--utiliza para pasar valores a un procedimiento o función.

-- un ejemplo basico en pseudocodigo con respecto a la tabla asignaciones seria:
--CREATE OR REPLACE PROCEDURE actualizar_horas (
--  agenteID NUMBER,
--  horas IN OUT NUMBER
--)
--AS
--BEGIN 
--  SELECT SUM(horas) INTO horas
--  FROM asignaciones
--  WHERE agenteID = agenteID;
--  horas = horas + 2;
--END;

--3 una funcion almacenada se puede usar en una consulta sql como por ejemplo para calcular 
--el total de horas asignadas a un agente el fin de esta es poder ejecutar consultas dinamicamente
--ya que al simplificar la busqueda de ciertos datos facilita la construccion de consultas
--mucho mas complejas, por ejemplo:
--select nombre, calcular_horas(agenteID) as total
--from agentes;

--el procedimiento seria en este caso
--CREATE OR REPLACE PROCEDURE calcular_horas_agente(agenteID IN NUMBER)
--AS
--  total_horas NUMBER;
--BEGIN
--  SELECt SUM(Horas) INTO total_horas
--  FROM aasignaciones
--  WHERE agenteID = agenteID;
--end
--en el ejemplo anterior se puede ver como se simplifican las consultas asi
--optimizando los tiempos de trabajo.

--4: un trigger es un disparador que se ejecuta automáticamente en respuesta a ciertos 
--eventos en la base de datos, como inserciones, actualizaciones o eliminaciones. 
--Se utiliza para mantener la integridad de los datos, realizar validaciones o 
--ejecutar acciones adicionales sin necesidad de intervención por parte del usuario.
--un ejemplo seria que se ejecute un trigger para añadir datos a una tabla de auditoria o 
--tambien para que cada que se añada un nuevo dato que tenga relacion con otra tabla
--se actualice esta para evitar problemas con las keys de las mismas.


--un ejemplo de trigger al insertar una asignacion en la tabla asignaiciones:
--  after insert on asignaciones
--  for each row
--  update Incidentes
--  set estado = 'en proceso'
--  where incidenteid= :new incidenteid and estado = 'abierto'


--ejercicios 

SET SERVEROUTPUT ON;


--ejercicio 1

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    ID_agente    IN NUMBER,
    ID_incidente IN NUMBER,
    horas       IN NUMBER,
    rol         IN VARCHAR2
)
AS
    proximoID NUMBER;
    existe_agente NUMBER;
    existe_incidente NUMBER;
    asignado NUMBER;
BEGIN
    SELECT COUNT(*) INTO existe_agente FROM Agentes WHERE AgenteID = ID_agente;
    if existe_agente = 0 then
        DBMS_OUTPUT.PUT_LINE('no se encontro el agente');

    end if;

    SELECT COUNT(*) INTO existe_incidente FROM Incidentes WHERE IncidenteID = ID_incidente;
    if existe_incidente = 0 THEN
        DBMS_OUTPUT.PUT_LINE('no se encontro el incidente');

    end if;

    SELECT COUNT(*) INTO asignado FROM Asignaciones 
    WHERE AgenteID = ID_agente AND IncidenteID = ID_incidente;
    if asignado > 0 then
        DBMS_OUTPUT.PUT_LINE('el agente ya está asignado a un incidente');

    end if;

    SELECT MAX(AsignacionID) + 1 INTO proximoID FROM Asignaciones;
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (proximoID, ID_agente, ID_incidente, horas, rol);
    UPDATE Incidentes SET Estado = 'pendiente' 
    WHERE IncidenteID = ID_incidente AND Estado = 'abierto';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('se registro la asignacion');
END;
/

--ejercicio 2

CREATE OR REPLACE function calcular_horas_agente(agenteID IN NUMBER)
return NUMBER
AS
    total_horas NUMBER;
BEGIN
    SELECT NVL(sum(Horas), 0) INTO total_horas
    FROM Asignaciones
    WHERE AgenteID = agenteID;
    return total_horas;
end;
/


CREATE OR REPLACE PROCEDURE mostrar_carga_agentes
AS
BEGIN
    FOR agente IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes)
    LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(agente.Nombre, 25) || RPAD(agente.Especialidad, 25) || calcular_horas_agente(agente.AgenteID));
    END LOOP;
END;
/


CREATE SEQUENCE seq_auditoria;

CREATE TABLE AuditoriaAsignaciones (
    ID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(20),
    FechaRegistro DATE
);

-- Trigger
CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF INSERTING then
        INSERT INTO AuditoriaAsignaciones 
            (ID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (seq_auditoria.NEXTVAL, :NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, 
                :NEW.Horas, 'INSERT', SYSDATE);
    END IF;
    
    if DELETING then
        INSERT INTO AuditoriaAsignaciones
            (ID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (seq_auditoria.NEXTVAL, :OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID,
                :OLD.Horas, 'DELETE', SYSDATE);
    end if;
end;
/





