CREATE OR REPLACE FUNCTION vw_group_members(
	vw_group_id integer)
    RETURNS TABLE(full_name text, status character varying, role character varying, last_seen timestamp without time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	BEGIN
	RETURN QUERY 
			SELECT
				u.u_Name ||' '||u.u_last_name AS full_name,
				gms.gms_status_name AS status,
				mr.mr_role_name AS role,
				u.u_last_login_date AS last_seen
			FROM
				groupmembers gm
					INNER JOIN users u ON u.user_id = gm.user_id
					INNER JOIN groupmemberstatus gms ON gms.group_member_status_id = gm.gm_status_id
					INNER JOIN memberroles mr ON mr.role_id = gm.gm_role_id
			WHERE
				gm.group_id IN (vw_group_id);
	END;
$BODY$;