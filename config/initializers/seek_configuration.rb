#DO NOT EDIT THIS FILE TO CHANGE SETTINGS. THESE ARE ONLY USED TO PRE-POPULATE THE DEFAULT VALUES.
#CHANGE THESE VALUES THROUGH THE ADMIN PAGES WHILST RUNNING SEEK.
require_relative './seek_testing'
require 'seek/config'

def load_seek_config_defaults!
  #Main settings
  Seek::Config.default :sycamore_enabled,false
  Seek::Config.default :jerm_enabled,false
  Seek::Config.default :email_enabled,false
  Seek::Config.default :smtp, {:address => '', :port => '25', :domain => '', :authentication => :plain, :user_name => '', :password => '', :enable_starttls_auto=>false}
  Seek::Config.default :noreply_sender, 'no-reply@sysmo-db.org'
  Seek::Config.default :support_email_address, ''
  Seek::Config.default :solr_enabled, false
  Seek::Config.default :filtering_enabled, true
  Seek::Config.default :jws_enabled, true
  Seek::Config.default :jws_online_root,"https://jws2.sysmo-db.org/"
  Seek::Config.default :internal_help_enabled, false
  Seek::Config.default :external_help_url,"https://docs.seek4science.org/help"
  Seek::Config.default :exception_notification_enabled,false
  Seek::Config.default :exception_notification_recipients,""
  Seek::Config.default :error_grouping_enabled,true
  Seek::Config.default :error_grouping_timeout,2.minutes
  Seek::Config.default :error_grouping_log_base,2
  Seek::Config.default :hide_details_enabled,false
  Seek::Config.default :registration_disabled,false
  Seek::Config.default :registration_disabled_description,'Registration is not available, please contact your administrator'
  Seek::Config.default :activation_required_enabled,false
  Seek::Config.default :google_analytics_enabled, false
  Seek::Config.default :google_analytics_tracker_id, '000-000'
  Seek::Config.default :google_analytics_tracking_notice, true
  Seek::Config.default :piwik_analytics_enabled, false
  Seek::Config.default :piwik_analytics_id_site, 1
  Seek::Config.default :piwik_analytics_url, 'localhost/piwik/'
  Seek::Config.default :piwik_analytics_tracking_notice, true
  Seek::Config.default :custom_analytics_snippet_enabled, false
  Seek::Config.default :custom_analytics_name, 'Custom name'
  Seek::Config.default :custom_analytics_snippet, ''
  Seek::Config.default :custom_analytics_tracking_notice, true
  Seek::Config.default :bioportal_api_key,''
  Seek::Config.default :project_news_enabled,false
  Seek::Config.default :project_news_feed_urls,''
  Seek::Config.default :project_news_number_of_entries,10
  Seek::Config.default :community_news_enabled,false
  Seek::Config.default :community_news_feed_urls,''
  Seek::Config.default :community_news_number_of_entries,10
  Seek::Config.default :home_description, 'You can configure the text that goes here within the Admin pages: Site Configuration->Home page settings.'
  Seek::Config.default :home_description_position, 'side'
  Seek::Config.default :tagline_prefix, 'Find, share and exchange <b>Data</b>, <b>Models</b> and <b>Processes</b> within the'
  Seek::Config.default :auth_lookup_enabled,true
  Seek::Config.default :external_search_enabled, true
  Seek::Config.default :project_single_page_enabled, false
  Seek::Config.default :isa_json_compliance_enabled, false
  Seek::Config.default :project_single_page_folders_enabled, false
  Seek::Config.default :project_browser_enabled,false
  Seek::Config.default :experimental_features_enabled,false
  Seek::Config.default :pdf_conversion_enabled,true
  Seek::Config.default :delete_asset_version_enabled, false
  Seek::Config.default :filestore_path,"filestore"
  Seek::Config.default :modelling_analysis_enabled,true
  Seek::Config.default :human_diseases_enabled, false
  Seek::Config.default :guide_box_enabled,true
  Seek::Config.default :tagging_enabled, true
  Seek::Config.default :authorization_checks_enabled, true
  Seek::Config.default :documentation_enabled,true
  Seek::Config.default :assay_type_ontology_file, "JERM.rdf"
  Seek::Config.default :technology_type_ontology_file, "JERM.rdf"
  Seek::Config.default :modelling_analysis_type_ontology_file, "JERM.rdf"
  Seek::Config.default :assay_type_base_uri,"http://jermontology.org/ontology/JERMOntology#Experimental_assay_type"
  Seek::Config.default :technology_type_base_uri,"http://jermontology.org/ontology/JERMOntology#Technology_type"
  Seek::Config.default :modelling_analysis_type_base_uri,"http://jermontology.org/ontology/JERMOntology#Model_analysis_type"
  Seek::Config.default :profile_select_by_default,true
  Seek::Config.default :show_announcements, true
  Seek::Config.default :programme_user_creation_enabled, false
  Seek::Config.default :programmes_open_for_projects_enabled, false
  Seek::Config.default :project_admin_sample_type_restriction, false #only project admins can create and edit sample types and controlled vocabs
  Seek::Config.default :recommended_data_licenses,  ['CC-BY-4.0', 'CC0-1.0', 'CC-BY-NC-4.0', 'CC-BY-SA-4.0', 'ODC-BY-1.0']
  Seek::Config.default :recommended_software_licenses, ['Apache-2.0','GPL-3.0','MIT','BSD-2-Clause','BSD-3-Clause','LGPL-2.1']

  # Types
  Seek::Config.default :documents_enabled,true
  Seek::Config.default :data_files_enabled,true
  Seek::Config.default :events_enabled,true
  Seek::Config.default :isa_enabled, true
  Seek::Config.default :models_enabled,true
  Seek::Config.default :organisms_enabled,true
  Seek::Config.default :programmes_enabled, false
  Seek::Config.default :presentations_enabled,true
  Seek::Config.default :publications_enabled,true
  Seek::Config.default :samples_enabled, true
  Seek::Config.default :sops_enabled, true
  Seek::Config.default :workflows_enabled, false
  Seek::Config.default :collections_enabled, true
  Seek::Config.default :file_templates_enabled, false
  Seek::Config.default :placeholders_enabled, false

  #Observered variables
  Seek::Config.default :observed_variables_enabled, false
  Seek::Config.default :observed_variable_sets_enabled,false

  Seek::Config.default :doi_minting_enabled, false
  Seek::Config.default :time_lock_doi_for, 0
  Seek::Config.default :doi_prefix,''
  Seek::Config.default :doi_suffix,'seek'


  Seek::Config.default :header_tagline_text_enabled, true

#time in minutes that the feeds on the front page are cached for
  Seek::Config.default :home_feeds_cache_timeout,30
# Branding
  Seek::Config.default :instance_name,'FAIRDOM-SEEK'
  Seek::Config.default :instance_link,'https://fairdomseek.org'

  Seek::Config.default :instance_admins_name,"FAIRDOM"
  Seek::Config.default :instance_admins_link,"http://www.fair-dom.org"

  Seek::Config.default :header_image_enabled,true
  Seek::Config.default :header_image_title, "FAIRDOM"
  Seek::Config.default :header_image_link,"http://www.fair-dom.org"
  Seek::Config.default :copyright_addendum_enabled,false
  Seek::Config.default :copyright_addendum_content,'Additions copyright ...'
  Seek::Config.default :issue_tracker, 'https://fair-dom.org/issues'

  Seek::Config.fixed :application_name,"FAIRDOM-SEEK"

  #Imprint
  Settings.defaults[:imprint_enabled]= false
  Seek::Config.default :imprint_description, File.read(Rails.root.join('config/default_data/imprint_example'))

  #About page
  Settings.defaults[:about_page_enabled]= false
  Seek::Config.default :about_page, File.read(Rails.root.join('config/default_data/about_page_example'))

  Seek::Config.default :about_instance_link_enabled, false
  Seek::Config.default :about_instance_admin_link_enabled, false
  Seek::Config.default :cite_link, ''
  Seek::Config.default :contact_link, ''

  Seek::Config.default :funding_link, ''

  #Terms and conditions page
  Settings.defaults[:terms_enabled]= false
  Seek::Config.default :terms_page, File.read(Rails.root.join('config/default_data/terms_and_conditions_example'))

  #Privacy policy
  Settings.defaults[:privacy_enabled]= false
  Seek::Config.default :privacy_page, File.read(Rails.root.join('config/default_data/privacy_policy_example'))

  #the maximum size, in Mb, for a spreadsheet file that can be extracted and explored
  Seek::Config.default :max_extractable_spreadsheet_size,10
  Seek::Config.default :jvm_memory_allocation,'512M'

  #the maximum size, in Mb, for a text file that can be indexed for search (too high and the indexing will timeout)
  Seek::Config.default :max_indexable_text_size,100

  Seek::Config.default :related_items_limit,5
  Seek::Config.default :search_results_limit,5

# Others
  Seek::Config.default :type_managers_enabled,true
  Seek::Config.default :type_managers,'admins'
  Seek::Config.default :tag_threshold,1
  Seek::Config.default :max_visible_tags,20
  Seek::Config.default :pubmed_api_email,nil
  Seek::Config.default :crossref_api_email,nil
  Seek::Config.default :site_base_host,"http://localhost:3000"
  Seek::Config.default :open_id_authentication_store,:memory
  Seek::Config.default :session_store_timeout, 1.hour
  Seek::Config.default :cv_dropdown_limit, 100

  # Admin setting to allow user impersonation, useful for debugging
  Seek::Config.default :admin_impersonation_enabled, false

  Seek::Config.default :recaptcha_enabled, false

  #MERGENOTE - remove this from config and replace with alternative partial
  Seek::Config.default :seek_video_link, "http://www.youtube.com/user/elinawetschHITS?feature=mhee#p/u"

  # Set default permissions
  Seek::Config.default :default_associated_projects_access_type, Policy::ACCESSIBLE
  Seek::Config.default :default_all_visitors_access_type, Policy::PRIVATE
  Seek::Config.default :max_all_visitors_access_type, Policy::ACCESSIBLE

  Seek::Config.default :permissions_popup, Seek::Config::PERMISSION_POPUP_ALWAYS

  Seek::Config.default :auth_lookup_update_batch_size, 10

  Seek::Config.fixed :css_prepended,''
  Seek::Config.fixed :css_appended,''
  Seek::Config.fixed :main_layout,'application'

  Seek::Config.default :datacite_url, 'https://mds.datacite.org/'
  Seek::Config.default :zenodo_publishing_enabled, false
  Seek::Config.default :zenodo_api_url, 'https://zenodo.org/api'
  Seek::Config.default :zenodo_oauth_url, 'https://zenodo.org/oauth'

  Seek::Config.default :allow_private_address_access, false
  Seek::Config.default :cache_remote_files, true
  Seek::Config.default :max_cachable_size, 20 * 1024 * 1024
  Seek::Config.default :hard_max_cachable_size, 100 * 1024 * 1024

  Seek::Config.default :orcid_required, false

  Seek::Config.default :news_enabled,false
  Seek::Config.default :news_feed_urls,''
  Seek::Config.default :news_number_of_entries,10
  Seek::Config.default :recent_contributions_number_of_entries, 20
  Seek::Config.default :tag_cloud_enabled,true
  Seek::Config.default :workflow_class_list_enabled,false

  # Home page panel settings
  Seek::Config.default :home_show_features,true
  Seek::Config.default :home_show_quickstart,true
  Seek::Config.default :home_show_my_items,true
  Seek::Config.default :home_show_who_uses,true
  Seek::Config.default :home_explore_projects,true
  Seek::Config.default :home_show_integrations,true
  Seek::Config.default :home_carousel,[]

  # omniauth settings and behaviour
  Seek::Config.default :omniauth_enabled, false
  Seek::Config.default :omniauth_user_create, true
  Seek::Config.default :omniauth_user_activate, true
  Seek::Config.default :omniauth_elixir_aai_enabled, false
  Seek::Config.default :omniauth_elixir_aai_client_id, ''
  Seek::Config.default :omniauth_elixir_aai_secret, ''
  Seek::Config.default :omniauth_ldap_enabled, false
  # See: https://github.com/intridea/omniauth-ldap
  Seek::Config.default :omniauth_ldap_config, {
    title: "organization-ldap",
    host: 'localhost',
    port: 389,
    method: :plain,
    base: 'DC=example,DC=com',
    uid: 'samaccountname',
    password: '',
    bind_dn: ''
  }

  Seek::Config.default :openbis_enabled,false
  Seek::Config.default :openbis_download_limit, 2.gigabytes
  Seek::Config.default :openbis_debug, false
  Seek::Config.default :openbis_autosync, true
  Seek::Config.default :openbis_check_new_arrivals, true

  Seek::Config.default :default_license, 'CC-BY-4.0'
  Seek::Config.default :metadata_license, 'CC-BY-4.0'

  Seek::Config.default :nels_api_url, 'https://test-fe.cbu.uib.no/nels-api'
  Seek::Config.default :nels_oauth_url, 'https://test-fe.cbu.uib.no/oauth2'
  Seek::Config.default :nels_permalink_base, 'https://test-fe.cbu.uib.no/nels/pages/sbi/sbi.xhtml'
  Seek::Config.default :nels_use_dummy_client, false

  Seek::Config.default :results_per_page_default, 7
  Seek::Config.default :results_per_page_default_condensed, 14
  Seek::Config.default :results_per_page, {}
  Seek::Config.default :sorting, {}

  Seek::Config.default :life_monitor_enabled, false
  Seek::Config.default :life_monitor_url, 'https://api.lifemonitor.eu/'
  Seek::Config.default :life_monitor_ui_url, 'https://app.lifemonitor.eu/'
  Seek::Config.default :git_support_enabled, false
  Seek::Config.default :bio_tools_enabled, false

  load_seek_testing_defaults! if Rails.env.test?
end

SEEK::Application.configure do
  load_seek_config_defaults!
end
