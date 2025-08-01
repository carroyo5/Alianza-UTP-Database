CREATE OR REPLACE FUNCTION fn_sys_welcome_new_users()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    payload TEXT;
BEGIN
    -- Construir JSON con nombre completo y email del nuevo usuario
    payload := json_build_object(
        'event', 'welcome_user',
        'full_name', NEW.u_name || ' ' || NEW.u_last_name,
        'email', NEW.u_email
    )::TEXT;

    -- Enviar notificación al canal
    PERFORM pg_notify('database_events', payload);

    RETURN NEW;
END;
$BODY$;
