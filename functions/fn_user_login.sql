CREATE OR REPLACE FUNCTION fn_user_login(
	p_username character varying,
	p_email character varying)
    RETURNS TABLE(user_id integer, username character varying, email character varying, en_password text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	BEGIN
	RETURN QUERY
    SELECT u.user_id, u.u_username, u.u_email, u.u_password AS en_password
    FROM users u
    WHERE
        (p_username IS NOT NULL AND u.u_username = p_username)
        OR
        (p_email IS NOT NULL AND u.u_email = p_email)
		AND u_user_status_id = 1
    LIMIT 1;
	END;
$BODY$;