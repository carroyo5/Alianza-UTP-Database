CREATE OR REPLACE FUNCTION fn_get_activities_by_club_admin(
	p_club_id integer)
    RETURNS TABLE(activity_id integer, activity_name character varying, activity_description text, max_participants integer, schedule json, location character varying, articipants_count bigint, activity_type_name character varying, activity_status_name character varying, group_name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
/*
Consulta actividades de un grupo, con horarios, ubicación, tipo, estado y número de participantes asistidos o que asistirán.
*/
  RETURN QUERY
  SELECT 
    a.activity_id,
    a.ga_activity_name,
    a.ga_activity_description,
    a.ga_max_participants,
    json_agg(
        json_build_object(
            'start_date', s.as_activity_start_date,
            'end_date', s.as_activity_end_date
        )
    ) AS schedule,
    s.as_activity_location AS location,
    (SELECT COUNT(*) 
     FROM activityparticipants ap 
     WHERE ap.ap_activity_id = a.activity_id
	 AND ap.attendance_status = TRUE) AS participants_count,
    t.at_activity_type_name,
    st.as_activity_status_name,
    g.g_group_name
	FROM groupactivities a
	JOIN activitiesschedule s ON s.as_activity_id = a.activity_id
	JOIN activitytypes t ON t.activity_type_id = a.ga_activity_type
	JOIN activitystatus st ON st.activity_status_id = a.ga_activity_status
	JOIN groups g ON g.group_id = a.ga_group_id
	WHERE g.group_id = p_club_id
	GROUP BY 
	    a.activity_id,
	    a.ga_activity_name,
	    a.ga_activity_description,
	    a.ga_max_participants,
	    s.as_activity_location,
	    t.at_activity_type_name,
	    st.as_activity_status_name,
	    g.g_group_name;
END;
$BODY$;