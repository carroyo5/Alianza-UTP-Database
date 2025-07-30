CREATE OR REPLACE FUNCTION fn_user_upcoming_events(
	p_user_id integer)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE v_result JSON;
	BEGIN
		SELECT json_agg(json_build_object('activity_name', sub.ga_activity_name, 
		'activity_datetime',(SELECT fn_sys_generate_datetime_spanish_context(sub.as_activity_start_date::TIMESTAMP))
		)) INTO v_result
		FROM (SELECT * FROM groupactivities AS ga
			JOIN activityparticipants AS ap ON ap.ap_activity_id = ga.activity_id
			JOIN activitiesschedule AS asch ON asch.as_activity_id = ga.activity_id
			WHERE ap.attendance_status = TRUE
			AND ap.ap_user_id =  p_user_id
			ORDER BY as_activity_start_date ASC
			LIMIT 5) AS sub;

		RETURN v_result;
	END;
$BODY$;