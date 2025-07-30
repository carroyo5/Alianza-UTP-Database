CREATE OR REPLACE FUNCTION fn_get_user_related_activities(
	p_user_id integer)
    RETURNS TABLE(activity_id integer, activity_name character varying, activity_description text, max_participant integer, activity_type character varying, activity_status character varying, group_id integer, creator_name text, participants bigint, activity_datetime text, activity_location character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	BEGIN
	    RETURN QUERY
			SELECT 
			    ga.activity_id,
			    ga.ga_activity_name,
			    ga.ga_activity_description,
			    ga.ga_max_participants,
			    att.at_activity_type_name,
			    acst.as_activity_status_name,
			    g.group_id,
			    CONCAT(u.u_name, ' ', u.u_last_name) AS creator_name,
			    (
			        SELECT COUNT(*)
			        FROM activityparticipants ap1
			        WHERE ap1.ap_activity_id = ga.activity_id
			          AND ap1.attendance_status = TRUE
			    ) AS participants_count,
			    TO_CHAR(asch.as_activity_start_date AT TIME ZONE 'America/Bogota', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS activity_datetime,
			    asch.as_activity_location
			FROM 
			    groupactivities ga
			    JOIN groups g ON g.group_id = ga.ga_group_id
			    JOIN activitytypes att ON att.activity_type_id = ga.ga_activity_type
			    JOIN activitystatus acst ON acst.activity_status_id = ga.ga_activity_status
			    JOIN users u ON u.user_id = ga.ga_creator_id
			    JOIN activitiesschedule asch ON asch.as_activity_id = ga.activity_id
			WHERE EXISTS (
			    SELECT 1
			    FROM activityparticipants ap
			    WHERE ap.ap_activity_id = ga.activity_id
			      AND ap.ap_user_id = p_user_id
			      AND ap.attendance_status = TRUE
			)
			ORDER BY asch.as_activity_start_date ASC;
	END;
$BODY$;
