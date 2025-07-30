
CREATE OR REPLACE FUNCTION fn_create_group(
	p_group_name character varying,
	p_group_description text,
	p_owner_id integer,
	p_group_category text,
	p_max_group_per_user integer,
	p_contact_info json DEFAULT NULL::json)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_category_id INT;
    v_group_status_id INT;
    v_group_id INT;
    v_contact JSON;
BEGIN
/*
Procedimiento para la creación de un grupo por parte de un usuario. 
Incluye validaciones como: límite de grupos por usuario, existencia y validez de la categoría, 
nombre único del grupo, y estado del usuario. Si todas las condiciones se cumplen, 
registra el nuevo grupo, guarda los contactos asociados (si existen) 
y genera una notificación de confirmación al creador.
*/
    -- Validar cantidad máxima de grupos por usuario
    IF (SELECT COUNT(group_id) FROM groups WHERE g_group_owner_id = p_owner_id) >= p_max_group_per_user THEN
        RETURN QUERY SELECT 'Máximo número de grupos excedidos para este usuario.', FALSE;
        RETURN;
    END IF;

    -- Validar que la categoría exista
    IF NOT EXISTS (
        SELECT 1 FROM groupcategories
        WHERE LOWER(gc_category_name) = LOWER(p_group_category)
    ) THEN
        RETURN QUERY SELECT 'Categoría de grupo no válida.', FALSE;
        RETURN;
    END IF;

    -- Validar que el nombre del grupo no exista ya
    IF EXISTS (
        SELECT 1 FROM groups 
        WHERE LOWER(g_group_name) = LOWER(p_group_name)
    ) THEN
        RETURN QUERY SELECT 'Ya existe un grupo con ese nombre.', FALSE;
        RETURN;
    END IF;

    -- Validar que el usuario exista y esté activo
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE user_id = p_owner_id AND u_user_status_id = 1
    ) THEN
        RETURN QUERY SELECT 'El usuario no existe o no está activo.', FALSE;
        RETURN;
    END IF;

    -- Obtener ID de la categoría
    SELECT group_category_id INTO v_category_id
    FROM groupcategories 
    WHERE LOWER(gc_category_name) = LOWER(p_group_category);

    -- Obtener ID de estado "Activo"
    SELECT group_status_id INTO v_group_status_id
    FROM groupstatus 
    WHERE gs_status_name = 'Activo';

    -- Insertar grupo y capturar ID
    INSERT INTO groups (
        g_group_name, g_group_description, g_group_status_id, g_group_owner_id, g_group_category_id
    )
    VALUES (
        p_group_name, p_group_description, v_group_status_id, p_owner_id, v_category_id
    )
    RETURNING group_id INTO v_group_id;

    -- Insertar contactos si vienen en el JSON
    IF p_contact_info IS NOT NULL THEN
        FOR v_contact IN SELECT * FROM json_array_elements(p_contact_info)
        LOOP
            INSERT INTO groupscontacts (
                group_id,
                gc_contact_name,
                gc_contact_type,
                gc_contact_value,
                gc_is_primary
            )
            VALUES (
                v_group_id,
                v_contact ->> 'name',
                v_contact ->> 'type',
                v_contact ->> 'value',
                (v_contact ->> 'primary')::BOOLEAN
            );
        END LOOP;
    END IF;
	PERFORM(fn_sys_generate_notifications(p_owner_id, '¡Tu grupo "' || p_group_name || '" ha sido creado exitosamente! Ya puedes gestionarlo desde tu bandeja de grupos.'));
	
    RETURN QUERY SELECT 'El grupo fue creado exitosamente.', TRUE;
    RETURN;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'Ha ocurrido un error en la creación. ' || SQLERRM, FALSE;
    RETURN;
END;
$BODY$;