CREATE OR REPLACE FUNCTION fn_insert_user(
	p_u_name character varying,
	p_u_last_name character varying,
	p_u_username character varying,
	p_u_email character varying,
	p_u_phone character varying,
	p_u_password character varying,
	p_u_birth_date date,
	p_u_document_number character varying,
	p_u_document_type_name character varying,
	p_u_gender_name character varying)
    RETURNS TABLE(message text, success boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_user_type_id INT;
    v_user_status_id INT;
    v_doc_type_id INT;
    v_gender_id INT;
    rows_affected INT;
    v_message TEXT := '';
    v_success BOOLEAN := FALSE;
	v_target_user_id INT;
BEGIN
    -- Buscar ID del tipo de usuario
    SELECT type_id INTO v_user_type_id
    FROM usertypes
    WHERE ut_type_name = 'Estudiante'
    LIMIT 1;

    IF v_user_type_id IS NULL THEN
        v_message := 'Tipo de usuario "Estudiante" no encontrado';
        RETURN QUERY SELECT v_message, v_success;
        RETURN;
    END IF;

    -- Buscar ID del estado de usuario
    SELECT user_status_id INTO v_user_status_id
    FROM userstatus
    WHERE us_status_name = 'Activo'
    LIMIT 1;

    IF v_user_status_id IS NULL THEN
        v_message := 'Estado de usuario "Activo" no encontrado';
        RETURN QUERY SELECT v_message, v_success;
        RETURN;
    END IF;

    -- Buscar ID del tipo de documento
    SELECT document_type_id INTO v_doc_type_id
    FROM documenttypes
    WHERE dt_type_name = p_u_document_type_name
    LIMIT 1;

    IF v_doc_type_id IS NULL THEN
        v_message := 'Tipo de documento "' || p_u_document_type_name || '" no encontrado';
        RETURN QUERY SELECT v_message, v_success;
        RETURN;
    END IF;

    -- Buscar ID del género
    SELECT gender_id INTO v_gender_id
    FROM gendertypes
    WHERE g_gender_name = p_u_gender_name
    LIMIT 1;

    IF v_gender_id IS NULL THEN
        v_message := 'Género "' || p_u_gender_name || '" no encontrado';
        RETURN QUERY SELECT v_message, v_success;
        RETURN;
    END IF;

    -- Insertar usuario
    INSERT INTO Users (
        u_name, u_last_name, u_username, u_email, u_phone,
        u_about_me, u_password, u_last_password_update, u_profile_photo_url,
        u_user_type_id, u_user_status_id, u_creation_date, u_last_login_date,
        u_birth_date, u_document_number, u_document_type_id, u_gender_id
    )
    VALUES (
        p_u_name, p_u_last_name, p_u_username, p_u_email, p_u_phone,
        NULL, p_u_password, NULL, (SELECT image_url FROM profile_photos ORDER BY RANDOM() LIMIT 1),
        v_user_type_id, v_user_status_id, NOW() AT TIME ZONE 'America/Bogota', NULL,
        p_u_birth_date, p_u_document_number, v_doc_type_id, v_gender_id
    )RETURNING user_id INTO v_target_user_id;

    GET DIAGNOSTICS rows_affected := ROW_COUNT;

    IF rows_affected > 0 THEN
		-- Notificaciones de creacion de usuario 
    	PERFORM public.fn_sys_generate_notifications(
        v_target_user_id, 'Gracias por unirte a nuestra comunidad. Estamos felices de tenerte aquí. ¡Explora y disfruta!');
		
		PERFORM public.fn_sys_generate_notifications(
        v_target_user_id, 'Completa tu perfil para que otros usuarios te conozcan mejor y puedas aprovechar todas las funciones.');

        v_message := 'Usuario creado exitosamente';
        v_success := TRUE;
    ELSE
        v_message := 'No se pudo crear el usuario';
    END IF;

    RETURN QUERY SELECT v_message, v_success;

EXCEPTION
    WHEN OTHERS THEN
            IF SQLERRM LIKE '%users_u_email_key%' THEN
                v_message := 'Error: El correo electrónico ya está registrado';
            ELSIF SQLERRM LIKE '%users_u_username_key%' THEN
                v_message := 'Error: El nombre de usuario ya existe';
            ELSE
                v_message := 'Error generado en fn_insert_user';
            END IF;
		
        v_success := FALSE;
        RETURN QUERY SELECT v_message, v_success;

END;
$BODY$;