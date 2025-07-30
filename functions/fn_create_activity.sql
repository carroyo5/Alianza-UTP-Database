CREATE OR REPLACE FUNCTION fn_create_activity(
	p_group_id integer,
	p_creator_id integer,
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
    v_activity_id INT;
    v_activity_status_id INT;
	v_group_name TEXT;
	v_user RECORD;
BEGIN
/*
Crea una nueva actividad en un grupo, validando permisos, tipo de actividad y horarios. 
Además, registra la actividad, su horario y notifica a los miembros activos del grupo.
*/
	IF (p_activity_start_datetime IS NULL OR p_activity_end_datetime IS NULL) THEN
		RETURN QUERY SELECT FALSE, 'Es necesario completar los horarios';
        RETURN;
	END IF;

    -- Validar si el usuario es administrador o dueño del grupo
    IF EXISTS (
        SELECT 1 FROM groups g
        LEFT JOIN groupmembers gm ON g.group_id = gm.group_id AND gm.gm_role_id IN (2, 3)
		WHERE g.group_id = p_group_id
        AND (gm.user_id = p_creator_id OR g.g_group_owner_id = p_creator_id)
    ) THEN
        BEGIN
            -- Verificar si el tipo de actividad existe
            IF NOT EXISTS (
                SELECT 1 FROM activitytypes 
                WHERE LOWER(at_activity_type_name) = LOWER(p_activity_type)
            ) THEN
                RETURN QUERY SELECT FALSE, 'Tipo de actividad no válido.';
                RETURN;
            END IF;

            -- Obtener el ID del tipo de actividad
            SELECT activity_type_id 
            INTO v_activity_type_id
            FROM activitytypes 
            WHERE LOWER(at_activity_type_name) = LOWER(p_activity_type);

            -- Obtener el estado inicial ("Programada")
            SELECT activity_status_id 
            INTO v_activity_status_id
            FROM activitystatus 
            WHERE as_activity_status_name = 'Programada';

            -- Insertar actividad
            INSERT INTO groupactivities (
                ga_activity_name,
                ga_activity_description,
                ga_max_participants,
                ga_activity_type,
                ga_activity_status,
                ga_group_id,
                ga_creator_id
            ) VALUES (
                p_name,
                p_description,
                p_max_participants,
                v_activity_type_id,
                v_activity_status_id,
                p_group_id,
                p_creator_id
            )
            RETURNING activity_id INTO v_activity_id;

            -- Insertar en el horario de actividades
            INSERT INTO activitiesschedule (
                as_activity_id,
                as_activity_start_date,
                as_activity_end_date,
                as_activity_location
            ) VALUES (
                v_activity_id,
                p_activity_start_datetime,
                p_activity_end_datetime,
                p_location
            );

			SELECT g_group_name INTO v_group_name
			FROM groups 
			WHERE group_id = p_group_id;
			
			FOR v_user IN
				SELECT user_id
				FROM groupmembers
				WHERE group_id = p_group_id 
				AND gm_status_id IN (2)
			LOOP
				-- Notificación positiva
				PERFORM fn_sys_generate_notifications(
				    v_user.user_id,
				    '¡Nueva actividad! El grupo "' || v_group_name || '" ha publicado: "' || p_name || '". ¡Revisa los detalles!'
				);
			END LOOP;

            RETURN QUERY SELECT TRUE, 'Actividad creada exitosamente';
            RETURN;

        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, 'Se ha producido un error: ' || SQLERRM;
            RETURN;
        END;
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario no autorizado o grupo no existe.';
        RETURN;
    END IF;
END;
$BODY$;