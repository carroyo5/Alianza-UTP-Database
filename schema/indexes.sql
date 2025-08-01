CREATE INDEX IF NOT EXISTS idx_users_email ON users (u_email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (u_username);

-- Índices adicionales sugeridos
CREATE INDEX IF NOT EXISTS idx_groupactivities_creator_id ON groupactivities (ga_creator_id);
CREATE INDEX IF NOT EXISTS idx_groupactivities_status ON groupactivities (ga_activity_status);
CREATE INDEX IF NOT EXISTS idx_activityparticipants_user ON activityparticipants (ap_user_id);
CREATE INDEX IF NOT EXISTS idx_activityparticipants_activity ON activityparticipants (ap_activity_id);
CREATE INDEX IF NOT EXISTS idx_groupmembers_status ON groupmembers (gm_status_id);
CREATE INDEX IF NOT EXISTS idx_groupjoinrequests_user ON groupjoinrequests (gjr_user_id);
