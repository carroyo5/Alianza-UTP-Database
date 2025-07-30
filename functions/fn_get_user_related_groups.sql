CREATE OR REPLACE FUNCTION fn_get_user_related_groups(
	p_user_id integer)
    RETURNS TABLE(group_id integer, group_name character varying, group_description text, group_status character varying, group_owner_name text, group_category character varying) 
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
	           gs.gs_status_name,
	           u.u_name || ' ' || u.u_last_name AS group_owner_name,
	           gc.gc_category_name
	    FROM groupmembers gm
	    INNER JOIN groups g ON g.group_id = gm.group_id
	    INNER JOIN groupstatus gs ON gs.group_status_id = g.g_group_status_id
	    INNER JOIN users u ON u.user_id = g.g_group_owner_id
	    INNER JOIN groupcategories gc ON gc.group_category_id = g.g_group_category_id
	    WHERE gm.user_id = p_user_id AND g_group_status_id = 1;
	END;
$BODY$;