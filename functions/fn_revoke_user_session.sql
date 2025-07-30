CREATE OR REPLACE FUNCTION fn_revoke_user_session(
	user_id integer)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
    v_message TEXT;
    v_success BOOLEAN;
BEGIN
    BEGIN
        UPDATE usersessions AS uss
        SET is_active = FALSE
        WHERE uss.user_id = $1;

        v_message := 'Borrado exitoso';
        v_success := TRUE;

    EXCEPTION WHEN OTHERS THEN
        v_message := 'No se han podido limpiar las sesiones: ' || SQLERRM;
        v_success := FALSE;
    END;

    RETURN QUERY SELECT v_message, v_success;
END;
$BODY$;