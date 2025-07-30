CREATE OR REPLACE FUNCTION fn_adm_activity_enrollment_stats(
	p_club_id integer)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
/*
Este procedimiento almacenado devuelve la cantidad de personas inscritas en un grupo, agrupadas por fecha.
*/
    RETURN (
			WITH data AS(
		SELECT CAST(ap.ap_registration_date AS DATE) AS date,
					COUNT(ap.ap_user_id) AS enrollments FROM groupactivities ga
		 	INNER JOIN activityparticipants AS ap ON ap.ap_activity_id = ga.activity_id
			WHERE ga.ga_group_id = p_club_id
			GROUP BY ap.ap_registration_date)
		
		SELECT jsonb_agg(json_build_object('date', date, 'enrollments', enrollments)) FROM data);
END;
$BODY$;