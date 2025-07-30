CREATE OR REPLACE FUNCTION fn_update_user_profile_photo(
	p_user_id integer,
	url character varying)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	DECLARE v_message TEXT;
			v_success BOOLEAN;
	BEGIN
		BEGIN
			UPDATE users u
			SET u_profile_photo_url = COALESCE(url, u_profile_photo_url)
			WHERE u.user_id = p_user_id;
	
			v_message := 'Se ha actualizado.';
			v_success := TRUE;
	
			EXCEPTION WHEN OTHERS THEN
				v_message := 'Ha ocurrido un error actualizando la foto de perfil.';
				v_success := FALSE;
		END;

		RETURN QUERY SELECT v_message, v_success;
	END
$BODY$;