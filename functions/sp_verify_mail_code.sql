CREATE OR REPLACE FUNCTION sp_verify_mail_code(
	p_email text,
	p_code integer)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM email_verifications
        WHERE email = p_email
          AND code = p_code
          AND active = TRUE
          AND expires_at > NOW()
    ) INTO v_exists;
    
    IF v_exists THEN
        UPDATE email_verifications
        SET active = FALSE
        WHERE email = p_email AND code = p_code;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$BODY$;