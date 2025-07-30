CREATE OR REPLACE FUNCTION fn_adm_pending_approval_requests(
	p_club_id integer)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    result JSON;
BEGIN
/*
Obtiene las solicitudes pendientes asociadas a cada equipo.
*/
    SELECT json_agg(
        json_build_object(
            'request_id', r.request_id,
            'full_name', CONCAT(u.u_name, ' ', u.u_last_name),
            'username', u.u_username,
            'email', u.u_email,
            'request_date', r.gjr_created_at,
            'status', rs.rs_status_name
        )
    )
    INTO result
    FROM groupjoinrequests r
    JOIN users u ON r.gjr_user_id = u.user_id
    JOIN requeststatus rs ON rs.request_status_id = r.gjr_request_status_id
    WHERE r.gjr_group_id = p_club_id
      AND r.gjr_request_status_id = (
          SELECT request_status_id FROM requeststatus WHERE rs_status_name = 'Pendiente'
      );

    RETURN COALESCE(result, '{"message": "no existen solicitudes", "success": "True"}'::json); -- devuelve arreglo vacío si no hay resultados
END;
$BODY$;