CREATE OR REPLACE FUNCTION fn_adm_weekly_activity_heatmap(
	p_club_id integer)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
  result JSON;
BEGIN
/*
Genera información estructurada en formato JSON para construir un mapa de calor en el frontend, 
mostrando la cantidad de actividades por día de la semana y hora, según el grupo especificado.
*/
  WITH activity_counts AS (
    SELECT 
      EXTRACT(DOW FROM ga_activity_created_date)::INT AS day_of_week,
      EXTRACT(HOUR FROM ga_activity_created_date)::INT AS hour,
      COUNT(DISTINCT activity_id) AS activity_count
    FROM groupactivities
    WHERE ga_group_id = p_club_id
    GROUP BY day_of_week, hour
    ORDER BY day_of_week, hour
  )
  SELECT json_agg(
    json_build_object(
      'day_of_week', day_of_week,
      'hour', hour,
      'activity_count', activity_count
    )
  )
  INTO result
  FROM activity_counts;

  RETURN result;
END;
$BODY$;