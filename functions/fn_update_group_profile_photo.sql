CREATE OR REPLACE FUNCTION fn_update_group_profile_photo(
	p_user_id integer,
	p_group_id integer,
	url character varying)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    -- Validar si el usuario es administrador o dueño del grupo
    IF EXISTS (
        SELECT 1 FROM groups g
        LEFT JOIN groupmembers gm ON g.group_id = gm.group_id AND gm.gm_role_id IN (2, 3)
        WHERE g.group_id = p_group_id
        AND (gm.user_id = p_user_id OR g.g_group_owner_id = p_user_id)
    ) THEN
        BEGIN
            UPDATE groups
            SET g_logo_url = COALESCE(url, g_logo_url)
            WHERE group_id = p_group_id;

            message := 'La foto de perfil del grupo ha sido actualizada correctamente.';
            success := TRUE;
        EXCEPTION WHEN OTHERS THEN
            message := 'Ha ocurrido un error al actualizar la foto de perfil del grupo.';
            success := FALSE;
        END;
    ELSE
        message := 'No tienes permisos para actualizar la foto de este grupo.';
        success := FALSE;
    END IF;

    RETURN NEXT;
END;
$BODY$;
