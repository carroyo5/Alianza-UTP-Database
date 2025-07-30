CREATE OR REPLACE FUNCTION fn_adm_update_pending_request(
	p_club_id integer,
	p_request_id integer,
	p_user_id integer,
	p_action text)
    RETURNS TABLE(message text, success boolean, was_approved boolean, approved_user_data json) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_request_status INT;
    v_member_role INT;
    v_target_user_id INT;
    v_member_status INT;
	v_fullname TEXT;
	v_email TEXT;
  	v_group_name TEXT;
	v_data JSON;
	
BEGIN
/*
Actualiza el estado de una solicitud de ingreso a un grupo, marcándola como 'Aprobada' o 'Rechazada'.
*/
    -- Verificar permisos
    IF NOT (
        EXISTS (
            SELECT 1 
            FROM groupmembers
            WHERE user_id = p_user_id 
              AND group_id = p_club_id 
              AND gm_role_id IN (2, 3)
        )
        OR
        EXISTS (
            SELECT 1 
            FROM groups 
            WHERE g_group_owner_id = p_user_id 
              AND group_id = p_club_id
        )
    ) THEN
        RETURN QUERY SELECT 'No tienes permisos para aprobar o rechazar solicitudes en este grupo.', FALSE, FALSE, '{}'::JSON;
        RETURN;
    END IF;

	--Validacion de estado
	SELECT gjr_request_status_id INTO v_request_status 
	FROM groupjoinrequests 
	WHERE request_id = p_request_id;
	
	IF NOT FOUND OR v_request_status <> 1 THEN
	    RETURN QUERY SELECT 'La solicitud ya ha sido atendida o no existe.', FALSE, FALSE, '{}'::JSON;
	    RETURN;
	END IF;
	
    -- Verificar pertenencia de la solicitud
    IF NOT EXISTS (
        SELECT 1
        FROM groupjoinrequests
        WHERE request_id = p_request_id
          AND gjr_group_id = p_club_id
    ) THEN
        RETURN QUERY SELECT 'La solicitud no pertenece a este grupo.', FALSE, FALSE, '{}'::JSON;
        RETURN;
    END IF;

    -- Verificar validez del estado
    SELECT request_status_id
    INTO v_request_status
    FROM requeststatus
    WHERE LOWER(rs_status_name) = LOWER(p_action);

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'Estado "' || p_action || '" no es válido.', FALSE, FALSE, '{}'::JSON;
        RETURN;
    END IF;

    -- Obtener el user_id del solicitante
    SELECT gjr_user_id INTO v_target_user_id
    FROM groupjoinrequests 
    WHERE request_id = p_request_id;

    -- Actualizar el estado de la solicitud
    UPDATE groupjoinrequests
    SET gjr_request_status_id = v_request_status,
        gjr_updated_at = NOW() AT TIME ZONE 'America/Bogota'
    WHERE request_id = p_request_id;

    -- Obtener nombre completo y nombre del grupo
    SELECT u_name || ' ' || u_last_name, u_email INTO v_fullname, v_email
    FROM users WHERE user_id = v_target_user_id;

    SELECT g_group_name INTO v_group_name
    FROM groups WHERE group_id = p_club_id;

    SELECT json_build_object(
        'fullname', v_fullname,
		'email', v_email,
        'group_name', v_group_name
    ) INTO v_data;

    -- Si fue aprobado
    IF LOWER(p_action) <> 'rechazado' THEN
        -- Rol: Miembro
        SELECT role_id INTO v_member_role
        FROM memberroles WHERE mr_role_name = 'Miembro';

        -- Estado: Aprobado
        SELECT group_member_status_id INTO v_member_status
        FROM groupmemberstatus WHERE gms_status_name = 'Aprobado';

        -- Insertar en groupmembers
        INSERT INTO groupmembers (
            user_id, group_id, gm_role_id, gm_status_id, gm_approved_by
        )
        VALUES (
            v_target_user_id, p_club_id, v_member_role, v_member_status, p_user_id
        );

        -- Notificación positiva
        PERFORM fn_sys_generate_notifications(
            v_target_user_id, 
            '¡Felicidades! Tu solicitud para unirte al grupo ' || v_group_name || ' ha sido aprobada.'
        );
		RETURN QUERY SELECT 'La solicitud ha sido actualizada correctamente.', TRUE, TRUE, v_data;

	ELSIF LOWER(p_action) = 'rechazado' THEN
	-- Notificación negativa
    PERFORM fn_sys_generate_notifications(
        v_target_user_id, 
        'Lamentablemente, tu solicitud para unirte al grupo ' || v_group_name || ' no ha sido aprobada en esta ocasión.');
		RETURN QUERY SELECT 'La solicitud ha sido rechazada.', TRUE, FALSE, v_data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'Ocurrió un error al actualizar la solicitud.', FALSE, FALSE, '{}'::JSON;

END;
$BODY$;