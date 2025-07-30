CREATE OR REPLACE FUNCTION fn_get_activity_by_id(
	p_activity_id integer)
    RETURNS TABLE(activity_id integer, activity_name character varying, activity_description text, max_participants integer, creator_name text, activity_datetime json, location character varying, participants_count bigint, activity_type_name character varying, activity_status_name character varying, group_name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
/*
Consulta los detalles de una actividad específica si está programada o completada, 
incluyendo información general, creador, fechas, ubicación, tipo, estado, grupo y participantes con asistencia.
*/

  RETURN QUERY
  SELECT 
    a.activity_id,
    a.ga_activity_name,
    a.ga_activity_description,
    a.ga_max_participants,
    CONCAT(u.u_name, ' ', u.u_last_name) AS creator_name,
    json_agg(
      json_build_object(
        'start_date', s.as_activity_start_date,
        'end_date', s.as_activity_end_date
      )
    ) AS activity_datetime,
    s.as_activity_location AS location,
    (SELECT COUNT(*) 
	FROM activityparticipants ap 
	WHERE ap.ap_activity_id = a.activity_id 
	AND attendance_status =TRUE) AS participants_count,
    t.at_activity_type_name,
    st.as_activity_status_name,
    g.g_group_name
  FROM groupactivities a
  JOIN users u ON u.user_id = a.ga_creator_id
  JOIN activitiesschedule s ON s.as_activity_id = a.activity_id
  JOIN activitytypes t ON t.activity_type_id = a.ga_activity_type
  JOIN activitystatus st ON st.activity_status_id = a.ga_activity_status
  JOIN groups g ON g.group_id = a.ga_group_id
  WHERE a.activity_id = p_activity_id
  AND activity_status_id IN (1,2) -- (Programada, Completada)
  GROUP BY 
    a.activity_id,
    a.ga_activity_name,
    a.ga_activity_description,
    a.ga_max_participants,
    u.u_name, u.u_last_name,
    s.as_activity_location,
    t.at_activity_type_name,
    st.as_activity_status_name,
    g.g_group_name;
END;
$BODY$;