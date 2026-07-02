--Sebastian arredondo, prueba 3

/*
PREGUNTA 1
R: una transaccion en una base de datos es un conjunto de operaciones que asegurant 
que todas las operaciones se completen correctamente o en caso contrario, nunca de ellas de ejecute.
Las propiedades ACID son:
- Atomicidad: todas las operaciones de la transacción se realizan como una unidad indivisible.
- Consistencia: La base de datos pasa de un estado válido a otro estado de igual validez
- Aislamiento: Las operaciones de la transacción se ejecutan de forma aislada para no afectar al resto
- Durabilidad: los cambios son permanentes y persisten incluso en caso de algun error que pudiera ocurrir durante o despues.
si tuviera que hacer uso de multiples savepoints para manejar errores parciales en un procedimiento que asigna un agente a un incidente y 
actualiza simultaneamente el estado del incidente,
podria hacer algo asi:
create or replace procedure asignar_agente_incidente(
  p_agente_id    in incidentes.agenteid%type,
  p_incidente_id in incidentes.incidentid%type,
    p_estado       in incidentes.estado%type
) is
  savepoint sp_asignacion;
  insert into asignaciones(agenteid, incidentid) values (p_agente_id, p_incidente_id);
  savepoint sp_estado;
  update incidentes set estado = p_estado where incidentid = p_incidente_id;
exception
  when others then
    rollback to sp_asignacion;
    raise_application_error(-20001, 'Error al asignar agente o actualizar estado: ' || sqlerrm);
end asignar_agente_incidente;
si falla solo la actualizacion del estado, el savepoint sp_estado permite que la asignacion del agente al incidente se mantenga, 
mientras que la actualizacion del estado se deshace,
lo que permite manejar errores parciales sin perder la informacion de la asignacion del agente.

PREGUNTA 2
R: Un Data Warehouse es un sistema de almacenamiento de datos diseñado para consultas y análisis. en cambio, 
una base de datos transaccional está diseñado para operaciones de lectura y escritura.
para analizar las horas trabajadas por agente y por severidad de incidente, 
un modelo dimensional con una tabla de hechos llamada "horastotales" 
que contenga columnas como "AgenteID", "SeveridadID", "Horas" y "Fecha" estaria correcto.
Las dimensiones serían "Agentes" y "Severidad". hacerlo de esta forma permite automatizar y hacer mas rapido los analisis 
de datos, ya que se puede hacer un join entre la tabla de hechos y las dimensiones para obtener la información deseada.

PREGUNTA 3 
R: en oracle, la herencia se implementa mediante tipos de objetos, 
donde un tipo puede heredar atributos y métodos de otro tipo. 
si tomamos de ejemplo la jerarqueia de Agente, AgenteEspecialista y AgentePentester,
el tipo Agente tendría atributos como "nombre", "apellido" y un método "calcular_costo()". 
El tipo AgenteEspecialista heredaría estos atributos y métodos, 
y podría agregar un atributo adicional como "especialidad" y sobreescribir el método "calcular_costo()". 
El tipo AgentePentester heredaría de AgenteEspecialista 
y podría agregar un atributo adicional como "certificacion" y sobreescribir el método "calcular_costo()".
Declarar un tipo como NOT INSTANTIABLE significa que no se pueden crear instancias de ese tipo directamente, 
sino que solo se pueden crear instancias de sus subtipos.

PREGUNTA 4 
R: las ventajas de usar indices y partiicones en una base de datos son que mejoran el rendimiento de las consultas,
ya que permiten acceder a los datos de manera más eficiente.
Las desventajas son que pueden aumentar el tiempo de inserción y actualización de datos,
ya que se deben mantener los indices y particiones actualizados.
Para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion, 
se podría crear un índice compuesto en las columnas Severidad y FechaDeteccion, esto permitiría que las consultas 
que filtren por estas columnas se ejecuten más rápido.
Además, se podría particionar la tabla Incidentes por rango de FechaDeteccion,
lo que permitiría que las consultas que filtren por FechaDeteccion solo accedan a las particiones relevantes, 
en lugar de escanear toda la tabla.
El partition pruning es una técnica que permite al optimizador de consultas determinar 
qué particiones son relevantes para una consulta específica

*/

--ejercicio 1

create or replace procedure registrar_asignacion(
  p_agente_id    in asignaciones.agenteid%type,
  p_incidente_id in asignaciones.incidentid%type,
  p_horas        in asignaciones.horas%type,
  p_rol          in asignaciones.rol%type
) is
  v_proximo_id        number;
  v_total_horas       number;
  v_agentes_asignados number;
begin
  savepoint sp_horas;
  select nvl(sum(a.horas), 0) + p_horas
    into v_total_horas
    from asignaciones a
    join incidentes i on a.incidentid = i.incidentid
   where a.agenteid = p_agente_id
     and i.estado = 'Abierto';

  if v_total_horas > 100 then
    rollback to sp_horas;
    raise_application_error(-20001,
      'Validación fallida: el agente ' || p_agente_id ||
      ' superaría 100 horas en incidentes Abiertos.');
  end if;
  savepoint sp_agentes;
  select count(*)
    into v_agentes_asignados
    from asignaciones
   where incidenteid = p_incidente_id;

  if v_agentes_asignados >= 3 then
    rollback to sp_agentes;
    raise_application_error(-20002,
      'Validación fallida: el incidente ' || p_incidente_id ||
      ' ya tiene 3 agentes asignados.');
  end if;
  select nvl(max(asignacionid), 0) + 1
    into v_proximo_id
    from asignaciones;

  insert into asignaciones(
    asignacionid,
    agenteid,
    incidentid,
    horas,
    rol
  ) values (
    v_proximo_id,
    p_agente_id,
    p_incidente_id,
    p_horas,
    p_rol
  );

exception
  when others then
    rollback;
    raise_application_error(-20099,
      'Error en registrar_asignacion: ' || sqlerrm);
end registrar_asignacion;

--ejercicio 2

create table Dim_Agente (
  AgenteID     number primary key,
  Nombre       varchar2(100),
  Especialidad varchar2(100),
  FechaIngreso date
);

create table Dim_Incidente (
  IncidenteID    number primary key,
  Descripcion    varchar2(100),
  Severidad      varchar2(20),
  Estado         varchar2(20),
  FechaDeteccion date
);

create table Fact_Asignaciones (
  Fact_AsignacionID number primary key,
  AgenteID          number not null,
  IncidenteID       number not null,
  FechaAsignacion   date not null,
  Horas             number not null,
  Rol               varchar2(50),
  Severidad         varchar2(20),
  Estado            varchar2(20),
  constraint fk_fact_agente foreign key (AgenteID) references Dim_Agente(AgenteID),
  constraint fk_fact_incidente foreign key (IncidenteID) references Dim_Incidente(IncidenteID)
);

--consulta analitica
select
  a.agenteid,
  a.nombre,
  sum(asg.horas) as total_horas,
  count(distinct asg.incidentid) as incidentes_atendidos
from asignaciones asg
join agentes a on a.agenteid = asg.agenteid
group by
  a.agenteid,
  a.nombre
order by
  total_horas desc;

--ejercicio 3

create table incidentes (
  incidenteid    number primary key,
  descripcion    varchar2(100),
  severidad      varchar2(20),
  estado         varchar2(20),
  fechadeteccion date
)
partition by range (fechadeteccion) (
  partition p_2026_q1 values less than (date '2026-04-01'),
  partition p_2026_q2 values less than (date '2026-07-01'),
  partition p_2026_q3 values less than (date '2026-10-01'),
  partition p_2026_q4 values less than (date '2027-01-01')
);

create index idx_incidentes_severidad_fechadeteccion
  on incidentes(severidad, fechadeteccion);

select
  i.incidenteid,
  sum(a.horas) as total_horas
from incidentes i
join asignaciones a on a.incidenteid = i.incidenteid
where i.severidad = 'Critical'
  and i.fechadeteccion >= date '2026-01-01'
  and i.fechadeteccion <  date '2026-04-01'
group by i.incidenteid
order by total_horas desc;

explain plan for
select
  i.incidenteid,
  sum(a.horas) as total_horas
from incidentes i
join asignaciones a on a.incidenteid = i.incidenteid
where i.severidad = 'Critical'
  and i.fechadeteccion >= date '2026-01-01'
  and i.fechadeteccion <  date '2026-04-01'
group by i.incidenteid
order by total_horas desc;

select * from table(dbms_xplan.display);

/*
El índice compuesto ayuda a filtrar por Severidad y FechaDeteccion juntos. a la vez ka partición por rango en FechaDeteccion 
permite que el optimizador sólo examine la partición relevante.
Esto acelera la consulta, porque no se escanea toda la tabla Incidentes.
*/