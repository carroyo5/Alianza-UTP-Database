CREATE OR REPLACE FUNCTION fn_get_club_details(
	p_club_id integer)
    RETURNS TABLE(group_id integer, group_name character varying, group_description text, owner_name text, creation_date timestamp without time zone, logo_url text, group_contact character varying, group_type_name character varying, group_status_name character varying, members_count bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
  RETURN QUERY
  SELECT 
    g.group_id,
    g.g_group_name,
    g.g_group_description,
    CONCAT(u.u_name, ' ', u.u_last_name) AS owner_name,
    g.g_creation_date,
    g.g_logo_url,
    c.gc_contact_value,
    gc.gc_category_name AS group_type_name,
    s.gs_status_name AS group_status_name,
    (SELECT COUNT(*) FROM groupmembers gm WHERE gm.group_id = g.group_id AND gm.gm_status_id = 2) AS members_count
  FROM groups g
  JOIN users u ON u.user_id = g.g_group_owner_id
  LEFT JOIN groupscontacts c ON c.group_id = g.group_id AND c.gc_is_primary = true
  JOIN groupcategories gc ON gc.group_category_id = g.g_group_category_id
  JOIN usertypes ct ON ct.type_id = u.u_user_type_id
  JOIN groupstatus s ON s.group_status_id = g.g_group_status_id
  WHERE g.group_id = p_club_id;
END;
$BODY$;