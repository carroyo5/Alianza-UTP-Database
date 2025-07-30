CREATE OR REPLACE FUNCTION fn_join_activity(
	p_activity_id integer,
	p_user_id integer)
    RETURNS TABLE(success boolean, message text, data json) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  max_participants INT;
  current_participants INT;
  activity_status INT;
  already_enrolled BOOLEAN;
  activity_name TEXT;
  result_data JSON;
BEGIN
  -- Verificar si la actividad existe y está activa
  SELECT ga_activity_status, ga_activity_name
  INTO activity_status, activity_name
  FROM groupactivities
  WHERE activity_id = p_activity_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'La actividad no existe.', '{}'::json;
    RETURN;
  END IF;

  IF activity_status != 1 THEN
    RETURN QUERY SELECT FALSE, 'La actividad no está disponible para inscripción.', '{}'::json;
    RETURN;
  END IF;

  -- Verificar si el usuario ya está inscrito
  SELECT EXISTS(
    SELECT 1 FROM activityparticipants 
    WHERE ap_activity_id = p_activity_id AND ap_user_id = p_user_id
	AND attendance_status = TRUE
  ) INTO already_enrolled;

  IF already_enrolled THEN
    RETURN QUERY SELECT FALSE, 'Ya estás inscrito en esta actividad.', '{}'::json;
    RETURN;
  END IF;

  -- Verificar límite de participantes
  SELECT a.ga_max_participants,
         (SELECT COUNT(*) FROM activityparticipants WHERE ap_activity_id = p_activity_id)
  INTO max_participants, current_participants
  FROM groupactivities a
  WHERE a.activity_id = p_activity_id;

  IF current_participants >= max_participants THEN
    RETURN QUERY SELECT FALSE, 'La actividad ya alcanzó el número máximo de participantes.', '{}'::json;
    RETURN;
  END IF;

  IF EXISTS (SELECT 1 FROM activityparticipants WHERE ap_activity_id = p_activity_id AND ap_user_id = p_user_id)
  THEN
 	  --Si ya hay un registro existente no se inserta, se actualiza el que ya esta
	  UPDATE activityparticipants
	  SET attendance_status = TRUE,
	      ap_registration_date = NOW() AT TIME ZONE 'America/Bogota'  --Se actualiza de nuevo la fecha
	  WHERE ap_activity_id = p_activity_id 
	  AND ap_user_id = p_user_id;
	ELSE
	  -- Insertar en activityparticipants
	  INSERT INTO activityparticipants(ap_activity_id, ap_user_id, ap_registration_date)
	  VALUES (p_activity_id, p_user_id, NOW() AT TIME ZONE 'America/Bogota');
	END IF;
	  
  -- Enviar notificación
  PERFORM fn_sys_generate_notifications(
    p_user_id,
    'Te has inscrito exitosamente en la actividad "' || activity_name || '". ¡Nos vemos pronto!'
  );

  -- Construir JSON con los datos de la actividad
  SELECT json_build_object(
    'user_name', u.u_name,
	'email', u_email,
    'activity_name', ga.ga_activity_name,
    'activity_description', ga.ga_activity_description,
    'activity_time', fn_sys_generate_datetime_spanish_context(asch.as_activity_start_date::TIMESTAMP),
    'location', asch.as_activity_location
  )
  INTO result_data
  FROM users u
  JOIN groupactivities ga ON ga.activity_id = p_activity_id
  JOIN activitiesschedule asch ON asch.as_activity_id = p_activity_id
  WHERE u.user_id = p_user_id
  LIMIT 1;

  RETURN QUERY SELECT TRUE, 'Te has inscrito correctamente.', result_data;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Ocurrió un error al inscribirte: ' || SQLERRM, '{}'::json;
    RETURN;
END;
$BODY$;