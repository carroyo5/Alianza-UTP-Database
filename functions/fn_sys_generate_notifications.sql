CREATE OR REPLACE FUNCTION fn_sys_generate_notifications(
	p_user_id integer,
	p_notification_text text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO usernotifications (user_id, notification_text)
    VALUES (p_user_id, p_notification_text);
END;
$BODY$;