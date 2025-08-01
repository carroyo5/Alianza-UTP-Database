-- Tablas independientes
CREATE TABLE IF NOT EXISTS activitystatus (
    activity_status_id integer NOT NULL DEFAULT nextval('activitystatus_activity_status_id_seq'::regclass),
    as_activity_status_name character varying COLLATE pg_catalog."default",
    CONSTRAINT activitystatus_pkey PRIMARY KEY (activity_status_id));

CREATE TABLE IF NOT EXISTS activitytypes (
    activity_type_id integer NOT NULL DEFAULT nextval('activitytypes_activity_type_id_seq'::regclass),
    at_activity_type_name character varying COLLATE pg_catalog."default",
    at_description text COLLATE pg_catalog."default",
    CONSTRAINT activitytypes_pkey PRIMARY KEY (activity_type_id));

CREATE TABLE IF NOT EXISTS documenttypes (
        document_type_id integer NOT NULL DEFAULT nextval('documenttypes_document_type_id_seq'),
    dt_type_name character varying COLLATE pg_catalog."default",
    dt_description text COLLATE pg_catalog."default",
    CONSTRAINT documenttypes_pkey PRIMARY KEY (document_type_id)
    );
    
CREATE TABLE IF NOT EXISTS email_verifications (
    code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    email character varying(255) COLLATE pg_catalog."default",
    code integer,
    expires_at timestamp without time zone,
    active boolean DEFAULT true,
    CONSTRAINT email_verifications_pkey PRIMARY KEY (code_id)
);

CREATE TABLE IF NOT EXISTS gendertypes (
    gender_id integer NOT NULL DEFAULT nextval('gendertypes_gender_id_seq'::regclass),
    g_gender_name character varying COLLATE pg_catalog."default",
    g_description text COLLATE pg_catalog."default",
    CONSTRAINT gendertypes_pkey PRIMARY KEY (gender_id)
    );

CREATE TABLE IF NOT EXISTS groupcategories (
    group_category_id integer NOT NULL DEFAULT nextval('groupcategories_group_category_id_seq'::regclass),
    gc_category_name character varying COLLATE pg_catalog."default",
    gc_description text COLLATE pg_catalog."default",
    CONSTRAINT groupcategories_pkey PRIMARY KEY (group_category_id));

CREATE TABLE IF NOT EXISTS groupmemberstatus (
    group_member_status_id integer NOT NULL DEFAULT nextval('groupmemberstatus_group_member_status_id_seq'::regclass),
    gms_status_name character varying COLLATE pg_catalog."default",
    gms_description text COLLATE pg_catalog."default",
    CONSTRAINT groupmemberstatus_pkey PRIMARY KEY (group_member_status_id));

CREATE TABLE IF NOT EXISTS groupstatus (
    group_status_id integer NOT NULL DEFAULT nextval('groupstatus_group_status_id_seq'::regclass),
    gs_status_name character varying COLLATE pg_catalog."default",
    gs_description text COLLATE pg_catalog."default",
    CONSTRAINT groupstatus_pkey PRIMARY KEY (group_status_id)
    );

CREATE TABLE IF NOT EXISTS memberroles (
    role_id integer NOT NULL DEFAULT nextval('memberroles_role_id_seq'::regclass),
    mr_role_name character varying COLLATE pg_catalog."default",
    mr_description text COLLATE pg_catalog."default",
    CONSTRAINT memberroles_pkey PRIMARY KEY (role_id)
    );

CREATE TABLE IF NOT EXISTS profile_photos (
    id integer NOT NULL DEFAULT nextval('profile_photos_id_seq'::regclass),
    image_url text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT profile_photos_pkey PRIMARY KEY (id)
    );

CREATE TABLE IF NOT EXISTS requeststatus (
    request_status_id integer NOT NULL DEFAULT nextval('requeststatus_request_status_id_seq'::regclass),
    rs_status_name character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT requeststatus_pkey PRIMARY KEY (request_status_id)
);

CREATE TABLE IF NOT EXISTS userstatus (
    user_status_id integer NOT NULL DEFAULT nextval('userstatus_user_status_id_seq'::regclass),
    us_status_name character varying COLLATE pg_catalog."default",
    us_description text COLLATE pg_catalog."default",
    CONSTRAINT userstatus_pkey PRIMARY KEY (user_status_id)
    );

CREATE TABLE IF NOT EXISTS usertypes (
    type_id integer NOT NULL DEFAULT nextval('usertypes_type_id_seq'::regclass),
    ut_type_name character varying COLLATE pg_catalog."default",
    ut_description text COLLATE pg_catalog."default",
    CONSTRAINT usertypes_pkey PRIMARY KEY (type_id)
);

-- Tablas que dependen de las anteriores

CREATE TABLE IF NOT EXISTS users (
    user_id integer NOT NULL DEFAULT nextval('users_user_id_seq'::regclass),
    u_name character varying COLLATE pg_catalog."default",
    u_last_name character varying COLLATE pg_catalog."default",
    u_username character varying COLLATE pg_catalog."default",
    u_email character varying COLLATE pg_catalog."default",
    u_phone character varying COLLATE pg_catalog."default",
    u_about_me text COLLATE pg_catalog."default",
    u_password text COLLATE pg_catalog."default",
    u_last_password_update timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    u_profile_photo_url character varying COLLATE pg_catalog."default",
    u_user_type_id integer NOT NULL,
    u_user_status_id integer NOT NULL,
    u_creation_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    u_last_login_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    u_birth_date date,
    u_document_number character varying COLLATE pg_catalog."default",
    u_document_type_id integer,
    u_gender_id integer,
    u_career text COLLATE pg_catalog."default",
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_u_email_key UNIQUE (u_email),
    CONSTRAINT users_u_username_key UNIQUE (u_username),
    CONSTRAINT users_u_document_type_id_fkey FOREIGN KEY (u_document_type_id)
        REFERENCES documenttypes (document_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT users_u_gender_id_fkey FOREIGN KEY (u_gender_id)
        REFERENCES gendertypes (gender_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT users_u_user_status_id_fkey FOREIGN KEY (u_user_status_id)
        REFERENCES userstatus (user_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT users_u_user_type_id_fkey FOREIGN KEY (u_user_type_id)
        REFERENCES usertypes (type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        );
CREATE TABLE IF NOT EXISTS groups (
    group_id integer NOT NULL DEFAULT nextval('groups_group_id_seq'::regclass),
    g_group_name character varying COLLATE pg_catalog."default",
    g_group_description text COLLATE pg_catalog."default",
    g_group_status_id integer NOT NULL,
    g_group_owner_id integer NOT NULL,
    g_group_category_id integer NOT NULL,
    g_creation_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    g_logo_url text COLLATE pg_catalog."default",
    CONSTRAINT groups_pkey PRIMARY KEY (group_id),
    CONSTRAINT groups_g_group_category_id_fkey FOREIGN KEY (g_group_category_id)
        REFERENCES groupcategories (group_category_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groups_g_group_owner_id_fkey FOREIGN KEY (g_group_owner_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groups_g_group_status_id_fkey FOREIGN KEY (g_group_status_id)
        REFERENCES groupstatus (group_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION);

-- Tablas intermedias (relacionales)

CREATE TABLE IF NOT EXISTS groupmembers (
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    gm_signup_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    gm_role_id integer NOT NULL,
    gm_status_id integer NOT NULL,
    gm_approved_by integer NOT NULL,
    gm_updated_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    CONSTRAINT groupmembers_pkey PRIMARY KEY (user_id, group_id),
    CONSTRAINT groupmembers_gm_approved_by_fkey FOREIGN KEY (gm_approved_by)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupmembers_gm_role_id_fkey FOREIGN KEY (gm_role_id)
        REFERENCES memberroles (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupmembers_gm_status_id_fkey FOREIGN KEY (gm_status_id)
        REFERENCES groupmemberstatus (group_member_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupmembers_group_id_fkey FOREIGN KEY (group_id)
        REFERENCES groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupmembers_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
	);

CREATE TABLE IF NOT EXISTS groupscontacts ( contact_info_id integer NOT NULL DEFAULT nextval('groupscontacts_contact_info_id_seq'::regclass),
    group_id integer NOT NULL,
    gc_contact_name character varying COLLATE pg_catalog."default",
    gc_contact_type character varying COLLATE pg_catalog."default",
    gc_contact_value character varying COLLATE pg_catalog."default",
    gc_is_primary boolean,
    CONSTRAINT groupscontacts_pkey PRIMARY KEY (contact_info_id),
    CONSTRAINT groupscontacts_group_id_fkey FOREIGN KEY (group_id)
        REFERENCES groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        );
        
CREATE TABLE IF NOT EXISTS groupjoinrequests (
    request_id integer NOT NULL DEFAULT nextval('groupjoinrequests_request_id_seq'::regclass),
    gjr_group_id integer NOT NULL,
    gjr_user_id integer NOT NULL,
    gjr_request_status_id integer NOT NULL,
    gjr_created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    gjr_updated_at timestamp with time zone,
    request_uuid uuid DEFAULT gen_random_uuid(),
    CONSTRAINT groupjoinrequests_pkey PRIMARY KEY (request_id),
    CONSTRAINT groupjoinrequests_request_uuid_key UNIQUE (request_uuid),
    CONSTRAINT fk_groupjoinrequests_request_status FOREIGN KEY (gjr_request_status_id)
        REFERENCES requeststatus (request_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupjoinrequests_gjr_group_id_fkey FOREIGN KEY (gjr_group_id)
        REFERENCES groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupjoinrequests_gjr_request_status_id_fkey FOREIGN KEY (gjr_request_status_id)
        REFERENCES groupmemberstatus (group_member_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupjoinrequests_gjr_user_id_fkey FOREIGN KEY (gjr_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION);

-- Tablas relacionadas a actividades

CREATE TABLE IF NOT EXISTS groupactivities (
    activity_id integer NOT NULL DEFAULT nextval('groupactivities_activity_id_seq'::regclass),
    ga_activity_name character varying COLLATE pg_catalog."default",
    ga_activity_description text COLLATE pg_catalog."default",
    ga_max_participants integer,
    ga_activity_type integer NOT NULL,
    ga_activity_status integer NOT NULL,
    ga_group_id integer NOT NULL,
    ga_creator_id integer NOT NULL,
    ga_activity_created_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    CONSTRAINT groupactivities_pkey PRIMARY KEY (activity_id),
    CONSTRAINT groupactivities_ga_activity_status_fkey FOREIGN KEY (ga_activity_status)
        REFERENCES activitystatus (activity_status_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupactivities_ga_activity_type_fkey FOREIGN KEY (ga_activity_type)
        REFERENCES activitytypes (activity_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupactivities_ga_creator_id_fkey FOREIGN KEY (ga_creator_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT groupactivities_ga_group_id_fkey FOREIGN KEY (ga_group_id)
        REFERENCES groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
	);
        
CREATE TABLE IF NOT EXISTS activitiesschedule (
    schedule_id integer NOT NULL DEFAULT nextval('activitiesschedule_schedule_id_seq'::regclass),
    as_activity_id integer NOT NULL,
    as_activity_start_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    as_activity_end_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    as_activity_location character varying COLLATE pg_catalog."default",
    CONSTRAINT activitiesschedule_pkey PRIMARY KEY (schedule_id),
    CONSTRAINT activitiesschedule_as_activity_id_fkey FOREIGN KEY (as_activity_id)
        REFERENCES groupactivities (activity_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION);

CREATE TABLE IF NOT EXISTS activityparticipants (
    participant_id integer NOT NULL DEFAULT nextval('activityparticipants_participant_id_seq'::regclass),
    ap_user_id integer NOT NULL,
    ap_activity_id integer NOT NULL,
    ap_registration_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    attendance_status boolean DEFAULT true,
    CONSTRAINT activityparticipants_pkey PRIMARY KEY (participant_id),
    CONSTRAINT activityparticipants_ap_activity_id_fkey FOREIGN KEY (ap_activity_id)
        REFERENCES groupactivities (activity_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT activityparticipants_ap_user_id_fkey FOREIGN KEY (ap_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        );

--Tablas relacionadas a usuarios

CREATE TABLE IF NOT EXISTS usernotifications (
    notification_id integer NOT NULL DEFAULT nextval('usernotifications_notification_id_seq'::regclass),
    user_id integer NOT NULL,
    notification_text text COLLATE pg_catalog."default" NOT NULL,
    is_read boolean DEFAULT false,
    datetime timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'America/Bogota'::text),
    CONSTRAINT usernotifications_pkey PRIMARY KEY (notification_id),
    CONSTRAINT fk_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE);
		
CREATE TABLE IF NOT EXISTS usersessions (
    token_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id integer,
    token_jti uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true,
    CONSTRAINT usersessions_pkey PRIMARY KEY (token_id),
    CONSTRAINT usersessions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        );