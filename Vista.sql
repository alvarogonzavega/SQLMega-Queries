--Vista: c) Tramos: tabla que registra cada tramo de carretera en el que la velocidad es inferior
--a la velocidad general de la vía (contiene la identificación de la vía, puntos de inicio
--y fin, y límite de velocidad en el tramo).


--Primero voy a crear una funcion para la vista para simplificar el problema.
CREATE OR REPLACE FUNCTION calculalongitudvia(road VARCHAR2(5), Km_point NUMBER(3,0), direction VARCHAR2(3)) RETURN NUMBER IS
 longitudvia NUMBER;
BEGIN
--Asumimos que el punto final es max de las km_point del ultimo radar + 5


RETURN (longitudvia);
END;


CREATE VIEW tramos AS (
SELECT name FROM ROADS
SELECT Km_point FROM RADARS



);


 
CREATE VIEW contratos AS (
SELECT referencia, fechafirma, COUNT('X') num_claúsulas
FROM contratos_ALL NATURAL JOIN clausulas_ALL
GROUP BY (referencia, fechafirma)
);










