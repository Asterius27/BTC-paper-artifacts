import { getFlaskQueries, getDjangoQueries, getDescriptions, getConfig } from './python-datastructures.js';
import * as fs from 'fs';

// TODO refactor eliminating duplicate code

let query_errors = 0;

// TODO separate django logout query in using client side sessions and logout is called and using server side sessions and logout is called
function readQueryResults(outputLocation, queryName) {
    let lines = [];
    try {
        lines = fs.readFileSync(outputLocation + "/" + queryName + ".txt", 'utf-8').split("\n");
    } catch (e) {
        query_errors++;
        fs.appendFileSync('./log_stats_generator.txt', "Failed to read query results for: " + outputLocation + "/" + queryName + ".txt" + " Reason: " + e + "\n");
        return [false, true];
    }
    if (outputLocation.endsWith("HSTS-header-and-cookie-domain") && (queryName === "domain_attribute_session_cookie" || queryName === "domain_attribute_remember_cookie")) {
        let aux_lines = [];
        try {
            aux_lines = fs.readFileSync(outputLocation + "/HSTS_header_no_subdomains.txt", 'utf-8').split("\n");
        } catch(e) {
            query_errors++;
            fs.appendFileSync('./log_stats_generator.txt', "Failed to read query results for: " + outputLocation + "/HSTS_header_no_subdomains.txt" + " Reason: " + e + "\n");
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

function readSetFromEnvResults(outputLocation, queryName) {
    try {
        let lines = fs.readFileSync(outputLocation + "/un_list_config_settings_from_env_var.txt", 'utf-8');
        if (lines.includes(queryName)) {
            return true;
        } else {
            return false;
        }
    } catch (e) {
        query_errors++;
        fs.appendFileSync('./log_stats_generator.txt', "Failed to read query results for: " + outputLocation + "/un_list_config_settings_from_env_var.txt" + " Reason: " + e + "\n");
        return false;
    }
}

function countRepos(counter, error_counter, false_positives_counter, framework, root_dir) {
    if (framework === "flask") {
        let flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                for (let [file, arr] of Object.entries(files)) {
                    if (dir + "/" + file !== "HSTS-header-and-cookie-domain/HSTS_header_no_subdomains") {
                        let query_result = readQueryResults(root_dir + "/" + dir, file);
                        if (query_result[0]) {
                            let isAlsoSetFromEnv = readSetFromEnvResults(root_dir + "/Explorative-queries", file);
                            if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                                counter[key][dir][file]++;
                                if (isAlsoSetFromEnv) {
                                    false_positives_counter[key][dir][file]++;
                                }
                            } else {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                    false_positives_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                    false_positives_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 1;
                                error_counter[key][dir][file] = 0;
                                if (isAlsoSetFromEnv) {
                                    false_positives_counter[key][dir][file] = 1;
                                } else {
                                    false_positives_counter[key][dir][file] = 0;
                                }
                            }
                        } else {
                            if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                    false_positives_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                    false_positives_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 0;
                                false_positives_counter[key][dir][file] = 0;
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
                            let isAlsoSetFromEnv = readSetFromEnvResults(root_dir + "/Explorative-queries", file); // TODO the query doesn't exists yet
                            if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                                counter[key][dir][file]++;
                                if (isAlsoSetFromEnv) {
                                    false_positives_counter[key][dir][file]++;
                                }
                            } else {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                    false_positives_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                    false_positives_counter[key][dir] = {};

                                }
                                counter[key][dir][file] = 1;
                                error_counter[key][dir][file] = 0;
                                if (isAlsoSetFromEnv) {
                                    false_positives_counter[key][dir][file] = 1;
                                } else {
                                    false_positives_counter[key][dir][file] = 0;
                                }
                            }
                        } else {
                            if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                                if (counter[key] === undefined) {
                                    counter[key] = {};
                                    error_counter[key] = {};
                                    false_positives_counter[key] = {};
                                }
                                if (counter[key][dir] === undefined) {
                                    counter[key][dir] = {};
                                    error_counter[key][dir] = {};
                                    false_positives_counter[key][dir] = {};
                                }
                                counter[key][dir][file] = 0;
                                false_positives_counter[key][dir][file] = 0;
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
    return [counter, error_counter, false_positives_counter];
}

function initializeCounter(counter, error_counter, false_positives_counter, framework) {
    if (framework === "flask") {
        let flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            counter[key] = {};
            error_counter[key] = {};
            false_positives_counter[key] = {};
            for (let [dir, files] of Object.entries(value)) {
                counter[key][dir] = {};
                error_counter[key][dir] = {};
                false_positives_counter[key][dir] = {};
                for (let [file, arr] of Object.entries(files)) {
                    counter[key][dir][file] = 0;
                    error_counter[key][dir][file] = 0;
                    false_positives_counter[key][dir][file] = 0;
                }
            }
        }
    }
    if (framework === "django") {
        let django_queries = getDjangoQueries();
        for (let [key, value] of Object.entries(django_queries)) {
            counter[key] = {};
            error_counter[key] = {};
            false_positives_counter[key] = {};
            for (let [dir, files] of Object.entries(value)) {
                counter[key][dir] = {};
                error_counter[key][dir] = {};
                false_positives_counter[key][dir] = {};
                for (let [file, arr] of Object.entries(files)) {
                    counter[key][dir][file] = 0;
                    error_counter[key][dir][file] = 0;
                    false_positives_counter[key][dir][file] = 0;
                }
            }
        }
    }
    return [counter, error_counter, false_positives_counter];
}

function getCounterKey(counter, key, dir, file) {
    if (counter[key] !== undefined) {
        if (counter[key][dir] !== undefined) {
            for (let [counter_key, res] of Object.entries(counter[key][dir])) {
                if (counter_key.includes(file)) {
                    return counter_key;
                }
            }
        }
    }
    return "keyNotFound";
}

// TODO test this
function getTooltip(value, total, type, false_positives = 0) {
    let percentage = 0;
    if (total !== 0) {
        percentage =  value * 100 / total;
    }
    if (false_positives === 0) {
        return type + ": " + value + " (" + percentage.toFixed(2) + " %)";
    } else {
        let false_positives_percentage = 0;
        if (value !== 0) {
            false_positives_percentage =  false_positives * 100 / value;
        }
        return type + ": " + value + " (" + percentage.toFixed(2) + " %)\nNumber of potential false positives, meaning it\'s also set from an env var (" + type + "): " + false_positives + " (" + false_positives_percentage.toFixed(2) + " %)";
    }
}

// TODO make it prettier
function generateStatsPage(flask_counter, flask_error_counter, false_positives_counter_flask, django_counter, django_error_counter, false_positives_counter_django, total, flask_total, django_total, failed_repos, custom_session_engine_repos, root_dir) {
    let html = '<html>\n'+
        '<head>\n'+
            '<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>\n'+
            '<script type="text/javascript">\n'+
                'google.charts.load("current", {"packages":["corechart"]});\n';
    let queries_desc = getDescriptions();
    let config = getConfig();
    for (let [key, value] of Object.entries(queries_desc)) {
        html += 'google.charts.setOnLoadCallback(draw' + key + 'Chart);\n';
        html += 'function draw' + key + 'Chart() {\n';
        html += 'var data = new google.visualization.arrayToDataTable([\n';
        html += '["Framework/Library", "Flask/Flask-login", {type: "string", role: "tooltip"}, "Failed Flask Queries", {type: "string", role: "tooltip"}, "Django", {type: "string", role: "tooltip"}, "Failed Django Queries", {type: "string", role: "tooltip"}, {role: "annotation"}],';
        for (let [dir, files] of Object.entries(value)) {
            for (let [file, arr] of Object.entries(files)) {
                let flask_file = getCounterKey(flask_counter, key, dir, file);
                let django_file = getCounterKey(django_counter, key, dir, file);
                html += '["' + queries_desc[key][dir][file] + '", ' + (flask_counter[key]?.[dir]?.[flask_file]|0) + ', "' + getTooltip((flask_counter[key]?.[dir]?.[flask_file]|0), flask_total, "Flask/Flask-login", (false_positives_counter_flask[key]?.[dir]?.[flask_file]|0)) + 
                    '", ' + (flask_error_counter[key]?.[dir]?.[flask_file]|0) + ', "' + getTooltip((flask_error_counter[key]?.[dir]?.[flask_file]|0), flask_total, "Failed Flask Queries") + '", ' + (django_counter[key]?.[dir]?.[django_file]|0) + ', "' + 
                    getTooltip((django_counter[key]?.[dir]?.[django_file]|0), django_total, "Django", (false_positives_counter_django[key]?.[dir]?.[django_file]|0)) + '", ' + (django_error_counter[key]?.[dir]?.[django_file]|0) + ', "' + 
                    getTooltip((django_error_counter[key]?.[dir]?.[django_file]|0), django_total, "Failed Django Queries") + '", ""],\n';
            }
        }
        html += ']);\n';
        html += config[key]["options"];
        html += 'var chart = new google.visualization.BarChart(document.getElementById("' + config[key]["element_id"] + '"));\n';
        html += 'chart.draw(data, options);\n}\n'
    }
    let html_end = '</script>\n'+
            '</head>\n'+
            '<body>\n'+
                '<p>Total number of applications/repos: ' + total + '<br/>Number of applications/repos that were not analyzed because of an error: ' + failed_repos + ', among which ' + custom_session_engine_repos + ' failed because they use a custom session engine (Django)<br/>'+
                'Total number of Flask/Flask-login applications/repos: ' + flask_total + '<br/>Total number of Django applications/repos: ' + django_total + '<br/>'+
                'Total number of queries that failed: ' + query_errors + '<br/></p>\n'+
                '<div>\n'+
                    '<h2>Login Security</h2>\n'+
                    '<div id="password_theft"></div>\n'+
                '</div>\n'+
                '<div>\n'+
                    '<h2>Post Login Security</h2>\n'+
                    '<div id="session_hijacking_chart"></div>\n'+
                    '<div id="session_fixation"></div>\n'+
                    '<div id="cookie_tampering_forging"></div>\n'+
                    '<div id="csrf"></div>\n'+
                    '<div id="insecure_serialization_deserialization"></div>\n'+
                    '<div id="library_specific_vulnerabilities"></div>\n'+
                '</div>\n'+
                '<div>\n'+
                    '<h2>Logout Security</h2>\n'+
                    '<div id="client_side_session_invalidation"></div>\n'+
                '</div>\n'+
                '<div>\n'+
                    '<h2>Signup/Account Management Security</h2>\n'+
                    '<div id="password_hashing"></div>\n'+
                    '<div id="account_deactivation"></div>\n'+
                '</div>\n'+
                '<div>\n'+
                    '<h2>Explorative Queries</h2>\n'+
                    '<div id="explorative_queries"></div>\n'+
                '</div>\n'+
            '</body>\n'+
        '</html>';
    html += html_end;
    fs.writeFileSync(root_dir + '/stats.html', html);
}

/*
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
*/

export { countRepos, generateStatsPage, initializeCounter }
