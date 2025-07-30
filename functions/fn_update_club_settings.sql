CREATE OR REPLACE FUNCTION fn_update_club_settings(
	p_club_id integer,
	p_name text DEFAULT NULL::text,
	p_description text DEFAULT NULL::text,
	p_status text DEFAULT NULL::text,
	p_category text DEFAULT NULL::text,
	p_logo_url text DEFAULT NULL::text)
    RETURNS TABLE(success boolean, message text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  v_category INT;
  v_status INT;
BEGIN
  IF EXISTS (SELECT 1 FROM groups WHERE group_id = p_club_id) THEN

    -- Obtener id de categoría si p_category NO es nulo
    IF p_category IS NOT NULL THEN
      SELECT group_category_id
      INTO v_category
      FROM groupcategories
      WHERE LOWER(gc_category_name) = LOWER(p_category);
    END IF;
	
	IF p_status IS NOT NULL THEN
      SELECT group_status_id
      INTO v_status
      FROM groupstatus
      WHERE LOWER(gs_status_name) = LOWER(p_status);
    END IF;
	
    BEGIN
      UPDATE groups
      SET
        g_group_name = COALESCE(p_name, g_group_name),
        g_group_description = COALESCE(p_description, g_group_description),
        g_group_status_id = COALESCE(v_status, g_group_status_id),
        g_group_category_id = COALESCE(v_category, g_group_category_id),
        g_logo_url = COALESCE(p_logo_url, g_logo_url)
      WHERE group_id = p_club_id;

      RETURN QUERY SELECT TRUE, 'Se han actualizado los datos correctamente.';
    EXCEPTION WHEN OTHERS THEN
      RETURN QUERY SELECT FALSE, 'Ha ocurrido un error al actualizar los datos.' || SQLERRM;
    END;

  ELSE
    RETURN QUERY SELECT FALSE, 'No se ha encontrado el grupo.';
  END IF;
END;
$BODY$;
