CREATE OR REPLACE FUNCTION fn_adm_delete_group(
	p_user_id integer,
	p_group_id integer)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
    v_status_id INT;
    v_user RECORD;
    v_group_name TEXT;
    v_group_exists BOOLEAN;
    v_group_is_active BOOLEAN;
BEGIN
    -- Verificar que el grupo existe
    SELECT EXISTS (
        SELECT 1 FROM groups WHERE group_id = p_group_id
    ) INTO v_group_exists;

    IF NOT v_group_exists THEN
        RETURN QUERY SELECT 'El grupo especificado no existe.', FALSE;
        RETURN;
    END IF;

    -- Verificar que el usuario sea el dueño del grupo
    IF EXISTS (
        SELECT 1 FROM groups g
        WHERE g.group_id = p_group_id
        AND g.g_group_owner_id = p_user_id
    ) THEN
        -- Verificar si ya está inactivo
        SELECT g_group_status_id = gs.group_status_id
        INTO v_group_is_active
        FROM groups g
        JOIN groupstatus gs ON gs.gs_status_name = 'Inactivo'
        WHERE g.group_id = p_group_id;

        IF v_group_is_active THEN
            RETURN QUERY SELECT 'El grupo ya se encuentra inactivo.', FALSE;
            RETURN;
        END IF;

        -- Obtener ID de estado "Inactivo"
        SELECT group_status_id INTO v_status_id
        FROM groupstatus
        WHERE gs_status_name = 'Inactivo';

        -- Obtener el nombre del grupo
        SELECT g_group_name INTO v_group_name
        FROM groups 
        WHERE group_id = p_group_id;

        -- Desactivar el grupo
        UPDATE groups
        SET g_group_status_id = v_status_id
        WHERE group_id = p_group_id;

        -- Notificar a los miembros activos del grupo
        FOR v_user IN
            SELECT user_id
            FROM groupmembers
            WHERE group_id = p_group_id
            AND gm_status_id = 2 -- Activos
        LOOP
            PERFORM public.fn_sys_generate_notifications(
                v_user.user_id,
                'Te notificamos que el grupo "' || v_group_name || '" ha sido desactivado por el propietario. Ya no podrás acceder a su contenido.'
            );
        END LOOP;

        RETURN QUERY SELECT 'El grupo ha sido desactivado correctamente.', TRUE;
        RETURN;
    ELSE
        RETURN QUERY SELECT 'Solo el dueño del grupo puede desactivarlo.', FALSE;
        RETURN;
    END IF;
END;
$BODY$;