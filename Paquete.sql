

--Descripcion del paquete, declaracion de las funciones
CREATE OR REPLACE PACKAGE mi_paquete IS
--- Primera Funcion: Cuantia para una sancion de velocidad maxima de radar.
	FUNCTION cuantia_sancionvelmaxradar(speed NUMBER(3), speedlim NUMBER(3,0)) RETURN NUMBER;
--Cuarta Funcion: Observacion inmediatamente anterior a otra observacion (del mismo radar)
	FUNCTION obs_inm_ant_radar(matricula VARCHAR2(7), tiempo TIMESTAMP,carretera VARCHAR2(5), Punto_Km NUMBER(3), direccion VARCHAR2(3))
 RETURN OBSERVATIONS%ROWTYPE;
--Quinta Funcion: Observacion inmediatamente anterior a otra observacion (del mismo vehiculo)
	FUNCTION obs_inm_ant_vehiculo( matricula_vh VARCHAR2(7), tempo TIMESTAMP)
 RETURN OBSERVATIONS%ROWTYPE;
	--- Segunda Funcion: Cuantia para una sancion de velocidad de tramo.
	FUNCTION cuantia_sancionveltramo() RETURN NUMBER;
	--Tercera Funcion: Cuantia para una sancion de distancia
	FUNCTION cuantia_sanciondistancia(tik_type VARCHAR2) RETURN NUMBER;

END mi_paquete;

--Cuerpo del paquete, implementaciones de cada funcion  
CREATE OR REPLACE PACKAGE BODY mi_paquete IS

--Implementacion primera funcion
FUNCTION cuantia_sancionvelmaxradar (speed NUMBER,speedlim NUMBER)
 RETURN NUMBER IS
--Declaramos una variable donde vamos a almacenar el resultado
	cuantia_velmax NUMBER(5);	
 BEGIN
 
	IF (speed> speedlim)THEN
		cuantia_velmax:= 10* (speed-speedlim);
		return (cuantia_velmax);
	END IF;	
END;
--Hacemos primero estas funciones,ya que, las vamos a usar para la funcion 2.
---------------------------------------------------------------------------------------------------------------------
--Implementacion cuarta funcion
FUNCTION obs_inm_ant_radar(matricula VARCHAR2, tiempo TIMESTAMP,carretera VARCHAR2, Punto_Km NUMBER, direccion VARCHAR2)
 RETURN OBSERVATIONS%ROWTYPE IS
 time_obs_inm_ant_radar OBSERVATIONS%ROWTYPE;
   
 BEGIN
   SELECT * INTO time_obs_inm_ant_radar FROM (SELECT  nPlate, odatetime, road, km_point, direction, speed 
 FROM OBSERVATIONS 
 --observaciones del mismo radar
 WHERE carretera=road AND Punto_Km=Km_point AND direccion=direction
 --todos los tiempos anteriores al tiempo de la observacion pasada por parametro
 AND tiempo>odatetime
 --si hago DESC, es decir, ordenadas de mayor a menor, las fechas mas recientes arriba
 GROUP BY nPlate, odatetime, road, km_point, direction, speed ORDER BY odatetime DESC)
 --De esta manera cojo solo un tiempo, del inmediatamente anterior
 WHERE ROWNUM<2;
 return (time_obs_inm_ant_radar);
  END;
------------------------------------------------------------------------------------------------------------------ 
--Implementacion quinta funcion
FUNCTION obs_inm_ant_vehiculo( matricula_vh VARCHAR2, tempo TIMESTAMP)
 RETURN OBSERVATIONS%ROWTYPE IS
 time_obs_inm_ant_vehiculo OBSERVATIONS%ROWTYPE;
   
 BEGIN
 
 --Se recoge el resultado de la consulta en una variable declarada.
 SELECT * INTO time_obs_inm_ant_vehiculo FROM (SELECT nPlate, odatetime, road, km_point, direction, speed
 FROM OBSERVATIONS
 --observaciones del mismo vehiculo
 WHERE matricula_vh=nPlate
 --todos los tiempos anteriores al tiempo de la observacion pasada por parametro
 AND tempo>odatetime
 --si hago DESC, es decir, ordenadas de mayor a menor, las fechas mas recientes arriba
 GROUP BY nPlate, odatetime, road, km_point, direction, speed ORDER BY odatetime DESC)
 --De esta manera cojo solo un tiempo, del inmediatamente anterior
 WHERE ROWNUM<2;
 return (time_obs_inm_ant_vehiculo);
  END;
 --------------------------------------------------------------------------------------------------------
 --- Segunda Funcion: Cuantia para una sancion de velocidad de tramo.

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 --Implementacion tercera funcion
  FUNCTION cuantia_sanciondistancia(tik_type VARCHAR2)
 RETURN NUMBER 
 IS
   amount NUMBER;
 BEGIN
SELECT amount FROM TICKETS 
WHERE tik_type='D';
return (amount);
 END;
 ---------------------------------------------------------------------------------------------------------------------------------------

 
END mi_paquete;



