// true: the query returns a result, false: the query doesn't return a result
// un = unskippable query, no skippable equivalent
// ut = unskippable query, if true also execute the skippable equivalent
// uf = unskippable query, if false also execute the skippable equivalent
// s = skippable query
let flask = {
    "COOKIE_QUERIES": {
        "Cookie-name-prefixes": {
            "ut_session_cookie_name_manually_set": [false, ""],
            "ut_remember_cookie_name_manually_set": [false, ""],
            "s_remember_cookie_name_prefix": [false, ""],
            "s_session_cookie_name_prefix": [false, ""]
        },
        "Domain-cookie-attribute": {
            "uf_domain_attribute_remember_cookie": [false, ""],
            "uf_domain_attribute_session_cookie": [false, ""],
            "s_domain_attribute_remember_cookie_manually_disabled": [false, ""],
            "s_domain_attribute_session_cookie_manually_disabled": [false, ""]
        },
        "Expires-cookie-attribute": {
            "ut_expires_attribute_remember_cookie_manually_set": [false, ""],
            "ut_expires_attribute_session_cookie_manually_set": [false, ""],
            "s_expires_attribute_remember_cookie": [false, ""],
            "s_expires_attribute_session_cookie": [false, ""],
        },
        "HTTPOnly-cookie-attribute": {
            "un_httponly_attribute_remember_cookie": [false, ""],
            "un_httponly_attribute_session_cookie": [false, ""]
        },
        "Samesite-cookie-attribute": {
            "ut_samesite_attribute_remember_cookie_manually_set": [false, ""],
            "ut_samesite_attribute_session_cookie_manually_set": [false, ""],
            "s_samesite_attribute_remember_cookie": [false, ""],
            "s_samesite_attribute_session_cookie": [false, ""]
        },
        "Secure-cookie-attribute": {
            "ut_secure_attribute_remember_cookie": [false, ""],
            "ut_secure_attribute_session_cookie": [false, ""],
            "s_secure_attribute_remember_cookie_manually_disabled": [false, ""],
            "s_secure_attribute_session_cookie_manually_disabled": [false, ""]
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
    "LOGOUT_QUERIES": {
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
    "EXTRA_QUERIES": {
        /*
        "Flask-login-open-redirect-after-login": {
            "open_redirect": [false, ""]
        },
        */
        "Flask-login-session-protection": {
            "uf_session_protection_basic": [false, ""],
            "s_session_protection": [false, ""],
            "s_session_protection_strong": [false, ""]
        },
        "Incorrect-config-changes": {
            "un_incorrect_config_changes": [false, ""]
        }
    },
    "SECRET_KEY_QUERIES": {
        "Secret-key": {
            "un_secret_key": [false, ""]
        }
    }
}

function getFlaskQueries() { return flask; }

let django = {
    "COOKIE_QUERIES": {
        "Cookie-name-prefixes": {
            "un_session_cookie_name_prefix": [false, ""]
        },
        "Domain-cookie-attribute": {
            "un_domain_attribute_session_cookie": [false, ""]
        },
        "Expires-cookie-attribute": {
            "un_expires_attribute_session_cookie": [false, ""]
        },
        "HTTPOnly-cookie-attribute": {
            "un_httponly_attribute_session_cookie": [false, ""]
        },
        "Samesite-cookie-attribute": {
            "un_samesite_attribute_session_cookie": [false, ""]
        },
        "Secure-cookie-attribute": {
            "un_secure_attribute_session_cookie": [false, ""]
        }
    },
    "SERIALIZATION_QUERIES": {
        "Session-serializer": {
            "un_session_serializer": [false, ""]
        }
    },
    "LOGOUT_QUERIES": {
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
    "SECRET_KEY_QUERIES": {
        "Secret-key": {
            "un_secret_key": [false, ""]
        }
    },
    "LOGIN_QUERIES": {
        "Redirect-everything-to-HTTPS": {
            "un_secure_ssl_redirect": [false, ""]
        }
    }
}

function getDjangoQueries() { return django; }

let descriptions = {
    "COOKIE_QUERIES": {
        "Cookie-name-prefixes": {
            "session_cookie_name_manually_set": "Session cookie name is manually set",
            "remember_cookie_name_manually_set": "Remember cookie name is manually set",
            "remember_cookie_name_prefix": "Remember cookie name does not contain the prefix __Host- or __Secure-",
            "session_cookie_name_prefix": "Session cookie name does not contain the prefix __Host- or __Secure-"
        },
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
        "Samesite-cookie-attribute": {
            "samesite_attribute_remember_cookie_manually_set": "SameSite remember cookie attribute is manually set",
            "samesite_attribute_session_cookie_manually_set": "SameSite session cookie attribute is manually set",
            "samesite_attribute_remember_cookie": "SameSite remember cookie attribute not set",
            "samesite_attribute_session_cookie": "SameSite session cookie attribute not set"
        },
        "Secure-cookie-attribute": {
            "secure_attribute_remember_cookie": "Secure remember cookie attribute not set",
            "secure_attribute_session_cookie": "Secure session cookie attribute not set",
            "secure_attribute_remember_cookie_manually_disabled": "Secure remember cookie attribute manually disabled",
            "secure_attribute_session_cookie_manually_disabled": "Secure session cookie attribute manually disabled"
        }
    },
    "LOGOUT_QUERIES": {
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
    "EXTRA_QUERIES": {
        "Flask-login-session-protection": {
            "session_protection_basic": "Session Protection is set to basic but no fresh login required found",
            "session_protection": "Session Protection is manually disabled",
            "session_protection_strong": "Session Protection is set to strong"
        },
        "Incorrect-config-changes": {
            "incorrect_config_changes": "Incorrect Config Changes"
        }
    },
    "SECRET_KEY_QUERIES": {
        "Secret-key": {
            "secret_key": "Secret key is hardcoded"
        }
    },
    "SERIALIZATION_QUERIES": {
        "Session-serializer": {
            "session_serializer": "Using custom or unsafe serializers"
        }
    },
    "LOGIN_QUERIES": {
        "Redirect-everything-to-HTTPS": {
            "secure_ssl_redirect": "Login page/form sent over HTTP"
        }
    }
}

function getDescriptions() { return descriptions; }

export { getFlaskQueries, getDjangoQueries, getDescriptions }
