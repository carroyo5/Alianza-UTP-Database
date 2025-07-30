
CREATE OR REPLACE FUNCTION fn_sys_generate_datetime_spanish_context(
	input_timestamp timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    result_text TEXT;
    day_name TEXT;
    month_name TEXT;
BEGIN
    SELECT CASE TRIM(LOWER(TO_CHAR(input_timestamp, 'Day')))
        WHEN 'monday' THEN 'Lunes'
        WHEN 'tuesday' THEN 'Martes'
        WHEN 'wednesday' THEN 'Miércoles'
        WHEN 'thursday' THEN 'Jueves'
        WHEN 'friday' THEN 'Viernes'
        WHEN 'saturday' THEN 'Sábado'
        WHEN 'sunday' THEN 'Domingo'
    END INTO day_name;

    SELECT CASE EXTRACT(MONTH FROM input_timestamp)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END INTO month_name;

    result_text := CONCAT(
        day_name, ', ',
        EXTRACT(DAY FROM input_timestamp), ' de ',
        month_name, ' de ',
        EXTRACT(YEAR FROM input_timestamp), ' a las ',
        TO_CHAR(input_timestamp, 'HH12:MI AM')
    );
    RETURN result_text;
END;
$BODY$;