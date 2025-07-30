
CREATE OR REPLACE FUNCTION vw_verifiy_mail_existance(
	p_email text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM users WHERE u_email = p_email) INTO v_exists;
    RETURN v_exists;
END;
$BODY$;
