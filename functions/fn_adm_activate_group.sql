CREATE OR REPLACE FUNCTION fn_adm_activate_group(
	p_user_id integer,
	p_group_id integer)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
DECLARE 
    v_status_id_active INT;
    v_current_status_id INT;
    v_user RECORD;
    v_group_name TEXT;
    v_group_exists BOOLEAN;
BEGIN
    -- Verificar que el grupo existe
    SELECT EXISTS (
        SELECT 1 FROM groups WHERE group_id = p_group_id
    ) INTO v_group_exists;

    IF NOT v_group_exists THEN
        RETURN QUERY SELECT 'El grupo especificado no existe.', FALSE;
        RETURN;
    END IF;

    -- Verificar que el usuario es el dueño del grupo
    IF EXISTS (
        SELECT 1 FROM groups g
        WHERE g.group_id = p_group_id
        AND g.g_group_owner_id = p_user_id
    ) THEN
        -- Obtener ID de estado actual y nombre del grupo
        SELECT g_group_status_id, g_group_name
        INTO v_current_status_id, v_group_name
        FROM groups
        WHERE group_id = p_group_id;

        -- Obtener el ID de estado "Activo"
        SELECT group_status_id INTO v_status_id_active
        FROM groupstatus
        WHERE gs_status_name = 'Activo';

        -- Verificar si ya está activo
        IF v_current_status_id = v_status_id_active THEN
            RETURN QUERY SELECT 'El grupo ya se encuentra activo.', FALSE;
            RETURN;
        END IF;

        -- Reactivar el grupo
        UPDATE groups
        SET g_group_status_id = v_status_id_active
        WHERE group_id = p_group_id;

        -- Notificar a los antiguos miembros activos
        FOR v_user IN
            SELECT user_id
            FROM groupmembers
            WHERE group_id = p_group_id
        LOOP
            PERFORM fn_sys_generate_notifications(
                v_user.user_id,
                '¡Buenas noticias! El grupo "' || v_group_name || '" ha sido reactivado por el propietario. Ya puedes volver a participar.'
            );
        END LOOP;

        RETURN QUERY SELECT 'El grupo ha sido reactivado correctamente.', TRUE;
        RETURN;
    ELSE
        RETURN QUERY SELECT 'Solo el dueño del grupo puede reactivarlo.', FALSE;
        RETURN;
    END IF;
END;
$BODY$;

ALTER FUNCTION fn_adm_activate_group(integer, integer)
    OWNER TO postgres;