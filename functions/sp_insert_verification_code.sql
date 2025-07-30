CREATE OR REPLACE FUNCTION sp_insert_verification_code(
	p_email text,
	p_code integer,
	p_expires_in integer DEFAULT 10)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    payload TEXT;
    rows_inserted INT;
BEGIN
/*
Funcion para insertar y enviar correo con el codigo
*/
    -- Desactivar codigos activos anteriores
    UPDATE email_verifications
    SET active = FALSE
    WHERE email = p_email AND active = TRUE;

    -- Insertar nuevo codigo activo
    INSERT INTO email_verifications (email, code, expires_at, active)
    VALUES (
        p_email,
        p_code,
        NOW() + INTERVAL '1 minute' * p_expires_in,
        TRUE
    );
    GET DIAGNOSTICS rows_inserted = ROW_COUNT;

    IF rows_inserted = 1 THEN
        -- Crear el JSON para notificacion
        payload := json_build_object(
            'event', 'reset_pass_code',
            'code', p_code,
            'email', p_email
        )::TEXT;
        -- Enviar notificación al canal
        PERFORM pg_notify('database_events', payload);

        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$BODY$;