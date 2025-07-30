CREATE OR REPLACE FUNCTION verify_auth_refresh(
	user_id integer,
	jti uuid)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE v_message TEXT;
		v_success BOOLEAN;
	BEGIN
		IF EXISTS (SELECT 1
		FROM usersessions uss
		WHERE uss.user_id = $1 
		AND uss.token_jti = $2
		AND uss.is_active = TRUE)
			THEN 
				v_message := 'Autenticado';
				v_success := TRUE;
			ELSE
				v_message := 'JTI invalido.';
				v_success := FALSE;
			END IF;

		RETURN QUERY SELECT v_message, v_success;
	END;
$BODY$;