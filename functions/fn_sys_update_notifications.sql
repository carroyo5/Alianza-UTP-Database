CREATE OR REPLACE FUNCTION fn_sys_update_notifications(
	p_user_id integer,
	p_notification_ids integer[])
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    UPDATE usernotifications
    SET is_read = TRUE
    WHERE user_id = p_user_id
      AND notification_id = ANY(p_notification_ids);

    RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$BODY$;