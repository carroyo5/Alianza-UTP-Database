SELECT cron.schedule(
    'clean-expired-user-codes-daily',
    '0 5 * * *',
    'CALL public.clean_expired_user_codes()'
);

SELECT cron.schedule(
    'reminder_notifications_generator',
    '* 15 * * * *',
    'SELECT public.fn_sys_generate_reminder_notifications();'
);

SELECT cron.schedule(
    'clean_expired_sessions_daily',
    '0 5 * * *',
    'CALL public.clean_expired_user_sessions()'
);