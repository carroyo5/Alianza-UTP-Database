CREATE OR REPLACE FUNCTION fn_request_group_join(
	p_user_id integer,
	p_group_id integer)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_request_status_id INT;
BEGIN
    -- Verificar si el usuario ya es miembro del grupo
    IF EXISTS (
        SELECT 1 
        FROM groupmembers 
        WHERE user_id = p_user_id AND group_id = p_group_id
    ) THEN
        RETURN QUERY SELECT 'El usuario ya es miembro del grupo.', FALSE;
        RETURN;
    END IF;

    -- Verificar si el usuario es el dueño del grupo
    IF EXISTS (
        SELECT 1 
        FROM groups 
        WHERE group_id = p_group_id AND g_group_owner_id = p_user_id
    ) THEN
        RETURN QUERY SELECT 'El usuario es el dueño del grupo.', FALSE;
        RETURN;
    END IF;

    -- Verificar si ya existe una solicitud pendiente
    IF EXISTS (
        SELECT 1
        FROM groupjoinrequests
        WHERE gjr_user_id = p_user_id 
          AND gjr_group_id = p_group_id 
          AND gjr_request_status_id = (
              SELECT request_status_id 
              FROM requeststatus 
              WHERE rs_status_name = 'Pendiente'
          )
    ) THEN
        RETURN QUERY SELECT 'Ya existe una solicitud pendiente para este grupo.', FALSE;
        RETURN;
    END IF;

    -- Obtener el ID del estado 'Pendiente'
    SELECT request_status_id
    INTO v_request_status_id 
    FROM requeststatus
    WHERE rs_status_name = 'Pendiente';

    -- Insertar la solicitud de unión
    INSERT INTO groupjoinrequests (
        gjr_group_id,
        gjr_user_id,
        gjr_request_status_id
    ) VALUES (
        p_group_id,
        p_user_id,
        v_request_status_id
    );

    RETURN QUERY SELECT 'Solicitud enviada con éxito.', TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'Error al procesar la solicitud.', FALSE;
END;
$BODY$;