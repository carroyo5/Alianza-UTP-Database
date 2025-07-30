
CREATE OR REPLACE FUNCTION fn_delete_activity(
	p_activity_id integer,
	p_user_id integer)
    RETURNS TABLE(success boolean, message text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
  v_activity_status_id INT;
  rows_affected INT;
  enrolled_users INT;
  activity_name TEXT;
BEGIN
/*
Procedimiento para cancelar una actividad de grupo, validando que el usuario sea administrador 
o dueño del grupo al que pertenece la actividad. Si la actividad no ha sido cancelada previamente, 
se actualiza su estado y se notifica a los usuarios inscritos.
*/
  -- Verificar que el usuario es admin o dueño del grupo Y que la actividad pertenece al grupo
  IF EXISTS (
     SELECT 1 FROM groups g
    LEFT JOIN groupmembers gm ON g.group_id = gm.group_id AND gm.gm_role_id IN (2, 3)
    JOIN groupactivities ga ON ga.ga_group_id = g.group_id
    WHERE (gm.user_id = p_user_id OR g.g_group_owner_id = p_user_id)
     AND ga.activity_id = p_activity_id
  ) THEN
    BEGIN
      -- Obtener el ID del estado "Cancelada"
      SELECT activity_status_id 
      INTO v_activity_status_id 
      FROM activitystatus
      WHERE as_activity_status_name = 'Cancelada';

      -- Verificar si ya está cancelada
      IF EXISTS (
        SELECT 1 
        FROM groupactivities 
        WHERE activity_id = p_activity_id 
          AND ga_activity_status = v_activity_status_id
      ) THEN
        RETURN QUERY SELECT TRUE, 'La actividad ya se encuentra cancelada.';
		RETURN;
      END IF;

      -- Actualizar estado a cancelado
      UPDATE groupactivities
      SET ga_activity_status = v_activity_status_id
      WHERE activity_id = p_activity_id;

	  GET DIAGNOSTICS rows_affected = ROW_COUNT;
	  IF rows_affected > 0 THEN
		  -- Obtener el nombre de la actividad
		  SELECT ga_activity_name INTO activity_name 
		  FROM groupactivities 
		  WHERE activity_id = p_activity_id;
		  
		  -- Enviar notificación a cada usuario inscrito
		  FOR enrolled_users IN SELECT ap_user_id 
		  FROM activityparticipants
          WHERE ap_activity_id = p_activity_id
		  LOOP
		  	PERFORM(fn_sys_generate_notifications(enrolled_users, 'Te notificamos que la actividad "' || activity_name || '" ha sido cancelada. Lamentamos los inconvenientes y agradecemos tu comprensión.'));
		  END LOOP;
	  RETURN QUERY SELECT TRUE, 'Actividad cancelada exitosamente.';
	  RETURN;
	  END IF;
    EXCEPTION WHEN OTHERS THEN
      RETURN QUERY SELECT FALSE, 'Ha ocurrido un error al cancelar la actividad ' ||SQLERRM;
	  RETURN;
    END;
  ELSE
    RETURN QUERY SELECT FALSE, 'Usuario no autorizado o actividad no existe.';
	RETURN;
  END IF;
END;
$BODY$;