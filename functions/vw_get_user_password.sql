CREATE OR REPLACE FUNCTION vw_get_user_password(
	p_user_id integer)
    RETURNS TABLE(hashed_password text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_password TEXT;
	BEGIN
	    SELECT u_password INTO v_password
	    FROM users
	    WHERE user_id = p_user_id;
	
	    IF v_password IS NULL THEN
	        RETURN QUERY SELECT NULL, FALSE;
	    ELSE
	        RETURN QUERY SELECT v_password, TRUE;
	    END IF;
	END;
$BODY$;