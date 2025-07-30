CREATE OR REPLACE FUNCTION fn_adm_get_club_members(
	p_club_id integer)
    RETURNS TABLE(username character varying, first_name character varying, last_name character varying, role_name character varying, status_name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
/*
Obtiene la información detallada de los miembros pertenecientes a un grupo específico.
*/
  RETURN QUERY
  SELECT 
    u.u_username,
    u.u_name,
    u.u_last_name,
    mrr.mr_role_name,
    us.us_status_name
  FROM groupmembers gm
  INNER JOIN users u ON u.user_id = gm.user_id
  INNER JOIN userstatus us ON us.user_status_id = u.u_user_status_id
  INNER JOIN memberroles mrr ON mrr.role_id = gm.gm_role_id
  WHERE gm.group_id = p_club_id
  AND u.u_user_status_id = 1 --Usuario activo
  AND gm.gm_status_id = 2; --Miembro de grupo acitvo
END;
$BODY$;
