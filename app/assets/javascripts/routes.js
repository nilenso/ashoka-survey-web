(function() {
  var NodeTypes, ParameterMissing, Utils, defaults,
    __hasProp = {}.hasOwnProperty;

  ParameterMissing = function(message) {
    this.message = message;
  };

  ParameterMissing.prototype = new Error();

  defaults = {
    prefix: "",
    default_url_options: {}
  };

  NodeTypes = {"GROUP":1,"CAT":2,"SYMBOL":3,"OR":4,"STAR":5,"LITERAL":6,"SLASH":7,"DOT":8};

  Utils = {
    serialize: function(obj) {
      var i, key, prop, result, s, val, _i, _len;

      if (!obj) {
        return "";
      }
      if (window.jQuery) {
        result = window.jQuery.param(obj);
        return (!result ? "" : result);
      }
      s = [];
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        prop = obj[key];
        if (prop != null) {
          if (this.getObjectType(prop) === "array") {
            for (i = _i = 0, _len = prop.length; _i < _len; i = ++_i) {
              val = prop[i];
              s.push("" + key + (encodeURIComponent("[]")) + "=" + (encodeURIComponent(val.toString())));
            }
          } else {
            s.push("" + key + "=" + (encodeURIComponent(prop.toString())));
          }
        }
      }
      if (!s.length) {
        return "";
      }
      return s.join("&");
    },
    clean_path: function(path) {
      var last_index;

      path = path.split("://");
      last_index = path.length - 1;
      path[last_index] = path[last_index].replace(/\/+/g, "/").replace(/\/$/m, "");
      return path.join("://");
    },
    set_default_url_options: function(optional_parts, options) {
      var i, part, _i, _len, _results;

      _results = [];
      for (i = _i = 0, _len = optional_parts.length; _i < _len; i = ++_i) {
        part = optional_parts[i];
        if (!options.hasOwnProperty(part) && defaults.default_url_options.hasOwnProperty(part)) {
          _results.push(options[part] = defaults.default_url_options[part]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    extract_anchor: function(options) {
      var anchor;

      anchor = "";
      if (options.hasOwnProperty("anchor")) {
        anchor = "#" + options.anchor;
        delete options.anchor;
      }
      return anchor;
    },
    extract_options: function(number_of_params, args) {
      var ret_value;

      ret_value = {};
      if (args.length > number_of_params && this.getObjectType(args[args.length - 1]) === "object") {
        ret_value = args.pop();
      }
      return ret_value;
    },
    path_identifier: function(object) {
      var property;

      if (object === 0) {
        return "0";
      }
      if (!object) {
        return "";
      }
      property = object;
      if (this.getObjectType(object) === "object") {
        property = object.to_param || object.id || object;
        if (this.getObjectType(property) === "function") {
          property = property.call(object);
        }
      }
      return property.toString();
    },
    clone: function(obj) {
      var attr, copy, key;

      if ((obj == null) || "object" !== this.getObjectType(obj)) {
        return obj;
      }
      copy = obj.constructor();
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        attr = obj[key];
        copy[key] = attr;
      }
      return copy;
    },
    prepare_parameters: function(required_parameters, actual_parameters, options) {
      var i, result, val, _i, _len;

      result = this.clone(options) || {};
      for (i = _i = 0, _len = required_parameters.length; _i < _len; i = ++_i) {
        val = required_parameters[i];
        result[val] = actual_parameters[i];
      }
      return result;
    },
    build_path: function(required_parameters, optional_parts, route, args) {
      var opts, parameters, result, url, url_params;

      args = Array.prototype.slice.call(args);
      opts = this.extract_options(required_parameters.length, args);
      if (args.length > required_parameters.length) {
        throw new Error("Too many parameters provided for path");
      }
      parameters = this.prepare_parameters(required_parameters, args, opts);
      this.set_default_url_options(optional_parts, parameters);
      result = "" + (this.get_prefix()) + (this.visit(route, parameters));
      url = Utils.clean_path("" + result + (this.extract_anchor(parameters)));
      if ((url_params = this.serialize(parameters)).length) {
        url += "?" + url_params;
      }
      return url;
    },
    visit: function(route, parameters, optional) {
      var left, left_part, right, right_part, type, value;

      if (optional == null) {
        optional = false;
      }
      type = route[0], left = route[1], right = route[2];
      switch (type) {
        case NodeTypes.GROUP:
          return this.visit(left, parameters, true);
        case NodeTypes.STAR:
          return this.visit_globbing(left, parameters, true);
        case NodeTypes.LITERAL:
        case NodeTypes.SLASH:
        case NodeTypes.DOT:
          return left;
        case NodeTypes.CAT:
          left_part = this.visit(left, parameters, optional);
          right_part = this.visit(right, parameters, optional);
          if (optional && !(left_part && right_part)) {
            return "";
          }
          return "" + left_part + right_part;
        case NodeTypes.SYMBOL:
          value = parameters[left];
          if (value != null) {
            delete parameters[left];
            return this.path_identifier(value);
          }
          if (optional) {
            return "";
          } else {
            throw new ParameterMissing("Route parameter missing: " + left);
          }
          break;
        default:
          throw new Error("Unknown Rails node type");
      }
    },
    visit_globbing: function(route, parameters, optional) {
      var left, right, type, value;

      type = route[0], left = route[1], right = route[2];
      value = parameters[left];
      if (value == null) {
        return this.visit(route, parameters, optional);
      }
      parameters[left] = (function() {
        switch (this.getObjectType(value)) {
          case "array":
            return value.join("/");
          default:
            return value;
        }
      }).call(this);
      return this.visit(route, parameters, optional);
    },
    get_prefix: function() {
      var prefix;

      prefix = defaults.prefix;
      if (prefix !== "") {
        prefix = (prefix.match("/$") ? prefix : "" + prefix + "/");
      }
      return prefix;
    },
    _classToTypeCache: null,
    _classToType: function() {
      var name, _i, _len, _ref;

      if (this._classToTypeCache != null) {
        return this._classToTypeCache;
      }
      this._classToTypeCache = {};
      _ref = "Boolean Number String Function Array Date RegExp Undefined Null".split(" ");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this._classToTypeCache["[object " + name + "]"] = name.toLowerCase();
      }
      return this._classToTypeCache;
    },
    getObjectType: function(obj) {
      var strType;

      if (window.jQuery && (window.jQuery.type != null)) {
        return window.jQuery.type(obj);
      }
      strType = Object.prototype.toString.call(obj);
      return this._classToType()[strType] || "object";
    },
    namespace: function(root, namespaceString) {
      var current, parts;

      parts = (namespaceString ? namespaceString.split(".") : []);
      if (!parts.length) {
        return;
      }
      current = parts.shift();
      root[current] = root[current] || {};
      return Utils.namespace(root[current], parts.join("."));
    }
  };

  Utils.namespace(window, "Routes");

  window.Routes = {
// api => /api/jobs/:id/alive(.:format)
  api_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"jobs",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"alive",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_audit => /api/audits/:id(.:format)
  api_audit_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"audits",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_audits => /api/audits(.:format)
  api_audits_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"audits",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_categories => /api/categories(.:format)
  api_categories_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"categories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_category => /api/categories/:id(.:format)
  api_category_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"categories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_deep_surveys => /api/deep_surveys(.:format)
  api_deep_surveys_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"deep_surveys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_login => /api/login(.:format)
  api_login_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"login",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_option => /api/options/:id(.:format)
  api_option_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"options",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_options => /api/options(.:format)
  api_options_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"options",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_question => /api/questions/:id(.:format)
  api_question_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"questions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_questions => /api/questions(.:format)
  api_questions_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"questions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_record => /api/records/:id(.:format)
  api_record_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"records",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_records => /api/records(.:format)
  api_records_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"records",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_response => /api/responses/:id(.:format)
  api_response_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_responses => /api/responses(.:format)
  api_responses_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"responses",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_survey => /api/surveys/:id(.:format)
  api_survey_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_surveys => /api/surveys(.:format)
  api_surveys_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"surveys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auth_failure => (/:locale)/auth/failure(.:format)
  auth_failure_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"auth",false]],[7,"/",false]],[6,"failure",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// complete_survey_response => (/:locale)/surveys/:survey_id/responses/:id/complete(.:format)
  complete_survey_response_path: function(_survey_id, _id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id","id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// count_api_responses => /api/responses/count(.:format)
  count_api_responses_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[6,"count",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dashboard => (/:locale)/dashboards/:id(.:format)
  dashboard_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["locale","format"], [2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"dashboards",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dashboards => (/:locale)/dashboards(.:format)
  dashboards_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"dashboards",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// duplicate_api_category => /api/categories/:id/duplicate(.:format)
  duplicate_api_category_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"categories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"duplicate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// duplicate_api_question => /api/questions/:id/duplicate(.:format)
  duplicate_api_question_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"questions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"duplicate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// duplicate_api_survey => /api/surveys/:id/duplicate(.:format)
  duplicate_api_survey_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"duplicate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_survey_publication => (/:locale)/surveys/:survey_id/publication/edit(.:format)
  edit_survey_publication_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"publication",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_survey_response => (/:locale)/surveys/:survey_id/responses/:id/edit(.:format)
  edit_survey_response_path: function(_survey_id, _id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id","id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// generate_excel_survey_responses => (/:locale)/surveys/:survey_id/responses/generate_excel(.:format)
  generate_excel_survey_responses_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[6,"generate_excel",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// identifier_questions_api_survey => /api/surveys/:id/identifier_questions(.:format)
  identifier_questions_api_survey_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"identifier_questions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// ids_for_response_api_records => /api/records/ids_for_response(.:format)
  ids_for_response_api_records_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"records",false]],[7,"/",false]],[6,"ids_for_response",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// image_upload_api_response => /api/responses/:id/image_upload(.:format)
  image_upload_api_response_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"image_upload",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// logout => (/:locale)/logout(.:format)
  logout_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"logout",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_survey => (/:locale)/surveys/new(.:format)
  new_survey_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_survey_response => (/:locale)/surveys/:survey_id/responses/new(.:format)
  new_survey_response_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// questions_count_api_surveys => /api/surveys/questions_count(.:format)
  questions_count_api_surveys_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[6,"questions_count",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"rails",false]],[7,"/",false]],[6,"info",false]],[7,"/",false]],[6,"properties",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// record => (/:locale)/records/:id(.:format)
  record_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["locale","format"], [2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"records",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// records => (/:locale)/records(.:format)
  records_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"records",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_survey => (/:locale)/surveys/:id/report(.:format)
  report_survey_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// root => /(:locale)(.:format)
  root_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[7,"/",false],[1,[3,"locale",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey => (/:locale)/surveys/:id(.:format)
  survey_path: function(_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["id"], ["locale","format"], [2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_archive => (/:locale)/surveys/:survey_id/archive(.:format)
  survey_archive_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"archive",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_build => (/:locale)/surveys/:survey_id/build(.:format)
  survey_build_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"build",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_finalize => (/:locale)/surveys/:survey_id/finalize(.:format)
  survey_finalize_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"finalize",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_public_response => (/:locale)/surveys/:survey_id/public_response(.:format)
  survey_public_response_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"public_response",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_publication => (/:locale)/surveys/:survey_id/publication(.:format)
  survey_publication_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"publication",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_response => (/:locale)/surveys/:survey_id/responses/:id(.:format)
  survey_response_path: function(_survey_id, _id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id","id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// survey_responses => (/:locale)/surveys/:survey_id/responses(.:format)
  survey_responses_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"responses",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// surveys => (/:locale)/surveys(.:format)
  surveys_path: function(options) {
  if (!options){ options = {}; }
  return Utils.build_path([], ["locale","format"], [2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// unpublish_survey_publication => (/:locale)/surveys/:survey_id/publication/unpublish(.:format)
  unpublish_survey_publication_path: function(_survey_id, options) {
  if (!options){ options = {}; }
  return Utils.build_path(["survey_id"], ["locale","format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[1,[2,[7,"/",false],[3,"locale",false]],false],[7,"/",false]],[6,"surveys",false]],[7,"/",false]],[3,"survey_id",false]],[7,"/",false]],[6,"publication",false]],[7,"/",false]],[6,"unpublish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  }}
;

  window.Routes.options = defaults;

}).call(this);
