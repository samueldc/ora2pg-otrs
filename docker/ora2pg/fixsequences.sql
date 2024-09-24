DO $$

DECLARE

erro varchar;

BEGIN

RAISE NOTICE 'Starting fix sequences...';

PERFORM SETVAL('acl_id_seq', COALESCE((SELECT MAX(id)+1 FROM acl), 1), false);
PERFORM SETVAL('general_catalog_id_seq', COALESCE((SELECT MAX(id)+1 FROM general_catalog), 1), false);
PERFORM SETVAL('configitem_definition_id_seq', COALESCE((SELECT MAX(id)+1 FROM configitem_definition), 1), false);
PERFORM SETVAL('configitem_history_type_id_seq', COALESCE((SELECT MAX(id)+1 FROM configitem_history_type), 1), false);
PERFORM SETVAL('dynamic_field_id_seq', COALESCE((SELECT MAX(id)+1 FROM dynamic_field), 1), false);
PERFORM SETVAL('gi_webservice_config_id_seq', COALESCE((SELECT MAX(id)+1 FROM gi_webservice_config), 1), false);
PERFORM SETVAL('gi_webservice_config_history_id_seq', COALESCE((SELECT MAX(id)+1 FROM gi_webservice_config_history), 1), false);
PERFORM SETVAL('permission_groups_id_seq', COALESCE((SELECT MAX(id)+1 FROM permission_groups), 1), false);
PERFORM SETVAL('imexport_search_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_search), 1), false);
PERFORM SETVAL('imexport_mapping_object_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_mapping_object), 1), false);
PERFORM SETVAL('imexport_object_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_object), 1), false);
PERFORM SETVAL('imexport_mapping_format_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_mapping_format), 1), false);
PERFORM SETVAL('imexport_format_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_format), 1), false);
PERFORM SETVAL('imexport_mapping_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_mapping), 1), false);
PERFORM SETVAL('imexport_template_id_seq', COALESCE((SELECT MAX(id)+1 FROM imexport_template), 1), false);
PERFORM SETVAL('notification_event_message_id_seq', COALESCE((SELECT MAX(id)+1 FROM notification_event_message), 1), false);
PERFORM SETVAL('notification_event_id_seq', COALESCE((SELECT MAX(id)+1 FROM notification_event), 1), false);
PERFORM SETVAL('package_repository_id_seq', COALESCE((SELECT MAX(id)+1 FROM package_repository), 1), false);
PERFORM SETVAL('pm_transition_action_id_seq', COALESCE((SELECT MAX(id)+1 FROM pm_transition_action), 1), false);
PERFORM SETVAL('pm_transition_id_seq', COALESCE((SELECT MAX(id)+1 FROM pm_transition), 1), false);
PERFORM SETVAL('pm_activity_dialog_id_seq', COALESCE((SELECT MAX(id)+1 FROM pm_activity_dialog), 1), false);
PERFORM SETVAL('pm_activity_id_seq', COALESCE((SELECT MAX(id)+1 FROM pm_activity), 1), false);
PERFORM SETVAL('pm_process_id_seq', COALESCE((SELECT MAX(id)+1 FROM pm_process), 1), false);
PERFORM SETVAL('system_address_id_seq', COALESCE((SELECT MAX(id)+1 FROM system_address), 1), false);
PERFORM SETVAL('queue_id_seq', COALESCE((SELECT MAX(id)+1 FROM queue), 1), false);
PERFORM SETVAL('oauth2_token_id_seq', COALESCE((SELECT MAX(id)+1 FROM oauth2_token), 1), false);
PERFORM SETVAL('oauth2_token_config_id_seq', COALESCE((SELECT MAX(id)+1 FROM oauth2_token_config), 1), false);
PERFORM SETVAL('mail_account_id_seq', COALESCE((SELECT MAX(id)+1 FROM mail_account), 1), false);
PERFORM SETVAL('roles_id_seq', COALESCE((SELECT MAX(id)+1 FROM roles), 1), false);
PERFORM SETVAL('service_id_seq', COALESCE((SELECT MAX(id)+1 FROM service), 1), false);
PERFORM SETVAL('sla_id_seq', COALESCE((SELECT MAX(id)+1 FROM sla), 1), false);
PERFORM SETVAL('ticket_type_id_seq', COALESCE((SELECT MAX(id)+1 FROM ticket_type), 1), false);
PERFORM SETVAL('ticket_state_id_seq', COALESCE((SELECT MAX(id)+1 FROM ticket_state), 1), false);
PERFORM SETVAL('sysconfig_modified_version_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_modified_version), 1), false);
PERFORM SETVAL('sysconfig_default_version_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_default_version), 1), false);
PERFORM SETVAL('sysconfig_modified_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_modified), 1), false);
PERFORM SETVAL('sysconfig_default_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_default), 1), false);
PERFORM SETVAL('sysconfig_deployment_lock_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_deployment), 1), false);
PERFORM SETVAL('sysconfig_deployment_id_seq', COALESCE((SELECT MAX(id)+1 FROM sysconfig_deployment), 1), false);
PERFORM SETVAL('survey_id_seq', COALESCE((SELECT MAX(id)+1 FROM survey), 1), false);
PERFORM SETVAL('survey_answer_id_seq', COALESCE((SELECT MAX(id)+1 FROM survey_answer), 1), false);
PERFORM SETVAL('survey_question_id_seq', COALESCE((SELECT MAX(id)+1 FROM survey_question), 1), false);

RAISE NOTICE 'Sequences sucessfully fixed!';

EXCEPTION
	WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS erro = MESSAGE_TEXT;
    RAISE NOTICE 'Ocorreu um erro: %', erro;
		ROLLBACK;

END;
$$