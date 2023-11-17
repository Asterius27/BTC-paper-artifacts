import { getFlaskQueries, getDjangoQueries } from './python-datastructures.js';
import * as fs from 'fs';

let query_errors = 0;

// TODO separate django logout query in using client side sessions and logout is called and using server side sessions and logout is called
function readQueryResults(outputLocation, queryName) {
    let lines = [];
    try {
        lines = fs.readFileSync(outputLocation + "/" + queryName + ".txt", 'utf-8').split("\n");
    } catch (e) {
        query_errors++;
        fs.appendFileSync('./log.txt', "Failed to read query results for: " + outputLocation + "/" + queryName + ".txt" + " Reason: " + e + "\n");
        return [false, true];
    }
    if (outputLocation.endsWith("HSTS-header-and-cookie-domain") && (queryName === "domain_attribute_session_cookie" || queryName === "domain_attribute_remember_cookie")) {
        let aux_lines = [];
        try {
            aux_lines = fs.readFileSync(outputLocation + "/HSTS_header_no_subdomains.txt", 'utf-8').split("\n");
        } catch(e) {
            query_errors++;
            fs.appendFileSync('./log.txt', "Failed to read query results for: " + outputLocation + "/HSTS_header_no_subdomains.txt" + " Reason: " + e + "\n");
            return [false, true];
        }
        aux_lines.pop();
        lines.pop();
        if (lines.length > 2 && aux_lines.length > 2) {
            return [true, false];
        } else {
            return [false, false];
        }
    } else {
        lines.pop();
        if (lines.length > 2) {
            return [true, false];
        } else {
            return [false, false];
        }
    }
}

function countRepos(counter, error_counter, framework, root_dir) {
    if (framework === "flask") {
        let flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                for (let [file, arr] of Object.entries(files)) {
                    if (dir + "/" + file !== "HSTS-header-and-cookie-domain/HSTS_header_no_subdomains") {
                        let query_result = readQueryResults(root_dir + "/" + dir, file);
                        if (query_result[0]) {
                            if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                                counter[key][dir][file]++;
                            } else {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 1;
                                error_counter[key][dir][file] = 0;
                            }
                        } else {
                            if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 0;
                                if (query_result[1]) {
                                    error_counter[key][dir][file] = 1;
                                } else {
                                    error_counter[key][dir][file] = 0;
                                }
                            } else {
                                if (query_result[1]) {
                                    error_counter[key][dir][file]++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (framework === "django") {
        let django_queries = getDjangoQueries();
        for (let [key, value] of Object.entries(django_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                for (let [file, arr] of Object.entries(files)) {
                    if (dir + "/" + file !== "HSTS-header-and-cookie-domain/HSTS_header_no_subdomains") {
                        let query_result = readQueryResults(root_dir + "/" + dir, file);
                        if (query_result[0]) {
                            if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                                counter[key][dir][file]++;
                            } else {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};

                                }
                                counter[key][dir][file] = 1;
                                error_counter[key][dir][file] = 0;
                            }
                        } else {
                            if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 0;
                                if (query_result[1]) {
                                    error_counter[key][dir][file] = 1;
                                } else {
                                    error_counter[key][dir][file] = 0;
                                }
                            } else {
                                if (query_result[1]) {
                                    error_counter[key][dir][file]++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return [counter, error_counter];
}

function initializeCounter(counter, error_counter, framework) {
    if (framework === "flask") {
        let flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            counter[key] = {};
            error_counter[key] = {};
            for (let [dir, files] of Object.entries(value)) {
                counter[key][dir] = {};
                error_counter[key][dir] = {};
                for (let [file, arr] of Object.entries(files)) {
                    counter[key][dir][file] = 0;
                    error_counter[key][dir][file] = 0;
                }
            }
        }
    }
    if (framework === "django") {
        let django_queries = getDjangoQueries();
        for (let [key, value] of Object.entries(django_queries)) {
            counter[key] = {};
            error_counter[key] = {};
            for (let [dir, files] of Object.entries(value)) {
                counter[key][dir] = {};
                error_counter[key][dir] = {};
                for (let [file, arr] of Object.entries(files)) {
                    counter[key][dir][file] = 0;
                    error_counter[key][dir][file] = 0;
                }
            }
        }
    }
    return [counter, error_counter];
}

// TODO make it prettier
function generateStatsPage(counter, error_counter, total, flask_total, django_total, failed_repos, custom_session_engine_repos, root_dir) {
    let html = '<html>\
        <head>\
            <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>\
            <script type="text/javascript">\
                google.charts.load("current", {"packages":["corechart"]});\
                google.charts.setOnLoadCallback(drawPasswordTheftChart);\
                google.charts.setOnLoadCallback(drawSessionHijackingChart);\
                google.charts.setOnLoadCallback(drawSessionFixationChart);\
                google.charts.setOnLoadCallback(drawCookieTamperingChart);\
                google.charts.setOnLoadCallback(drawCSRFChart);\
                google.charts.setOnLoadCallback(drawInsecureSerializationChart);\
                google.charts.setOnLoadCallback(drawLibraryVulnerabilitiesChart);\
                google.charts.setOnLoadCallback(drawClientSideSessionIvalidationChart);\
                function drawPasswordTheftChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["Login page/form sent over HTTP", 0, 0, ' + counter["DJANGO_LOGIN_QUERY"]["Redirect-everything-to-HTTPS"]["secure_ssl_redirect"] + ', ' + error_counter["DJANGO_LOGIN_QUERY"]["Redirect-everything-to-HTTPS"]["secure_ssl_redirect"] + ', ""],\
                    ]);\
                    var options = {"title":"Password Theft","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("password_theft"));\
                    chart.draw(data, options);\
                }\
                function drawSessionHijackingChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["Secure session cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"] + ', ' +
                            counter["DJANGO_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"] + ', ""],'+
                        '["Secure session cookie attribute manually disabled", ' + counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie_manually_disabled"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie_manually_disabled"] + ', 0, 0, ""],' +
                        '["Secure remember cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_remember_cookie"] + ', 0, 0, ""],' +
                        '["Secure remember cookie attribute manually disabled", ' + counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_remember_cookie_manually_disabled"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_remember_cookie_manually_disabled"] + ', 0, 0, ""],' +
//                        ["HSTS not activated", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header"]["HSTS_header"] + ', ' + counter["DJANGO_HSTS_QUERIES"]["HSTS-header"]["HSTS_header"] + ', ""],\
//                        ["HSTS activated without include subdomains and session cookie set for a parent domain", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_session_cookie"] + ', ' + counter["DJANGO_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_session_cookie"] + ', ""],\
//                        ["HSTS activated without include subdomains and remember cookie set for a parent domain", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_remember_cookie"] + ', 0, ""],\
                        '["HTTPOnly session cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"] + ', ' + 
                            counter["DJANGO_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"] + ', ""],'+
                        '["HTTPOnly remember cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_remember_cookie"] + ', 0, 0, ""],'+
                        '["Domain session cookie attribute set", ' + counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie"] + ', ' + 
                            counter["DJANGO_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie"] + ', ""],'+
                        '["Domain session cookie attribute set manually disabled", ' + counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie_manually_disabled"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_session_cookie_manually_disabled"] + ', 0, 0, ""],'+
                        '["Domain remember cookie attribute set", ' + counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_remember_cookie"] + ', 0, 0, ""],'+
                        '["Domain remember cookie attribute set manually disabled", ' + counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_remember_cookie_manually_disabled"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Domain-cookie-attribute"]["domain_attribute_remember_cookie_manually_disabled"] + ', 0, 0, ""],'+
                        '["Expires session cookie attribute set to a duration that is too long (greater than 30 days)", ' + counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie"] + ', ' + 
                            counter["DJANGO_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie"] + ', ""],'+
                        '["Expires session cookie attribute is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_session_cookie_manually_set"] + ', 0, 0, ""],'+
                        '["Expires remember cookie attribute set to a duration that is too long (greater than 30 days)", ' + counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_remember_cookie"] + ', 0, 0, ""],'+
                        '["Expires remember cookie attribute is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_remember_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Expires-cookie-attribute"]["expires_attribute_remember_cookie_manually_set"] + ', 0, 0, ""]\
                    ]);\
                    var options = {"title":"Session Hijacking","width":1500,"height":1500,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("session_hijacking_chart"));\
                    chart.draw(data, options);\
                }\
                function drawSessionFixationChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],' +
//                        ["HSTS not activated or activated without the include subdomains option", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header-subdomains"]["HSTS_header_subdomains"] + ', ' + counter["DJANGO_HSTS_QUERIES"]["HSTS-header-subdomains"]["HSTS_header_subdomains"] + ', ""],\
                        '["Session cookie name does not contain the prefix __Host- or __Secure-", ' + counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_session_cookie"] + ', ' + 
                            counter["DJANGO_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_session_cookie"] + ', ""],'+
                        '["Session cookie name is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_session_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_session_cookie_manually_set"] + ', 0, 0, ""],' +
                        '["Remember cookie name does not contain the prefix __Host- or __Secure-", ' + counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_prefix_remember_cookie"] + ', 0, 0, ""],' +
                        '["Remember cookie name is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_remember_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Cookie-name-prefixes"]["name_remember_cookie_manually_set"] + ', 0, 0, ""],' +
//                        ["Initially accept a session/user ID generated by the user and use that for the current session", ' + counter["FLASK_SERIALIZATION_QUERIES"]["Cookie-user-ID-serialization"]["cookie_user_id_serialization"] + ', 0, ""]\
                    ']);\
                    var options = {"title":"Session Fixation","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("session_fixation"));\
                    chart.draw(data, options);\
                }\
                function drawCookieTamperingChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["Secret key is hardcoded", ' + counter["FLASK_SECRET_KEY_QUERY"]["Flask-secret-key"]["secret_key"] + ', ' + error_counter["FLASK_SECRET_KEY_QUERY"]["Flask-secret-key"]["secret_key"] + ', ' + 
                            counter["DJANGO_SECRET_KEY_QUERY"]["Django-secret-key"]["secret_key"] + ', ' + error_counter["DJANGO_SECRET_KEY_QUERY"]["Django-secret-key"]["secret_key"] + ', ""]\
                    ]);\
                    var options = {"title":"Cookie Tampering/Forging","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("cookie_tampering_forging"));\
                    chart.draw(data, options);\
                }\
                function drawCSRFChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["SameSite session cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie"] + ', ' + 
                            counter["DJANGO_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie"] + ', ' + error_counter["DJANGO_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie"] + ', ""],'+
                        '["SameSite session cookie attribute is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_session_cookie_manually_set"] + ', 0, 0, ""],'+
                        '["SameSite remember cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_remember_cookie"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_remember_cookie"] + ', 0, 0, ""],'+
                        '["SameSite remember cookie attribute is manually set", ' + counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_remember_cookie_manually_set"] + ', ' + error_counter["FLASK_COOKIE_QUERIES"]["Samesite-cookie-attribute"]["samesite_attribute_remember_cookie_manually_set"] + ', 0, 0, ""]\
                    ]);\
                    var options = {"title":"CSRF","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("csrf"));\
                    chart.draw(data, options);\
                }\
                function drawInsecureSerializationChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],' +
//                        ["Unsafe serializer settings", ' + counter["FLASK_SERIALIZATION_QUERIES"]["Serializer-settings"]["serializer_settings"] + ', 0, ""],\
                        '["Using custom or unsafe serializers", 0, 0, ' + counter["DJANGO_SERIALIZATION_QUERIES"]["Session-serializer"]["session_serializer"] + ', ' + error_counter["DJANGO_SERIALIZATION_QUERIES"]["Session-serializer"]["session_serializer"] + ', ""]\
                    ]);\
                    var options = {"title":"Insecure Serialization/Deserialization","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("insecure_serialization_deserialization"));\
                    chart.draw(data, options);\
                }\
                function drawLibraryVulnerabilitiesChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["Session Protection is manually disabled", ' + counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection"] + ', ' + error_counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection"] + ', 0, 0, ""],\
                        ["Session Protection is set to basic but no fresh login required found", ' + counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection_basic"] + ', ' + error_counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection_basic"] + ', 0, 0, ""],' +
                        '["Session Protection is set to strong", ' + counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection_strong"] + ', ' + error_counter["FLASK_EXTRA_QUERIES"]["Flask-login-session-protection"]["session_protection_strong"] + ', 0, 0, ""],' +
//                        ["Open Redirect after Login", ' + counter["FLASK_EXTRA_QUERIES"]["Flask-login-open-redirect-after-login"]["open_redirect"] + ', 0, ""],\
                        '["Incorrect Config Changes", ' + counter["FLASK_EXTRA_QUERIES"]["Incorrect-config-changes"]["incorrect_config_changes"] + ', ' + error_counter["FLASK_EXTRA_QUERIES"]["Incorrect-config-changes"]["incorrect_config_changes"] + ', 0, 0, ""]'+
                    ']);\
                    var options = {"title":"Library Specific Vulnerabilities","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("library_specific_vulnerabilities"));\
                    chart.draw(data, options);\
                }\
                function drawClientSideSessionIvalidationChart() {\
                    var data = new google.visualization.arrayToDataTable([\
                        ["Framework/Library", "Flask/Flask-login", "Failed Flask Queries", "Django", "Failed Django Queries", {role: "annotation"}],\
                        ["Logout function is called/used", ' + counter["FLASK_LOGOUT_QUERIES"]["Logout-function-is-called"]["logout_function_is_called"] + ', ' + error_counter["FLASK_LOGOUT_QUERIES"]["Logout-function-is-called"]["logout_function_is_called"] + ', ' + 
                            counter["DJANGO_LOGOUT_QUERIES"]["Logout-function-is-called"]["logout_function_is_called"] + ', ' + error_counter["DJANGO_LOGOUT_QUERIES"]["Logout-function-is-called"]["logout_function_is_called"] + ', ""],' +
                        '["Session not completely cleared upon logout", ' + counter["FLASK_LOGOUT_QUERIES"]["Clear-permanent-session-on-logout"]["clear_session_on_logout"] + ', ' + error_counter["FLASK_LOGOUT_QUERIES"]["Clear-permanent-session-on-logout"]["clear_session_on_logout"] + ', 0, 0, ""],'+
                        '["Using client side sessions", ' + flask_total + ', 0, ' + counter["DJANGO_LOGOUT_QUERIES"]["Logout-session-invalidation"]["client_side_session"] + ', ' + error_counter["DJANGO_LOGOUT_QUERIES"]["Logout-session-invalidation"]["client_side_session"] + ', ""]\
                    ]);\
                    var options = {"title":"Client Side Session Invalidation","width":1500,"height":1000,"legend": {"position": "top", "maxLines": 3},"bar": {"groupWidth": "75%"},"isStacked": true};\
                    var chart = new google.visualization.BarChart(document.getElementById("client_side_session_invalidation"));\
                    chart.draw(data, options);\
                }\
            </script>\
        </head>\
        <body>\
            <p>Total number of applications/repos: ' + total + '<br/>Number of applications/repos that were not analyzed because of an error: ' + failed_repos + ', among which ' + custom_session_engine_repos + ' failed because they use a custom session engine (Django)<br/>\
            Total number of Flask/Flask-login applications/repos: ' + flask_total + '<br/>Total number of Django applications/repos: ' + django_total + '<br/>\
            Total number of queries that failed: ' + query_errors + '<br/></p>\
            <div>\
                <h2>Login Security</h2>\
                <div id="password_theft"></div>\
            </div>\
            <div>\
                <h2>Post Login Security</h2>\
                <div id="session_hijacking_chart"></div>\
                <div id="session_fixation"></div>\
                <div id="cookie_tampering_forging"></div>\
                <div id="csrf"></div>\
                <div id="insecure_serialization_deserialization"></div>\
                <div id="library_specific_vulnerabilities"></div>\
            </div>\
            <div>\
                <h2>Logout Security</h2>\
                <div id="client_side_session_invalidation"></div>\
            </div>\
        </body>\
    </html>';
    fs.writeFileSync(root_dir + '/stats.html', html);
}

export { countRepos, generateStatsPage, initializeCounter }
