CREATE OR REPLACE FUNCTION fn_leave_activity(
	p_activity_id integer,
	p_user_id integer)
    RETURNS TABLE(success boolean, message text, data json) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  already_enrolled BOOLEAN;
  activity_name TEXT;
  affected_rows INT;
  result_data JSON;
BEGIN
  -- Verificar si el usuario está inscrito en la actividad
  SELECT EXISTS(
    SELECT 1 FROM activityparticipants 
    WHERE ap_activity_id = p_activity_id AND ap_user_id = p_user_id
	AND attendance_status = TRUE
  ) INTO already_enrolled;

  IF NOT already_enrolled THEN
    RETURN QUERY SELECT FALSE, 'No estás inscrito en esta actividad.', '{}'::json;
    RETURN;
  END IF;
  	
  -- Eliminar la inscripción
  UPDATE activityparticipants
  SET attendance_status = FALSE
  WHERE ap_activity_id = p_activity_id AND ap_user_id = p_user_id;

  GET DIAGNOSTICS affected_rows = ROW_COUNT;

  IF affected_rows = 0 THEN
    RETURN QUERY SELECT FALSE, 'No se pudo eliminar la inscripción.', '{}'::json;
    RETURN;
  END IF;

  -- Obtener nombre de la actividad para notificación
  SELECT ga_activity_name INTO activity_name
  FROM groupactivities
  WHERE activity_id = p_activity_id;

  -- Enviar notificación
  PERFORM fn_sys_generate_notifications(
    p_user_id,
    'Has cancelado tu inscripción en la actividad "' || activity_name || '".'
  );

  -- Construir JSON con datos de la actividad
  SELECT json_build_object(
    'user_name', u.u_name,
    'email', u.u_email,
    'activity_name', ga.ga_activity_name
  )
  INTO result_data
  FROM users u
  JOIN groupactivities ga ON ga.activity_id = p_activity_id
  JOIN activitiesschedule asch ON asch.as_activity_id = p_activity_id
  WHERE u.user_id = p_user_id
  LIMIT 1;

  RETURN QUERY SELECT TRUE, 'Has salido correctamente de la actividad.', result_data;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Ocurrió un error al cancelar la inscripción: ' || SQLERRM, '{}'::json;
    RETURN;
END;
$BODY$;