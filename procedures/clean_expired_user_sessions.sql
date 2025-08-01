CREATE OR REPLACE PROCEDURE clean_expired_user_sessions(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM UserSessions
    WHERE expires_at < CURRENT_TIMESTAMP AT TIME ZONE 'America/Bogota' OR is_active = FALSE;
END;
$BODY$;