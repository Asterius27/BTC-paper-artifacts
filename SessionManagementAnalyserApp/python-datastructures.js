// true: the query returns a result, false: the query doesn't return a result
// The shortest query name (among the pair of skippable and unskippable queries) cannot have more than one different word at the end, e.g. the pair (ut_session_cookie_name_manually_set, s_session_cookie_name_prefix_something) would break everything
// un = unskippable query, no skippable equivalent
// ut = unskippable query, if true also execute the skippable equivalent
// uf = unskippable query, if false also execute the skippable equivalent
// st = skippable query, if skipped the default result of the query is true
// sf = skippable query, if skipped the default result of the query is false
let flask = {
    "SessionHijacking": {
        "Domain-cookie-attribute": {
            "uf_domain_attribute_remember_cookie": [false, ""],
            "uf_domain_attribute_session_cookie": [false, ""],
            "sf_domain_attribute_remember_cookie_manually_disabled": [false, ""],
            "sf_domain_attribute_session_cookie_manually_disabled": [false, ""]
        },
        "Expires-cookie-attribute": {
            "un_refresh_each_request_remember_cookie": [false, ""],
            "un_refresh_each_request_session_cookie": [false, ""],
            "ut_expires_attribute_remember_cookie_manually_set": [false, ""],
            "ut_expires_attribute_session_cookie_manually_set": [false, ""],
            "st_expires_attribute_remember_cookie": [false, ""],
            "sf_expires_attribute_session_cookie": [false, ""],
        },
        "HTTPOnly-cookie-attribute": {
            "un_httponly_attribute_remember_cookie": [false, ""],
            "un_httponly_attribute_session_cookie": [false, ""]
        },
        "Secure-cookie-attribute": {
            "ut_secure_attribute_remember_cookie": [false, ""],
            "ut_secure_attribute_session_cookie": [false, ""],
            "sf_secure_attribute_remember_cookie_manually_disabled": [false, ""],
            "sf_secure_attribute_session_cookie_manually_disabled": [false, ""]
        }
    },
    "SessionFixation": {
        "Cookie-name-prefixes": {
            "ut_session_cookie_name_manually_set": [false, ""],
            "ut_remember_cookie_name_manually_set": [false, ""],
            "st_remember_cookie_name_prefix": [false, ""],
            "st_session_cookie_name_prefix": [false, ""]
        }
    },
    "CSRF": {
        "Samesite-cookie-attribute": {
            "ut_samesite_attribute_remember_cookie_manually_set": [false, ""],
            "ut_samesite_attribute_session_cookie_manually_set": [false, ""],
            "st_samesite_attribute_remember_cookie": [false, ""],
            "st_samesite_attribute_session_cookie": [false, ""]
        }
    },
    /*
    "FLASK_SERIALIZATION_QUERIES": {
        "Cookie-user-ID-serialization": {
            "cookie_user_id_serialization": [false, ""]
        },
        "Serializer-settings": {
            "serializer_settings": [false, ""]
        }
    },
    */
    "ClientSideSessionIvalidation": {
        "Clear-permanent-session-on-logout": {
            "un_clear_session_on_logout": [false, ""]
        },
        "Logout-function-is-called": {
            "un_logout_function_is_called": [false, ""]
        }
    },
    /*
    "FLASK_HSTS_QUERIES": {
        "HSTS-header": {
            "HSTS_header": [false, ""]
        },
        "HSTS-header-and-cookie-domain": {
            "HSTS_header_no_subdomains": [false, ""],
            "domain_attribute_remember_cookie": [false, ""],
            "domain_attribute_session_cookie": [false, ""]
        },
        "HSTS-header-subdomains": {
            "HSTS_header_subdomains": [false, ""]
        }
    },
    */
    "LibraryVulnerabilities": {
        /*
        "Flask-login-open-redirect-after-login": {
            "open_redirect": [false, ""]
        },
        */
        "Flask-login-session-protection": {
            "uf_session_protection_basic": [false, ""],
            "sf_session_protection": [false, ""],
            "sf_session_protection_strong": [false, ""]
        },
        "Incorrect-config-changes": {
            "un_incorrect_config_changes": [false, ""]
        },
        "Fresh-login-restrictions": {
            "un_no_fresh_login_checks": [false, ""]
        },
        "Login-restrictions": {
            "un_no_authentication_checks": [false, ""],
            "un_no_authentication_checks_general": [false, ""]
        }
    },
    "CookieTampering": {
        "Secret-key": {
            "un_secret_key": [false, ""]
        }
    },
    "ExplorativeQueries": {
        "Explorative-queries": {
            "un_custom_session_interface": [false, ""],
            "un_config_set_from_env_var": [false, ""],
            "un_config_set_from_file_mapping_keys": [false, ""],
            "un_list_config_settings_from_env_var": [false, ""]
        }
    },
    "PasswordHashing": {
        "Password-hashing": {
            "un_flask_bcrypt_is_used": [false, ""],
            "un_argon2_is_used": [false, ""],
            "un_bcrypt_is_used": [false, ""],
            "un_hashlib_is_used": [false, ""],
            "un_passlib_is_used": [false, ""],
            "un_werkzeug_is_used": [false, ""],
            "ut_password_hashing_algorithm_manually_set": [false, ""],
            "ut_password_hashing_rounds_manually_set": [false, ""],
            "sf_password_hashing_algorithm": [false, ""],
            "sf_password_hashing_rounds": [false, ""]
        }
    },
    "AccountDeactivation": {
        "Account-deactivation": {
            "un_deactivation_left_as_default": [false, ""],
            "un_deactivation_manually_set": [false, ""],
            "un_user_class_does_not_override_is_active": [false, ""],
            "un_user_class_extends_usermixin": [false, ""],
            "un_user_class_overrides_is_active": [false, ""],
            "un_user_class_overrides_is_active_always_returns_false": [false, ""],
            "un_user_class_overrides_is_active_always_returns_true": [false, ""],
            "un_user_class_overrides_is_active_custom_boolean_return": [false, ""],
            "un_user_class_overrides_is_active_non_boolean_return": [false, ""],
            "un_deactivation_not_used": [false, ""],
            "ut_deactivated_accounts_login": [false, ""],
            "sf_deactivated_accounts_default": [false, ""],
            "sf_deactivated_accounts_handling": [false, ""]
        }
    },
    "PasswordStrength": {
        "Password-strength": {
            "un_deform_is_used": [false, ""],
            "un_passwordmeter_is_used": [false, ""],
            "un_passwordstrength_is_used": [false, ""],
            "un_flask_wtf_is_used": [false, ""],
            "un_wtforms_is_used": [false, ""],
            "un_form_with_password_field": [false, ""],
            "un_form_with_two_password_fields": [false, ""],
            "un_form_with_password_field_and_validators": [false, ""],
            "un_form_with_password_field_is_validated": [false, ""],
            "un_form_with_password_field_uses_extra_validators_in_validate_method": [false, ""],
            "un_password_custom_checks": [false, ""],
            "un_password_length_check": [false, ""],
            "un_password_regexp_check": [false, ""]
        }
    }
}

function getFlaskQueries() { return flask; }

let django = {
    "SessionHijacking": {
        "Domain-cookie-attribute": {
            "un_domain_attribute_session_cookie": [false, ""]
        },
        "Expires-cookie-attribute": {
            "un_expires_attribute_session_cookie": [false, ""]
        },
        "HTTPOnly-cookie-attribute": {
            "un_httponly_attribute_session_cookie": [false, ""]
        },
        "Secure-cookie-attribute": {
            "un_secure_attribute_session_cookie": [false, ""]
        }
    },
    "SessionFixation": {
        "Cookie-name-prefixes": {
            "un_session_cookie_name_prefix": [false, ""]
        }
    },
    "CSRF": {
        "Samesite-cookie-attribute": {
            "un_samesite_attribute_session_cookie": [false, ""]
        }
    },
    "InsecureSerialization": {
        "Session-serializer": {
            "un_session_serializer": [false, ""]
        }
    },
    "ClientSideSessionIvalidation": {
        "Logout-session-invalidation": {
            "un_client_side_session": [false, ""]
        },
        "Logout-function-is-called": {
            "un_logout_function_is_called": [false, ""]
        }
    },
    /*
    "DJANGO_HSTS_QUERIES": {
        "HSTS-header": {
            "HSTS_header": [false, ""]
        },
        "HSTS-header-and-cookie-domain": {
            "HSTS_header_no_subdomains": [false, ""],
            "domain_attribute_session_cookie": [false, ""]
        },
        "HSTS-header-subdomains": {
            "HSTS_header_subdomains": [false, ""]
        }
    },
    */
    "CookieTampering": {
        "Secret-key": {
            "un_secret_key": [false, ""]
        }
    },
    "PasswordTheft": {
        "Redirect-everything-to-HTTPS": {
            "un_secure_ssl_redirect": [false, ""]
        }
    }
}

function getDjangoQueries() { return django; }

let descriptions = {
    "SessionHijacking": {
        "Domain-cookie-attribute": {
            "domain_attribute_remember_cookie": "Domain remember cookie attribute set",
            "domain_attribute_session_cookie": "Domain session cookie attribute set",
            "domain_attribute_remember_cookie_manually_disabled": "Domain remember cookie attribute manually disabled",
            "domain_attribute_session_cookie_manually_disabled": "Domain session cookie attribute manually disabled"
        },
        "Expires-cookie-attribute": {
            "refresh_each_request_remember_cookie": "Remember cookie lifetime is refreshed at each request",
            "refresh_each_request_session_cookie": "Session is set to permanent and session cookie lifetime is refreshed at each request",
            "expires_attribute_remember_cookie_manually_set": "Expires remember cookie attribute is manually set",
            "expires_attribute_session_cookie_manually_set": "Expires session cookie attribute is manually set",
            "expires_attribute_remember_cookie": "Expires remember cookie attribute set to a duration that is too long (greater than 30 days)",
            "expires_attribute_session_cookie": "Expires session cookie attribute set to a duration that is too long (greater than 30 days)",
        },
        "HTTPOnly-cookie-attribute": {
            "httponly_attribute_remember_cookie": "HTTPOnly remember cookie attribute not set",
            "httponly_attribute_session_cookie": "HTTPOnly session cookie attribute not set"
        },
        "Secure-cookie-attribute": {
            "secure_attribute_remember_cookie": "Secure remember cookie attribute not set",
            "secure_attribute_session_cookie": "Secure session cookie attribute not set",
            "secure_attribute_remember_cookie_manually_disabled": "Secure remember cookie attribute manually disabled",
            "secure_attribute_session_cookie_manually_disabled": "Secure session cookie attribute manually disabled"
        }
    },
    "SessionFixation": {
        "Cookie-name-prefixes": {
            "session_cookie_name_manually_set": "Session cookie name is manually set",
            "remember_cookie_name_manually_set": "Remember cookie name is manually set",
            "remember_cookie_name_prefix": "Remember cookie name does not contain the prefix __Host- or __Secure-",
            "session_cookie_name_prefix": "Session cookie name does not contain the prefix __Host- or __Secure-"
        }
    },
    "CSRF": {
        "Samesite-cookie-attribute": {
            "samesite_attribute_remember_cookie_manually_set": "SameSite remember cookie attribute is manually set",
            "samesite_attribute_session_cookie_manually_set": "SameSite session cookie attribute is manually set",
            "samesite_attribute_remember_cookie": "SameSite remember cookie attribute not set",
            "samesite_attribute_session_cookie": "SameSite session cookie attribute not set"
        }
    },
    "ClientSideSessionIvalidation": {
        "Clear-permanent-session-on-logout": {
            "clear_session_on_logout": "Session not completely cleared upon logout"
        },
        "Logout-function-is-called": {
            "logout_function_is_called": "Logout function is called/used"
        },
        "Logout-session-invalidation": {
            "client_side_session": "Using client side sessions"
        }
    },
    "LibraryVulnerabilities": {
        "Flask-login-session-protection": {
            "session_protection_basic": "Session Protection is set to basic but no fresh login required found",
            "session_protection": "Session Protection is manually disabled",
            "session_protection_strong": "Session Protection is set to strong"
        },
        "Incorrect-config-changes": {
            "incorrect_config_changes": "Some config changes are made after the user has logged in"
        },
        "Fresh-login-restrictions": {
            "no_fresh_login_checks": "The application never checks whether the current login is fresh or not (no fresh login restricted areas of the app)"
        },
        "Login-restrictions": {
            "no_authentication_checks": "The application never checks whether the user is authenticated or not (no login restricted areas of the app)",
            "no_authentication_checks_general": "The application never accesses the current_user object and never uses the @login_required decorator"
        }
    },
    "CookieTampering": {
        "Secret-key": {
            "secret_key": "Secret key is hardcoded"
        }
    },
    "InsecureSerialization": {
        "Session-serializer": {
            "session_serializer": "Using custom or unsafe serializers"
        }
    },
    "PasswordTheft": {
        "Redirect-everything-to-HTTPS": {
            "secure_ssl_redirect": "Login page/form sent over HTTP"
        }
    },
    "ExplorativeQueries": {
        "Explorative-queries": {
            "custom_session_interface": "Using a custom session interface",
            "config_set_from_env_var": "How many repos set the whole flask config object from an environment variable",
            "config_set_from_file_mapping_keys": "How many repos set the whole flask config object using the from_file or from_mapping or fromkeys functions",
            "list_config_settings_from_env_var": "How many repos set one or more config settings from environment variables (using for example os.environ.get())"
        }
    },
    "PasswordHashing": {
        "Password-hashing": {
            "flask_bcrypt_is_used": "Flask-Bcrypt is being used by the application",
            "argon2_is_used": "Argon2 is being used by the application",
            "bcrypt_is_used": "Bcrypt is being used by the application",
            "hashlib_is_used": "Hashlib is being used by the application",
            "passlib_is_used": "Passlib is being used by the application",
            "werkzeug_is_used": "Werkzeug is being used by the application",
            "password_hashing_algorithm_manually_set": "The password hashing algorithm is manually set",
            "password_hashing_rounds_manually_set": "The number of rounds of the hashing algorithm is manually set",
            "password_hashing_algorithm": "Using a bugged hashing algorithm",
            "password_hashing_rounds": "Using less than 12 rounds (default and recommended value) for hashing"
        }
    },
    "AccountDeactivation": {
        "Account-deactivation": {
            "deactivation_left_as_default": "Force parameter (of the login function) is not set, default value is false so deactivated users are not allowed to log in",
            "deactivation_manually_set": "Deactivated users are not allowed to log in (force is manually set to false and not left as default)",
            "user_class_does_not_override_is_active": "There are one or more user classes (in the repo) that don't override is_active (default behaviour is to always return true)",
            "user_class_extends_usermixin": "There are one or more classes (in the repo) that extend Flask-Login's UserMixin",
            "user_class_overrides_is_active": "There are one or more classes (in the repo) that override is_active property (and extend UserMixin)",
            "user_class_overrides_is_active_always_returns_false": "There are one or more classes (in the repo) that override is_active with a property that always returns false",
            "user_class_overrides_is_active_always_returns_true": "There are one or more classes (in the repo) that override is_active with a property that always returns true",
            "user_class_overrides_is_active_custom_boolean_return": "There are one or more classes (in the repo) that override is_active with a property that has some custom logic but always returns a literal (either true or false)",
            "user_class_overrides_is_active_non_boolean_return": "There are one or more classes (in the repo) that override is_active with a property that has some custom logic and might return a boolean that is not a literal",
            "deactivation_not_used": "Deactivated accounts are not allowed to login, but (there exists at least one user class where) is_active behaviour is left as default (always returns true)",
            "deactivated_accounts_login": "Deactivated accounts are allowed to login (force set to true)",
            "deactivated_accounts_default": "Deactivated accounts are allowed to login and (there exists at least one user class where) is_active behaviour is left as default (always returns true)",
            "deactivated_accounts_handling": "Deactivated accounts are allowed to login and (there exists at least one) user class overrides is_active default behaviour with some custom logic"
        }
    },
    "PasswordStrength": {
        "Password-strength": {
            "deform_is_used": "Deform is being used by the application",
            "passwordmeter_is_used": "passwordmeter is being used by the application",
            "passwordstrength_is_used": "password-strength is being used by the application",
            "flask_wtf_is_used": "Flask-WTF is being used by the application",
            "wtforms_is_used": "WTForms is being used by the application",
            "form_with_password_field": "Number of repos with at least one form with a password field",
            "form_with_two_password_fields": "Number of repos with at least one form with two password fields",
            "form_with_password_field_and_validators": "Number of forms with a password field that also has some validators",
            "form_with_password_field_is_validated": "Some forms with a password field (that has some validators) are not being validated",
            "form_with_password_field_uses_extra_validators_in_validate_method": "Some forms have a password field and pass extra validators when calling the validate or validate_on_submit method",
            "password_custom_checks": "Using a custom validator to check password strength",
            "password_length_check": "Length checks are being performed on the password field",
            "password_regexp_check": "The password is being checked using a regexp"
        }
    }
}

function getDescriptions() { return descriptions; }

let config = {
    "SessionHijacking": {
        "options": 'var options = {"title":"Session Hijacking","width":1500,"height":2000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'session_hijacking_chart'
    },
    "SessionFixation": {
        "options": 'var options = {"title":"Session Fixation","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'session_fixation'
    },
    "CSRF": {
        "options": 'var options = {"title":"CSRF","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'csrf'
    },
    "ClientSideSessionIvalidation": {
        "options": 'var options = {"title":"Client Side Session Invalidation","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'client_side_session_invalidation'
    },
    "LibraryVulnerabilities": {
        "options": 'var options = {"title":"Library Specific Vulnerabilities","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'library_specific_vulnerabilities'
    },
    "CookieTampering": {
        "options": 'var options = {"title":"Cookie Tampering/Forging","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'cookie_tampering_forging'
    },
    "InsecureSerialization": {
        "options": 'var options = {"title":"Insecure Serialization/Deserialization","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'insecure_serialization_deserialization'
    },
    "PasswordTheft": {
        "options": 'var options = {"title":"Password Theft","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'password_theft'
    },
    "ExplorativeQueries": {
        "options": 'var options = {"title":"Explorative Queries","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'explorative_queries'
    },
    "PasswordHashing": {
        "options": 'var options = {"title":"Password Hashing","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'password_hashing'
    },
    "AccountDeactivation": {
        "options": 'var options = {"title":"Account Deactivation","width":1500,"height":1600,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'account_deactivation'
    },
    "PasswordStrength": {
        "options": 'var options = {"title":"Password Strength","width":1500,"height":1800,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
        "element_id": 'password_strength'
    }
}

function getConfig() { return config; }

export { getFlaskQueries, getDjangoQueries, getDescriptions, getConfig }
