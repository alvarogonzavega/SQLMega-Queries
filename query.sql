--IMPLEMENTACION SQL DE LAS CONSULTAS--
--POR SOFIA NAJARRO ALMARAZ, ALVARO GONZALEZ DE LA VEGA & JAIME DE ESTEBAN DE URANGA-- 
------------------------------------------
-- Primera consulta: Los 10 vehiculos mas 'observados' en el transcurso del dia de hoy.
SELECT * FROM (
SELECT DISTINCT nPlate AS top_observed_vehicles FROM OBSERVATIONS
WHERE SUBSTR(odatetime, 1, 8)=SUBSTR((TO_TIMESTAMP(SYSDATE,'YYYY-MM-DDHH24:MI:SS.FF2')), 1, 8)
GROUP BY nPlate ORDER BY COUNT(nPlate) DESC)
WHERE ROWNUM<11;
-- Segunda consulta: Listado de carreteras y su valor de velocidad promedio establecida, 
--ordenado de mayor a menor velocidad en primera instancia y por orden alfabético 
--de carreteras en segunda, contando ambos sentidos.
SELECT name AS Roads, speed_limit FROM ROADS 
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
SELECT owner AS Boss FROM (
(SELECT owner FROM VEHICLES A
WHERE A.owner NOT IN (SELECT B.reg_driver FROM VEHICLES B
WHERE A.nPlate= B.nPlate)GROUP BY owner HAVING COUNT(nPlate)>=3)
INTERSECT (SELECT owner FROM VEHICLES C
WHERE C.owner NOT IN (SELECT D.driver FROM ASSIGNMENTS D
WHERE C.nPlate= D.nPlate)GROUP BY owner HAVING COUNT(nPlate)>=3)
)GROUP BY owner;
--Quinta consulta:(Evolucion) indica la diferencia de ingresos por multas entre el mes pasado y el
--mismo mes del año anterior.






