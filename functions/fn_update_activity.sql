CREATE OR REPLACE FUNCTION fn_update_activity(
	p_activity_id integer,
	p_updater_id integer,
	p_name text,
	p_description text,
	p_max_participants integer,
	p_activity_type text,
	p_activity_start_datetime timestamp without time zone,
	p_activity_end_datetime timestamp without time zone,
	p_location text)
    RETURNS TABLE(success boolean, message text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_activity_type_id INT;
    v_existing_activity RECORD;
    v_now TIMESTAMP;
    v_user RECORD;
    v_group_name TEXT;
    v_enrolled INT;
	p_group_id INT;
BEGIN
    v_now := NOW() AT TIME ZONE 'America/Bogota';

	SELECT ga_group_id 
	INTO p_group_id 
	FROM groupactivities 
	WHERE activity_id = p_activity_id LIMIT 1;

    -- Validar permisos (dueño o admin del grupo)
    IF NOT EXISTS (
        SELECT 1 FROM groups g
        LEFT JOIN groupmembers gm ON g.group_id = gm.group_id AND gm.gm_role_id IN (2, 3)
        WHERE g.group_id = p_group_id
        AND (gm.user_id = p_updater_id OR g.g_group_owner_id = p_updater_id)
    ) THEN
        RETURN QUERY SELECT FALSE, 'Usuario no autorizado o grupo no válido.';
        RETURN;
    END IF;

    -- Validar fechas en el pasado
    IF p_activity_start_datetime < v_now OR p_activity_end_datetime < v_now THEN
        RETURN QUERY SELECT FALSE, 'Las fechas no pueden ser anteriores al momento actual.';
        RETURN;
    END IF;

    -- Obtener datos actuales de la actividad
    SELECT ga.activity_id, asch.as_activity_start_date, asch.as_activity_end_date
    INTO v_existing_activity
    FROM groupactivities ga
    JOIN activitiesschedule asch ON asch.as_activity_id = ga.activity_id
    WHERE ga.activity_id = p_activity_id;

    -- Validar que la actividad no haya iniciado
    IF v_existing_activity.as_activity_start_date <= v_now THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar una actividad que ya inició o finalizó.';
        RETURN;
    END IF;

    -- Validar máximo de participantes
    IF p_max_participants IS NOT NULL THEN
        SELECT COUNT(*) INTO v_enrolled
        FROM activityparticipants
        WHERE ap_activity_id = p_activity_id
          AND attendance_status = TRUE;

        IF p_max_participants < v_enrolled THEN
            RETURN QUERY SELECT FALSE, 'La cantidad máxima no puede ser menor que los inscritos.';
            RETURN;
        END IF;
    END IF;

    -- Validar tipo de actividad
    SELECT activity_type_id
    INTO v_activity_type_id
    FROM activitytypes 
    WHERE LOWER(at_activity_type_name) = LOWER(p_activity_type);

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Tipo de actividad no válido.';
        RETURN;
    END IF;

    -- Actualizar actividad
    UPDATE groupactivities
    SET 
        ga_activity_name = COALESCE(p_name, ga_activity_name),
        ga_activity_description = COALESCE(p_description, ga_activity_description),
        ga_max_participants = COALESCE(p_max_participants, ga_max_participants),
        ga_activity_type = COALESCE(v_activity_type_id, ga_activity_type)
    WHERE activity_id = p_activity_id;

    -- Actualizar horario
    UPDATE activitiesschedule
    SET 
        as_activity_start_date = COALESCE(p_activity_start_datetime, as_activity_start_date),
        as_activity_end_date = COALESCE(p_activity_end_datetime, as_activity_end_date),
        as_activity_location = COALESCE(p_location, as_activity_location)
    WHERE as_activity_id = p_activity_id;

    -- Notificar solo si cambió la fecha o la ubicación
    IF (p_activity_start_datetime IS NOT NULL OR p_location IS NOT NULL) THEN
        -- Obtener nombre del grupo
        SELECT g_group_name INTO v_group_name
        FROM groups
        WHERE group_id = p_group_id;

        FOR v_user IN
            SELECT ua.ap_user_id
            FROM activityparticipants ua
            WHERE ua.ap_activity_id = p_activity_id 
			AND attendance_status = TRUE
        LOOP
            PERFORM public.fn_sys_generate_notifications(
                v_user.user_id,
                'La actividad "' || COALESCE(p_name, '') || '" del grupo "' || v_group_name || '" ha sido actualizada. Revisa los nuevos detalles.'
            );
        END LOOP;
    END IF;

    RETURN QUERY SELECT TRUE, 'Actividad actualizada exitosamente';

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Se ha producido un error: ' || SQLERRM;
    RETURN;
END;
$BODY$;