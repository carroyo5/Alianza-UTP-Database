CREATE OR REPLACE FUNCTION fn_adm_get_member_status(
	p_club_id integer)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
/*
Función que devuelve los estados actuales y pasados de los miembros.
*/
    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'status', status,
            'quantity', quantity
        ))
        FROM (
            SELECT 
    			gms.gms_status_name AS status,
				COUNT(DISTINCT gm.user_id) AS quantity
			FROM groupmemberstatus gms
			LEFT JOIN groupmembers gm 
			    ON gm.gm_status_id = gms.group_member_status_id AND gm.group_id = p_club_id
            GROUP BY gms.gms_status_name
        ) AS sub
    );
END;
$BODY$;