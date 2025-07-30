CREATE OR REPLACE FUNCTION fn_update_user_password_by_email(
	p_email text,
	p_new_password text)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
    UPDATE users
    SET 
        u_password = p_new_password,
        u_last_password_update = NOW()
    WHERE u_email = p_email;

    IF FOUND THEN
        message := 'Contraseña actualizada correctamente.';
        success := TRUE;
    ELSE
        message := 'No se encontró el usuario con ese correo.';
        success := FALSE;
    END IF;

    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    message := 'Error al actualizar contraseña: ' || SQLERRM;
    success := FALSE;
    RETURN NEXT;
END;
$BODY$;