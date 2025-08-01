CREATE OR REPLACE PROCEDURE sp_create_user_refresh_token(
	IN p_user_id integer,
	IN p_token uuid,
	INOUT message text,
	INOUT success boolean)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	-- Actualizar el último login si encontró usuario
    UPDATE users u
    SET u_last_login_date = NOW() AT TIME ZONE 'America/Bogota'
    WHERE u.user_id = p_user_id;
    
    -- Desactivar sesiones anteriores
    UPDATE usersessions uss
    SET is_active = FALSE
    WHERE uss.user_id = p_user_id;

    INSERT INTO UserSessions (
        user_id, token_jti, expires_at
    )
    VALUES (
        p_user_id, p_token, NOW() AT TIME ZONE 'America/Bogota' + INTERVAL '7 days'
    );

    message := 'Refresh token creado correctamente.';
	success := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Error al crear refresh token: ' || SQLERRM;
		success := FALSE;
END;
$BODY$;