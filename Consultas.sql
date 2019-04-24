-- Primera consulta: Los 10 vehículos más 'observados' en el transcurso del día de hoy.
--Aqui además se visualiza el numero de veces observado.
SELECT * FROM (
SELECT DISTINCT nPlate AS top_observed_vehicles,COUNT(nPlate) AS times_seen FROM OBSERVATIONS
WHERE SUBSTR(odatetime, 1, 8)=SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)
GROUP BY nPlate ORDER BY COUNT(nPlate) DESC)
WHERE ROWNUM<11;
--Esto es lo que piden.
SELECT * FROM (
SELECT DISTINCT nPlate AS top_observed_vehicles FROM OBSERVATIONS
WHERE SUBSTR(odatetime, 1, 8)=SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)
GROUP BY nPlate ORDER BY COUNT(nPlate) DESC)
WHERE ROWNUM<11;
---REVISAR---
-- Segunda consulta: Listado de carreteras y su valor de velocidad promedio establecida, 
--ordenado de mayor a menor velocidad en primera instancia y por orden alfabético 
--de carreteras en segunda, contando ambos sentidos.
--Es decir, se ordenan de mayor a menor velocidad y si hay carreteras 
--que tienen las mismas velocidades se hace por orden alfabetico.
SELECT name AS Roads, avg(speed_limit) FROM ROADS 
GROUP BY speed_limit, name ORDER BY speed_limit DESC, name ASC;
--Tercera consulta:Personas que no conducen ninguno de sus vehiculos (ni como conductor habitual
--ni como conductor adicional).
--Dueños que no son conductores habituales de sus vehiculos INTERSECCIÓN CON Dueños que no son conductores adicionales de sus vehiculos
SELECT owner FROM (
(SELECT owner FROM VEHICLES A
WHERE A.owner NOT IN (SELECT B.reg_driver FROM VEHICLES B
WHERE A.nPlate= B.nPlate))
INTERSECT (SELECT owner FROM VEHICLES C
WHERE C.owner NOT IN (SELECT D.driver FROM ASSIGNMENTS D
WHERE C.nPlate= D.nPlate))
)GROUP BY owner;
--Cuarta consulta: (Jefazo)dueños de al menos tres coches que no son conductores. 
--Igual que la anterior pero tienen que ser con al menos 3 coches.
SELECT owner AS Boss FROM VEHICLES A 
WHERE A.owner NOT IN (SELECT DNI FROM DRIVERS B
WHERE B.DNI= A.owner)
GROUP BY owner HAVING COUNT(nPlate)>=3;

--Quinta consulta:(Evolucion) indica la diferencia de ingresos por multas entre el mes pasado y el
--mismo mes del año anterior.
 --Primero, los ingresos por multas del mes pasado del año anterior
 SELECT amount FROM TICKETS
 WHERE SUBSTR(sent_date, 1, 8)=
 --Le resto 1 al mes
 SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 4, 6)-1
  --Le resto 1 al año
 SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)-1
 --La fecha coincida con el mes pasado del año anterior
 WHERE SUBSTR(sent_date, 1, 8)= SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)-1 AND
 SUBSTR(sent_date, 4, 6)=SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 4, 6)-1
  --La fecha coincida con el mes pasado de este año
  WHERE SUBSTR(sent_date, 1, 8)= SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)
  AND
 SUBSTR(sent_date, 4, 6)=SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 4, 6)-1




























   