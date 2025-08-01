CREATE OR REPLACE FUNCTION fn_sys_notify_created_activity()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
		payload TEXT;
		user_data JSON;
		v_group_name TEXT;
	BEGIN
		--Obtener nombre del grupo
		SELECT g_group_name INTO v_group_name
	    FROM groups
	    WHERE group_id = NEW.ga_group_id
		LIMIT 1;

		
		SELECT json_agg(json_build_object('email', u.u_email, 'name', u.u_name)) INTO user_data
	    FROM groupmembers gm
	    JOIN users u ON gm.user_id = u.user_id
	    WHERE gm.group_id = NEW.ga_group_id
	      AND gm.gm_status_id = 2  -- Estado activo
		  AND u.user_id NOT IN (NEW.ga_creator_id)
	      AND u.u_user_status_id = 1;

		payload := json_build_object(
		'event', 'activity_created',
		'group_name', v_group_name,
		'activity_id', NEW.activity_id,
		'activity_name', NEW.ga_activity_name,
		'user_data', user_data
		)::TEXT;

		PERFORM pg_notify('database_events', payload);
		RETURN NEW;
	END;
$BODY$;
