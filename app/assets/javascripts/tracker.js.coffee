class SurveyApp.Tracker
  constructor: (user_info, @development=false) ->
    mixpanel.init("981a7a6da84c67bb7faeec8db0143beb")
    mixpanel.identify(user_info.user_id);
    mixpanel.name_tag(user_info.name);
    mixpanel.people.set
      "$email": user_info.email,
      "$name": user_info.name,
      "org_id": user_info.org_id,
      "role": user_info.role

      mixpanel.set_config({ debug: true, track_links_timeout: 2000  }) if @development

  track_forms: (form_id, event_name, attributes={}) =>
    mixpanel.track_forms(form_id, event_name, attributes);

  track_links: (element_id, event_name, attributes={}) =>
    mixpanel.track_links(element_id, event_name, attributes);


