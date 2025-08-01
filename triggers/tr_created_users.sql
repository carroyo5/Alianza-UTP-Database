CREATE OR REPLACE TRIGGER tr_created_users
    AFTER INSERT
    ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_sys_welcome_new_users();