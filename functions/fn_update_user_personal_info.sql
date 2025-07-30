CREATE OR REPLACE FUNCTION public.fn_update_user_personal_info(
	p_user_id integer,
	p_name character varying DEFAULT NULL::character varying,
	p_last_name character varying DEFAULT NULL::character varying,
	p_email character varying DEFAULT NULL::character varying,
	p_phone character varying DEFAULT NULL::character varying,
	p_about_me text DEFAULT NULL::text,
	p_career text DEFAULT NULL::text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
  UPDATE users
  SET 
    u_name = COALESCE(p_name, u_name),
    u_last_name = COALESCE(p_last_name, u_last_name),
    u_email = COALESCE(p_email, u_email),
    u_phone = COALESCE(p_phone, u_phone),
    u_about_me = COALESCE(p_about_me, u_about_me),
	u_career = COALESCE(p_career, u_career)
  WHERE user_id = p_user_id;

  RETURN FOUND;
END;
$BODY$;
