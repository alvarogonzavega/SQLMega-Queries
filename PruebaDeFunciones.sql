--Probar que compila correctamente funcion a funcion.

--Primera Funcion
CREATE OR REPLACE FUNCTION cuantia_sancionvelmaxradar (speed NUMBER,speedlim NUMBER)
 RETURN NUMBER IS
	cuantia_velmax NUMBER(5);	
 BEGIN
 
	IF (speed> speedlim)THEN
		cuantia_velmax:= 10* (speed-speedlim);
		return (cuantia_velmax);
	END IF;	
END;
/
 --Vamos a usar este ejemplo para ver que funciona correctamente
SELECT cuantia_sancionvelmaxradar(123, 120) FROM dual;
--SOLUCION: 30
---------------------------------------------------------------------------------------------------------------
--Cuarta funcion
CREATE OR REPLACE FUNCTION obs_inm_ant_radar(matricula VARCHAR2, tiempo TIMESTAMP,carretera VARCHAR2, Punto_Km NUMBER, direccion VARCHAR2)
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
 GROUP BY nPlate, odatetime, road, km_point, direction, speed  ORDER BY odatetime DESC)
 --De esta manera cojo solo un tiempo, del inmediatamente anterior
 WHERE ROWNUM<2;
 return (time_obs_inm_ant_radar);
  END;
  /
--Para probar funciones a las que se les pasa por parametro una rowtype, hay que declarar una variable de este tipo y
-- llamarla dentro de un procedimiento no nominado.
SET SERVEROUTPUT ON
--Hay que darle a ENTER y aparte en otra linea
DECLARE 
var1 OBSERVATIONS%ROWTYPE;
BEGIN
var1 := obs_inm_ant_radar ('4760AEE' , TO_TIMESTAMP('2009-08-24'||'00:34:17.60','YYYY-MM-DDHH24:MI:SS.FF2'),'M50', 15, 'ASC');
DBMS_OUTPUT.PUT_LINE ('nPlate:'||var1.nPlate||' '||'time:'||var1.odatetime||' '||'road:'||var1.road||' '||
'Km:'||var1.km_point||' '||'Dir:'||var1.direction||' '||'Speed:'||var1.speed);
END;
/
-----------------------------------------------------------------------------------------------------------------------
--Implementacion quinta funcion
CREATE OR REPLACE FUNCTION obs_inm_ant_vehiculo( matricula_vh VARCHAR2, tempo TIMESTAMP)
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
  /
  
--Para probar la funcion  
  SET SERVEROUTPUT ON
--Hay que darle a ENTER y aparte en otra linea
DECLARE 
  var2 OBSERVATIONS%ROWTYPE;
BEGIN
var2 := obs_inm_ant_vehiculo ('4760AEE' , TO_TIMESTAMP('2009-08-24'||'00:34:17.60','YYYY-MM-DDHH24:MI:SS.FF2'));
DBMS_OUTPUT.PUT_LINE ('nPlate:'||var2.nPlate||' '||'time:'||var2.odatetime||' '||'road:'||var2.road||' '||
'Km:'||var2.km_point||' '||'Dir:'||var2.direction||' '||'Speed:'||var2.speed);
END;
/
-------------------------------------------------------------------------------------------------------------------------------
--Implementacion segunda funcion
--Sancion para un vehiculo que pasa por un tramo de la misma carretera y en el mismo sentido.
CREATE OR REPLACE FUNCTION cuantia_sancion_vel_tramo (matricula_vh VARCHAR2, tiempo TIMESTAMP)
 RETURN NUMBER IS
--Declaramos una variable donde vamos a almacenar el resultado
	cuantia_vel_tramo NUMBER(5);
--variables que almacenan
	carretera VARCHAR2(5);
	punto_km_inicial NUMBER(3,0);
	sentido VARCHAR2(3);
	vel_punto_final NUMBER(3,0);
--variables que almacenan despues de hacer calculos	
	lim_radar NUMBER(3,0);
	punto_km_final NUMBER(3,0);
	distancia_tramo NUMBER(3,0);
--tiempo correcto que tiene que tardar para que no reciba sancion	
	tiempo_correcto  NUMBER(3,0);
	tiempo_punto_km_inicial TIMESTAMP;
	segundos_odatetime NUMBER(3,0);
	segundos_tiempo NUMBER(3,0);
--tiempo que hace el vehiculo	
	tiempo_vehiculo  NUMBER(3,0);
	vel_punto_inicial NUMBER(3,0);
	
	
 BEGIN
--Sacamos varios datos de la observacion introducida por parametro y los guardamos en cada variable declarada
	SELECT road INTO carretera FROM OBSERVATIONS WHERE matricula_vh=nPlate AND tiempo=odatetime; 
	SELECT Km_point INTO punto_km_final FROM OBSERVATIONS WHERE matricula_vh=nPlate AND tiempo=odatetime; 
	SELECT direction INTO sentido FROM OBSERVATIONS WHERE matricula_vh=nPlate AND tiempo=odatetime; 
	SELECT speed INTO vel_punto_final FROM OBSERVATIONS WHERE matricula_vh=nPlate AND tiempo=odatetime; 
--Buscamos que radar hay en ese punto kilometrico y quedarnos con la velocidad del radar
	SELECT speedlim INTO lim_radar FROM RADARS WHERE carretera=road AND punto_km_inicial=Km_point AND sentido=direction; 

--Necesitamos el punto kilometrico del radar anterior del pasado por parametro
	SELECT Km_point INTO punto_km_inicial FROM (SELECT road, Km_point, direction FROM RADARS
	WHERE carretera=road AND sentido=direction AND punto_km_inicial>Km_point
	--ordenado de mayor a menor, para coger el radar justo antes
	GROUP BY Km_point ORDER BY Km_point DESC)
	WHERE ROWNUM<2;

	--Calculamos la distancia entre los dos radares, hacemos valor absoluto para ahorrarnos los dos tipos de sentidos
	distancia_tramo:= ABS(Punto_km_final - Punto_km_inicial);
	--Los tramos de velocidad miden 5 en general como maximo o si son menores de 5, la distancia hasta el siguiente radar.
	--Si sale mayor que 5 significa que entre los dos radares tambien tenemos parte de tramo regulado por la velocidad de la carretera.
	IF (distancia_tramo>5)THEN
	distancia_tramo:=5;
	END IF;
	tiempo_correcto:=(distancia_tramo/lim_radar)*3600;
	--Vamos a sacar el tiempo de la observacion inmediatamente anterior.

	SELECT * INTO tiempo_punto_km_inicial FROM (SELECT odatetime FROM OBSERVATIONS
 --observaciones del mismo vehiculo
	WHERE matricula_vh=nPlate
 --todos los tiempos anteriores al tiempo de la observacion pasada por parametro
	AND tiempo>odatetime
 --si hago DESC, es decir, ordenadas de mayor a menor, las fechas mas recientes arriba
	GROUP BY odatetime ORDER BY odatetime DESC)
 --De esta manera cojo solo un tiempo, del inmediatamente anterior
	WHERE ROWNUM<2;
 --Extraemos los segundos y calculamos la diferencia en segundos
	SELECT extract(second from tiempo_punto_km_inicial) INTO segundos_odatetime from dual;
	SELECT extract(second from tiempo) INTO segundos_tiempo from dual;
	tiempo_vehiculo:=ABS(segundos_odatetime - segundos_tiempo);

	--Si tiempo_correcto>tiempo_vehiculo, se produce sancion
	IF (tiempo_correcto>tiempo_vehiculo) THEN
	--Calculamos la velocidad media
	vel_punto_inicial:=(distancia_tramo/tiempo_vehiculo)*3600;
	cuantia_vel_tramo:= 10* (vel_punto_final - vel_punto_inicial);
	return (cuantia_vel_tramo);
	ELSE
	--No se produce sancion
	cuantia_vel_tramo:=0;
	return (cuantia_vel_tramo);
	END IF;
END;	
 --Una vez compilada vamos a probarla
 --Mostramos observaciones del mismo vehiculo mismo radar
 SELECT odatetime, nPlate, road, km_point, direction FROM OBSERVATIONS
 WHERE odatetime<'17/07/11 04:22:27,820000' AND nPlate='8960AEO' AND road='A1' AND km_point<242 AND direction='ASC'
 GROUP BY odatetime, nPlate, road, km_point, direction ORDER BY odatetime DESC;
 --salen 10 filas
SELECT cuantia_sancion_vel_tramo('8960AEO', '04/06/09 04:25:26,580000') FROM dual;
--SOLUCION: 

  