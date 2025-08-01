CREATE OR REPLACE PROCEDURE sp_deactivate_user_tokens(
	IN p_user_id integer,
	OUT message text,
	OUT success boolean)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_affected_tokens INT;
BEGIN
     -- Desactivar tokens activos
    UPDATE UserSessions
    SET is_active = FALSE
    WHERE user_id = p_user_id AND is_active = TRUE;

    GET DIAGNOSTICS v_affected_tokens = ROW_COUNT;

    IF v_affected_tokens > 0 THEN
        message := 'Se desactivaron ' || v_affected_tokens || ' tokens correctamente.';
    ELSE
        message := 'No había tokens activos para desactivar.';
    END IF;

    success := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Error al desactivar tokens: ' || SQLERRM;
        success := FALSE;
END;
$BODY$;