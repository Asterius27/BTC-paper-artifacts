// true: the query returns a result, false: the query doesn't return a result
let flask = {
    "FLASK_COOKIE_QUERIES": {
        "Cookie-name-prefixes": {
            "name_prefix_remember_cookie": [false, ""],
            "name_prefix_session_cookie": [false, ""]
        },
        "Domain-cookie-attribute": {
            "domain_attribute_remember_cookie": [false, ""],
            "domain_attribute_session_cookie": [false, ""]
        },
        "Expires-cookie-attribute": {
            "expires_attribute_remember_cookie": [false, ""],
            "expires_attribute_session_cookie": [false, ""]
        },
        "HTTPOnly-cookie-attribute": {
            "httponly_attribute_remember_cookie": [false, ""],
            "httponly_attribute_session_cookie": [false, ""]
        },
        "Samesite-cookie-attribute": {
            "samesite_attribute_remember_cookie": [false, ""],
            "samesite_attribute_session_cookie": [false, ""]
        },
        "Secure-cookie-attribute": {
            "secure_attribute_remember_cookie": [false, ""],
            "secure_attribute_session_cookie": [false, ""]
        }
    },
    "FLASK_SERIALIZATION_QUERIES": {
        "Cookie-user-ID-serialization": {
            "cookie_user_id_serialization": [false, ""]
        },
        "Serializer-settings": {
            "serializer_settings": [false, ""]
        }
    },
    "FLASK_LOGOUT_QUERIES": {
        "Clear-permanent-session-on-logout": {
            "clear_session_on_logout": [false, ""]
        }
    },
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
    "FLASK_EXTRA_QUERIES": {
        "Flask-login-open-redirect-after-login": {
            "open_redirect": [false, ""]
        },
        "Flask-login-session-protection": {
            "session_protection": [false, ""],
            "session_protection_basic": [false, ""]
        },
        "Incorrect-config-changes": {
            "incorrect_config_changes": [false, ""]
        }
    },
    "FLASK_SECRET_KEY_QUERY": {
        "Flask-secret-key": {
            "secret_key": [false, ""]
        }
    }
}

function getFlaskQueries() { return flask; }

let django = {
    // TODO
}

function getDjangoQueries() { return django; }

export { getFlaskQueries, getDjangoQueries }
