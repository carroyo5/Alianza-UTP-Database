
CREATE OR REPLACE FUNCTION public.fn_sys_get_notifications(
	p_user_id integer)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    result JSON;
    v_now TIMESTAMPTZ := NOW() AT TIME ZONE 'America/Bogota';
BEGIN
    SELECT json_agg(json_build_object(
        'notification_id', un.notification_id, 
        'description', un.notification_text, 
        'elapsed_time', un.elapsed_time
    ))
    INTO result
    FROM (
        SELECT
            notification_id,
            notification_text,
            CASE
                WHEN EXTRACT(year FROM age(v_now, datetime)) >= 1 THEN
                    'hace ' || FLOOR(EXTRACT(year FROM age(v_now, datetime)))::int || ' año' || 
                    CASE WHEN FLOOR(EXTRACT(year FROM age(v_now, datetime)))::int > 1 THEN 's' ELSE '' END
                WHEN EXTRACT(month FROM age(v_now, datetime)) >= 1 THEN
                    'hace ' || FLOOR(EXTRACT(month FROM age(v_now, datetime)))::int || ' mes' ||
                    CASE WHEN FLOOR(EXTRACT(month FROM age(v_now, datetime)))::int > 1 THEN 'es' ELSE '' END
                WHEN EXTRACT(day FROM age(v_now, datetime)) >= 1 THEN
                    'hace ' || FLOOR(EXTRACT(day FROM age(v_now, datetime)))::int || ' día' ||
                    CASE WHEN FLOOR(EXTRACT(day FROM age(v_now, datetime)))::int > 1 THEN 's' ELSE '' END
                WHEN EXTRACT(hour FROM age(v_now, datetime)) >= 1 THEN
                    'hace ' || FLOOR(EXTRACT(hour FROM age(v_now, datetime)))::int || ' hora' ||
                    CASE WHEN FLOOR(EXTRACT(hour FROM age(v_now, datetime)))::int > 1 THEN 's' ELSE '' END
                WHEN EXTRACT(minute FROM age(v_now, datetime)) >= 1 THEN
                    'hace ' || FLOOR(EXTRACT(minute FROM age(v_now, datetime)))::int || ' minuto' ||
                    CASE WHEN FLOOR(EXTRACT(minute FROM age(v_now, datetime)))::int > 1 THEN 's' ELSE '' END
                ELSE
                    'hace ' || FLOOR(EXTRACT(second FROM age(v_now, datetime)))::int || ' segundo' ||
                    CASE WHEN FLOOR(EXTRACT(second FROM age(v_now, datetime)))::int > 1 THEN 's' ELSE '' END
            END AS elapsed_time
        FROM usernotifications
        WHERE user_id = p_user_id
        AND is_read = FALSE
    ) AS un;

    RETURN result;
END;
$BODY$;
