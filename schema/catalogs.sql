INSERT INTO public.activitystatus(
	activity_status_id, as_activity_status_name)
	VALUES (1, 'Programada'), (2, 'Realizada'), (3, 'Cancelada');


INSERT INTO public.activitytypes(
    at_activity_type_name, at_description)
VALUES 
    ('Taller', 'Sesión práctica para desarrollar habilidades específicas'),
    ('Charla', 'Presentación informativa sobre un tema específico'),
    ('Evento Social', 'Actividad para fomentar la interacción entre estudiantes'),
    ('Conferencia', 'Disertación académica impartida por expertos'),
    ('Seminario', 'Reunión especializada con discusión técnica'),
    ('Foro', 'Espacio de debate sobre temas académicos o sociales'),
    ('Exposición', 'Muestra de trabajos académicos o artísticos'),
    ('Competencia Académica', 'Evento donde se evalúan conocimientos y habilidades'),
    ('Hackathon', 'Maratón de programación y desarrollo tecnológico'),
    ('Voluntariado', 'Actividad de servicio comunitario'),
    ('Intercambio Cultural', 'Evento para compartir tradiciones y costumbres'),
    ('Feria de Empleo', 'Espacio para conectar estudiantes con empleadores'),
    ('Olimpiada Deportiva', 'Competencia atlética interuniversitaria'),
    ('Club de Estudio', 'Grupo regular de aprendizaje colaborativo'),
    ('Visita Guiada', 'Recorrido académico a instalaciones relevantes'),
    ('Simposio', 'Reunión de expertos para discutir investigaciones'),
    ('Congreso', 'Encuentro académico multidisciplinario'),
    ('Festival Artístico', 'Muestra de talento musical, teatral o visual'),
    ('Cine Foro', 'Proyección y análisis de material audiovisual'),
    ('Networking', 'Evento para establecer conexiones profesionales');

INSERT INTO public.documenttypes(
	dt_type_name, dt_description)
	VALUES ('Cédula', 'Documento nacional de identidad'), 
	('Pasaporte', 'Documento oficial para viajes internacionales');


INSERT INTO public.gendertypes(
    g_gender_name, g_description)
VALUES 
    ('Masculino', 'Identifica como hombre'),
    ('Femenino', 'Identifica como mujer'),
    ('Prefiero no decirlo', 'Prefiere no especificar su género');


INSERT INTO public.groupcategories(gc_category_name, gc_description)
VALUES 
    ('Académico', 'Grupos enfocados en el estudio y mejora académica'),
    ('Deportivo', 'Equipos y clubes deportivos universitarios'),
    ('Cultural', 'Grupos dedicados a actividades artísticas y culturales'),
    ('Tecnología', 'Clubes de programación, robótica e innovación tecnológica'),
    ('Voluntariado', 'Grupos de servicio comunitario y ayuda social'),
    ('Emprendimiento', 'Comunidades para el desarrollo de proyectos empresariales'),
    ('Ciencias', 'Grupos de investigación y divulgación científica'),
    ('Debate', 'Sociedades de debate y oratoria'),
    ('Medio Ambiente', 'Colectivos de sostenibilidad y ecología'),
    ('Gastronomía', 'Clubes culinarios y de cocina'),
    ('Idiomas', 'Grupos de práctica y aprendizaje de lenguas extranjeras'),
    ('Fotografía', 'Colectivos de fotografía y medios visuales'),
    ('Cine', 'Clubes de apreciación y producción cinematográfica'),
    ('Música', 'Bandas, orquestas y coros universitarios'),
    ('Teatro', 'Grupos de actuación y producción teatral'),
    ('Literatura', 'Círculos de escritura creativa y lectura'),
    ('Danza', 'Grupos de baile y expresión corporal'),
    ('Política', 'Organizaciones estudiantiles políticas'),
    ('Derechos Humanos', 'Colectivos de activismo y derechos humanos'),
    ('Videojuegos', 'Comunidades de gamers y desarrollo de juegos'),
    ('Astronomía', 'Grupos de astronomía y exploración espacial'),
    ('Salud Estudiantil', 'Grupos de bienestar y salud mental'),
    ('Artes Marciales', 'Clubes de disciplinas de defensa personal'),
    ('Periodismo', 'Medios de comunicación y prensa estudiantil'),
    ('Moda', 'Colectivos de diseño y producción de moda');

INSERT INTO public.groupmemberstatus(
    group_member_status_id, gms_status_name, gms_description)
VALUES 
    (1, 'Pendiente', 'Solicitud en espera de aprobación'),
    (2, 'Aprobado', 'Miembro aprobado'),
    (3, 'Rechazado', 'Solicitud denegada'),
    (4, 'Inactivo', 'Miembro inactivo');

	
INSERT INTO public.groupstatus(
    group_status_id, gs_status_name, gs_description)
VALUES 
    (1, 'Activo', 'Grupo en funcionamiento normal'),
    (2, 'Inactivo', 'Grupo cerrado temporal o permanentemente');


INSERT INTO public.memberroles(
    role_id, mr_role_name, mr_description)
VALUES 
    (1, 'Miembro', 'Miembro regular del grupo con acceso básico'),
    (2, 'Moderador', 'Miembro con permisos limitados de gestión y moderación'),
    (3, 'Administrador', 'Responsable principal con todos los permisos del grupo');

INSERT INTO public.profile_photos(
    id, image_url)
VALUES 
    (1, 'https://i.imgur.com/hgYRiv1.jpeg'),
    (2, 'https://i.imgur.com/1l6d8B4.jpeg'),
    (3, 'https://i.imgur.com/51TA3OZ.jpeg'),
    (4, 'https://i.imgur.com/ybtjwdb.jpeg');

INSERT INTO public.requeststatus(
    request_status_id, rs_status_name)
VALUES 
    (1, 'Pendiente'),
    (2, 'Aprobado'),
    (3, 'Rechazado'),
    (4, 'Cancelado');

INSERT INTO public.userstatus(
    user_status_id, us_status_name, us_description)
VALUES 
    (1, 'Activo', 'Usuario activo con acceso completo'),
    (2, 'Inactivo', 'Usuario deshabilitado temporalmente'),
    (3, 'Suspendido', 'Usuario suspendido por infracciones'),
    (4, 'Egresado', 'Usuario graduado con acceso limitado'),
    (5, 'Pendiente', 'Usuario registrado pendiente de verificación'),
    (6, 'Bloqueado', 'Usuario bloqueado por seguridad'),
    (7, 'Eliminado', 'Cuenta de usuario eliminada');

INSERT INTO public.usertypes(
    type_id, ut_type_name, ut_description)
VALUES 
    (1, 'Estudiante', 'Usuario con rol de estudiante'),
    (2, 'Profesor', 'Usuario con rol de docente'),
    (3, 'Administrador', 'Usuario con privilegios administrativos');