CREATE OR REPLACE TRIGGER tr_notifiy_new_activity
    AFTER INSERT
    ON public.groupactivities
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_sys_notify_created_activity();