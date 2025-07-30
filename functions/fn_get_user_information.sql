CREATE OR REPLACE FUNCTION fn_get_user_information(
	p_user_id integer)
    RETURNS TABLE(username character varying, email character varying, name character varying, last_name character varying, phone character varying, about_me text, gender character varying, birth_date date, doc_number character varying, doc_type character varying, profile_photo_url character varying, user_type character varying, user_status character varying, career text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
/*
Consulta para obtener todos los datos de un usuario.
*/
    RETURN QUERY
        SELECT 
            u.u_username AS username,
            u.u_email AS email,
            u.u_name AS name,
            u.u_last_name AS last_name,
            u.u_phone AS phone,
            CASE 
                WHEN u.u_about_me IS NULL THEN '¡Hola ' || u.u_name || '! Cuéntanos algo interesante sobre ti... tu historia nos encantaría conocerla. Completa tu "Sobre mí" en tu perfil.'
                ELSE u.u_about_me 
            END AS about_me,
			gt.g_gender_name AS gender,
			u.u_birth_date AS birth_date,
			u.u_document_number AS doc_number,
			dt.dt_type_name AS doc_type,
            u.u_profile_photo_url,
            ut.ut_type_name AS user_type,
            us.us_status_name AS user_status,
			u_career AS career
        FROM 
            users u
            JOIN userTypes ut ON u.u_user_type_id = ut.type_id
            JOIN userStatus us ON u.u_user_status_id = us.user_status_id
			JOIN gendertypes gt ON gt.gender_id = u.u_gender_id
			JOIN documenttype dt ON dt.document_type_id = u.u_document_type_id
        WHERE u.user_id = p_user_id;
END;
$BODY$;
