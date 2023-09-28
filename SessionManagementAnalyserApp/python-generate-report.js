import * as fs from 'fs';

function generateCSS(dir) {
    let css = ".styled-table {\nborder-collapse: collapse;\nfont-size: 0.9em;\nfont-family: sans-serif;\nmin-width: 100%;\nbox-shadow: 0 0 20px rgba(0, 0, 0, 0.15);\n}\n\n";
    css += ".styled-table thead tr {\nbackground-color: #7459C6;\ncolor: #ffffff;\ntext-align: left;\n}\n\n";
    css += ".styled-table th,\n.styled-table td {\npadding: 12px 15px;\n}\n\n";
    css += ".styled-table tbody tr {\nborder-bottom: 1px solid #dddddd;\n}\n\n";
    css += ".styled-table tbody tr:nth-of-type(even) {\nbackground-color: #f3f3f3;\n}\n\n";
    css += ".styled-table tbody tr:last-of-type {\nborder-bottom: 2px solid #7459C6;\n}\n\n";
    css += ".collapsible {\nbackground-color: #777;\ncolor: white;\ncursor: pointer;\npadding: 18px;\nwidth: 100%;\nborder: none;\ntext-align: left;\noutline: none;\nfont-size: 15px;\n}\n\n";
    css += ".active, .collapsible:hover {\nbackground-color: #7459C6;\n}\n\n";
    css += ".content {\nmargin-top: 1em;\nmargin-bottom: 1em;\ndisplay: none;\noverflow: hidden;\n}\n\n";
    css += ".header {\npadding: 60px;\nmargin-bottom: 1em;\ntext-align: center;\nbackground: #780098;\ncolor: white;\nfont-family: Arial;\nfont-size: 25px;\n}\n\n";
    fs.writeFileSync(dir + '/style.css', css);
}

function aux(key1, key2, key3, obj, output) {
    if (obj[key1][key2][key3][0]) {
        if (output === "") {
            return obj[key1][key2][key3][1].slice(2, -4);
        } else {
            return output;
        }
    } else {
        return "";
    }
}

// TODO make it prettier
export function generateReport(results, lib, dir) {
    generateCSS(dir);
    let html = "";
    if (lib === "Flask/Flask-login") {
        html += '<html><head><link rel="stylesheet" href="style.css"></head><body><div class="header"><h1>' + lib + " Report - Client Side Sessions (It will be prettier)</h1></div>";
        html += '<button type="button" class="collapsible">Post Login Security</button><div class="content">';

        html += '<button type="button" class="collapsible">Session Hijacking</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Secure cookie attribute not set</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Secure-cookie-attribute", "secure_attribute_session_cookie", results, "") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Secure-cookie-attribute", "secure_attribute_remember_cookie", results, "") + "</td></tr>";
        html += "<tr><td>HSTS not activated</td>";
        html += "<td>" + aux("FLASK_HSTS_QUERIES", "HSTS-header", "HSTS_header", results, "") + "</td>";
        html += "<td>N/A</td></tr>";
        html += "<tr><td>HSTS activated without include subdomains option and cookie set for a parent domain</td>";
        if (results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"][0] && results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_session_cookie"][0]) {
            html += "<td>HSTS is activated without the includeSubDomains option and the cookie is set for a parent domain (for more information see ./HSTS-header-and-cookie-domain)</td>";
        } else { html += "<td></td>"; }
        if (results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"][0] && results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_remember_cookie"][0]) {
            html += "<td>HSTS is activated without the includeSubDomains option and the cookie is set for a parent domain (for more information see ./HSTS-header-and-cookie-domain)</td></tr>";
        } else { html += "<td></td></tr>"; }
        html += "<tr><td>HTTPOnly cookie attribute not set</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "HTTPOnly-cookie-attribute", "httponly_attribute_session_cookie", results, "Session cookie is accessible via javascript (HTTPOnly attribute set to false) (for more information see ./HTTPOnly-cookie-attribute)") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "HTTPOnly-cookie-attribute", "httponly_attribute_remember_cookie", results, "Remember cookie is accessible via javascript (HTTPOnly attribute set to false) (for more information see ./HTTPOnly-cookie-attribute)") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">General Recommendations (could allow both hijacking and fixation)</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Domain cookie attribute set</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Domain-cookie-attribute", "domain_attribute_session_cookie", results, "Session cookie domain attribute is set (for more information see ./Domain-cookie-attribute)") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Domain-cookie-attribute", "domain_attribute_remember_cookie", results, "Remember cookie domain attribute is set (for more information see ./Domain-cookie-attribute)") + "</td></tr>";
        html += "<tr><td>Expires cookie attribute set to a duration that is too long (greater than 30 days)</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Expires-cookie-attribute", "expires_attribute_session_cookie", results, "") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Expires-cookie-attribute", "expires_attribute_remember_cookie", results, "") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Session Fixation</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>HSTS not activated or activated without the include subdomains option</td>";
        html += "<td>" + aux("FLASK_HSTS_QUERIES", "HSTS-header-subdomains", "HSTS_header_subdomains", results, "") + "</td>";
        html += "<td>N/A</td></tr>";
        html += "<tr><td>Cookie name does not contain the prefix __Host- or __Secure-</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Cookie-name-prefixes", "name_prefix_session_cookie", results, "") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Cookie-name-prefixes", "name_prefix_remember_cookie", results, "") + "</td></tr>";
        html += "<tr><td>Initially accept a session/user ID generated by the user and use that for the current session</td>";
        html += "<td>N/A</td>";
        html += "<td>" + aux("FLASK_SERIALIZATION_QUERIES", "Cookie-user-ID-serialization", "cookie_user_id_serialization", results, "The user ID is hardcoded and not randomly generated (for more information see ./Cookie-user-ID-serialization)") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Cookie Tampering/Forging</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Weak Signature</td>";
        html += "<td>" + aux("FLASK_SECRET_KEY_QUERY", "Flask-secret-key", "secret_key", results, "The secret key is hardcoded (for more information see ./Flask-secret-key)") + "</td>";
        html += "<td>N/A</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">CSRF</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>SameSite cookie attribute not set</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Samesite-cookie-attribute", "samesite_attribute_session_cookie", results, "") + "</td>";
        html += "<td>" + aux("FLASK_COOKIE_QUERIES", "Samesite-cookie-attribute", "samesite_attribute_remember_cookie", results, "") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Insecure Serialization/Deserialization</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Unsafe serializer settings</td>";
        html += "<td>" + aux("FLASK_SERIALIZATION_QUERIES", "Serializer-settings", "serializer_settings", results, "Serialize objects to ASCII-encoded JSON is disabled, so the JSON will be returned as a Unicode string. This has security implications when rendering the JSON into JavaScript in templates (for more information see ./Serializer-settings)") + "</td>";
        html += "<td>N/A</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Library Specific Vulnerabilities</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Session Protection</td>";
        html += "<td>N/A</td>";
        html += "<td>" + aux("FLASK_EXTRA_QUERIES", "Flask-login-session-protection", "session_protection", results, "Session protection is disabled, there is no way to know if the cookies are stolen or not (for more information see ./Flask-login-session-protection)") + "</td></tr>";
        html += "<tr><td>Session Protection Basic</td>";
        html += "<td>N/A</td>";
        html += "<td>" + aux("FLASK_EXTRA_QUERIES", "Flask-login-session-protection", "session_protection_basic", results, "") + "</td></tr>";
        html += "<tr><td>Open Redirect after Login</td>";
        html += "<td>N/A</td>";
        html += "<td>" + aux("FLASK_EXTRA_QUERIES", "Flask-login-open-redirect-after-login", "open_redirect", results, "Found an open redirect vulnerability when redirecting the user after the login (for more information see ./Flask-login-open-redirect-after-login)") + "</td></tr>";
        html += "<tr><td>Incorrect Config Changes</td>";
        html += "<td>" + aux("FLASK_EXTRA_QUERIES", "Incorrect-config-changes", "incorrect_config_changes", results, "Some configuration changes are made after the initialization phase (for more information see ./Incorrect-config-changes)") + "</td>";
        html += "<td>N/A</td></tr>";
        html += '</tbody></table></div>';
        html += '</div>';

        html += '<button type="button" class="collapsible">Logout Security</button><div class="content">';

        html += '<button type="button" class="collapsible">Client Side Session Invalidation</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Session not completely cleared upon logout</td>";
        html += "<td>" + aux("FLASK_LOGOUT_QUERIES", "Clear-permanent-session-on-logout", "clear_session_on_logout", results, "") + "</td>";
        html += "<td>N/A</td></tr>";
        html += '</tbody></table></div>';
        html += '</div>';
    }
    
    if (lib === "Django") {
        if (results["DJANGO_LOGOUT_QUERIES"]["Logout-session-invalidation"]["client_side_session"][0]) {
            html += '<html><head><link rel="stylesheet" href="style.css"></head><body><div class="header"><h1>' + lib + " Report - Client Side Sessions (It will be prettier)</h1></div>";
        } else {
            html += '<html><head><link rel="stylesheet" href="style.css"></head><body><div class="header"><h1>' + lib + " Report - Server Side Sessions (It will be prettier)</h1></div>";
        }
        html += '<button type="button" class="collapsible">Login Security</button><div class="content">';

        html += '<button type="button" class="collapsible">Password Theft</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Login page/form sent over HTTP</td>";
        html += "<td>" + aux("DJANGO_LOGIN_QUERY", "Redirect-everything-to-HTTPS", "secure_ssl_redirect", results, "") + "</td></tr>";
        html += '</tbody></table></div>';
        html += '</div>';

        html += '<button type="button" class="collapsible">Post Login Security</button><div class="content">';

        html += '<button type="button" class="collapsible">Session Hijacking</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Secure cookie attribute not set</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "Secure-cookie-attribute", "secure_attribute_session_cookie", results, "") + "</td></tr>";
        html += "<tr><td>HSTS not activated</td>";
        html += "<td>" + aux("DJANGO_HSTS_QUERIES", "HSTS-header", "HSTS_header", results, "") + "</td></tr>";
        html += "<tr><td>HSTS activated without include subdomains and cookie set for a parent domain</td>";
        if (results["DJANGO_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"][0] && results["DJANGO_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_session_cookie"][0]) {
            html += "<td>HSTS is activated without the includeSubDomains option and the cookie is set for a parent domain (for more information see ./HSTS-header-and-cookie-domain)</td>";
        } else { html += "<td></td>"; }
        html += "<tr><td>HTTPOnly cookie attribute not set</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "HTTPOnly-cookie-attribute", "httponly_attribute_session_cookie", results, "Session cookie is accessible via javascript (HTTPOnly attribute set to false) (for more information see ./HTTPOnly-cookie-attribute)") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">General Recommendations (could allow both hijacking and fixation)</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Domain cookie attribute set</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "Domain-cookie-attribute", "domain_attribute_session_cookie", results, "Session cookie domain attribute is set (for more information see ./Domain-cookie-attribute)") + "</td></tr>";
        html += "<tr><td>Expires cookie attribute set to a duration that is too long (greater than 30 days)</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "Expires-cookie-attribute", "expires_attribute_session_cookie", results, "") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Session Fixation</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>HSTS not activated or activated without the include subdomains option</td>";
        html += "<td>" + aux("DJANGO_HSTS_QUERIES", "HSTS-header-subdomains", "HSTS_header_subdomains", results, "") + "</td></tr>";
        html += "<tr><td>Cookie name does not contain the prefix __Host- or __Secure-</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "Cookie-name-prefixes", "name_prefix_session_cookie", results, "") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Cookie Tampering/Forging</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Weak Signature</td>";
        html += "<td>" + aux("DJANGO_SECRET_KEY_QUERY", "Django-secret-key", "secret_key", results, "The secret key is hardcoded and the app is configured to use client side sessions (for more information see ./Flask-secret-key)") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">CSRF</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>SameSite cookie attribute not set</td>";
        html += "<td>" + aux("DJANGO_COOKIE_QUERIES", "Samesite-cookie-attribute", "samesite_attribute_session_cookie", results, "") + "</td></tr>";
        html += '</tbody></table></div>';

        html += '<button type="button" class="collapsible">Insecure Serialization/Deserialization</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Using custom or unsafe serializers</td>";
        html += "<td>" + aux("DJANGO_SERIALIZATION_QUERIES", "Session-serializer", "session_serializer", results, "Using a custom or unsafe serializer (for more information see ./Session-serializer)") + "</td></tr>";
        html += '</tbody></table></div>';
        html += '</div>';

        html += '<button type="button" class="collapsible">Logout Security</button><div class="content">';

        html += '<button type="button" class="collapsible">Client Side Session Invalidation</button><div class="content"><table class="styled-table"><thead><tr>';
        html += "<th>Vulnerability</th><th>Django</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Using client side sessions</td>";
        html += "<td>" + aux("DJANGO_LOGOUT_QUERIES", "Logout-session-invalidation", "client_side_session", results, "") + "</td></tr>";
        html += '</tbody></table></div>';
        html += '</div>';
    }
    html += '<script> \
    var coll = document.getElementsByClassName("collapsible"); \
    var i; \
    for (i = 0; i < coll.length; i++) { \
        coll[i].addEventListener("click", function() { \
        this.classList.toggle("active"); \
        var content = this.nextElementSibling; \
        if (content.style.display === "block") { \
            content.style.display = "none"; \
        } else { \
            content.style.display = "block"; \
        } \
        }); \
    } \
    </script></body></html>';
    fs.writeFileSync(dir + '/FinalReport.html', html);
}
