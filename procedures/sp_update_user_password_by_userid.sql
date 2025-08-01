CREATE OR REPLACE PROCEDURE sp_update_user_password_by_userid(
	IN p_user_id integer,
	IN p_new_password text,
	OUT p_message text,
	OUT p_success boolean)
LANGUAGE 'plpgsql'
AS $BODY$
	BEGIN
		 UPDATE users
		    SET 
		        u_password = p_new_password,
		        u_last_password_update = NOW() AT TIME ZONE 'America/Bogota'
		    WHERE user_id = p_user_id; 
			
	    p_message := 'Contraseña actualizada correctamente.';
		p_success := TRUE;
		
	EXCEPTION WHEN OTHERS THEN
		    p_message := 'Error al actualizar contraseña: ' || SQLERRM;
			p_success := FALSE;
	END
$BODY$;