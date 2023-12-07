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
        }
    },
    "CookieTampering": {
        "Secret-key": {
            "un_secret_key": [false, ""]
        }
    },
    "ExplorativeQueries": {
        "Explorative-queries": {
            "un_config_set_from_env_var": [false, ""],
            "un_config_set_from_file_mapping_keys": [false, ""],
            "un_list_config_settings_from_env_var": [false, ""]
        }
    },
    "PasswordHashing": {
        "Password-hashing": {
            "ut_password_hashing_algorithm_manually_set": [false, ""],
            "ut_password_hashing_rounds_manually_set": [false, ""],
            "sf_password_hashing_algorithm": [false, ""],
            "sf_password_hashing_rounds": [false, ""]
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
            "un_config_set_from_env_var": "How many repos set the whole flask config object from an environment variable",
            "un_config_set_from_file_mapping_keys": "How many repos set the whole flask config object using the from_file or from_mapping or fromkeys functions",
            "un_list_config_settings_from_env_var": "How many repos set one or more config settings from environment variables (using for example os.environ.get())"
        }
    },
    "PasswordHashing": {
        "Password-hashing": {
            "ut_password_hashing_algorithm_manually_set": "The password hashing algorithm is manually set",
            "ut_password_hashing_rounds_manually_set": "The number of rounds of the hashing algorithm is manually set",
            "sf_password_hashing_algorithm": "Using a bugged hashing algorithm",
            "sf_password_hashing_rounds": "Using less than 12 rounds (default and recommended value) for hashing"
        }
    }
}

function getDescriptions() { return descriptions; }

let config = {
    "SessionHijacking": {
        "options": 'var options = {"title":"Session Hijacking","width":1500,"height":1800,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\n',
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
    }
}

function getConfig() { return config; }

export { getFlaskQueries, getDjangoQueries, getDescriptions, getConfig }
