CREATE OR REPLACE FUNCTION fn_sys_notify_activity_cancelled()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
	DECLARE
	payload TEXT;
	user_data JSON;
	BEGIN
		  -- Validar si el nuevo estado es "Cancelada"
	IF NEW.ga_activity_status = (SELECT activity_status_id FROM activitystatus WHERE as_activity_status_name = 'Cancelada')
	   AND OLD.ga_activity_status IS DISTINCT FROM NEW.ga_activity_status THEN

    -- Obtener la informacion para el correo de los usuarios inscritos
    SELECT json_agg(json_build_object('email', u_email, 'name', u_name)) INTO user_data 
    FROM activityparticipants ap
		INNER JOIN users u ON ap.ap_user_id = u.user_id
    WHERE ap_activity_id = NEW.activity_id
	AND u.u_user_status_id = 1 AND ap.attendance_status = TRUE;

    -- Crear payload con la información relevante
    payload := json_build_object(
	  'event', 'activity_cancelled',
      'activity_id', NEW.activity_id,
      'activity_name', NEW.ga_activity_name,
      'user_data', user_data
    )::TEXT;

    -- Enviar notificación al canal
    PERFORM pg_notify('database_events', payload);
  END IF;

  RETURN NEW;
END;
$BODY$;