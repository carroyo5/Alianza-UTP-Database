CREATE OR REPLACE PROCEDURE clean_expired_user_codes()
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM email_verifications
    WHERE expires_at < CURRENT_DATE AT TIME ZONE 'America/Bogota';
END;
$BODY$;