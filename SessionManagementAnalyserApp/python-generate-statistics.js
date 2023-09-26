import { getFlaskQueries, getDjangoQueries } from './python-datastructures.js';
import * as fs from 'fs';

function readQueryResults(outputLocation, queryName) {
    let lines = fs.readFileSync(outputLocation + "/" + queryName + ".txt", 'utf-8').split("\n");
    lines.pop();
    if (lines.length > 2) {
        return true;
    } else {
        return false;
    }
}

function countRepos(counter, framework, root_dir) {
    if (framework === "flask") {
        let flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                for (let [file, arr] of Object.entries(files)) {
                    if (readQueryResults(root_dir + "/" + dir, file)) {
                        if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                            counter[key][dir][file]++;
                        } else {
                            if (counter[key] === undefined) {
                                counter[key] = {}
                            }
                            if (counter[key][dir] === undefined) {
                                counter[key][dir] = {}
                            }
                            counter[key][dir][file] = 1;
                        }
                    } else {
                        if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                            if (counter[key] === undefined) {
                                counter[key] = {}
                            }
                            if (counter[key][dir] === undefined) {
                                counter[key][dir] = {}
                            }
                            counter[key][dir][file] = 0;
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
                    if (readQueryResults(root_dir + "/" + dir, file)) {
                        if (counter[key] !== undefined && counter[key][dir] !== undefined && counter[key][dir][file] !== undefined) {
                            counter[key][dir][file]++;
                        } else {
                            if (counter[key] === undefined) {
                                counter[key] = {}
                            }
                            if (counter[key][dir] === undefined) {
                                counter[key][dir] = {}
                            }
                            counter[key][dir][file] = 1;
                        }
                    } else {
                        if (counter[key] === undefined || counter[key][dir] === undefined || counter[key][dir][file] === undefined) {
                            if (counter[key] === undefined) {
                                counter[key] = {}
                            }
                            if (counter[key][dir] === undefined) {
                                counter[key][dir] = {}
                            }
                            counter[key][dir][file] = 0;
                        }
                    }
                }
            }
        }
    }
    return counter;
}

// TODO make it prettier, finish it, add django and Flask-login support, fix "HSTS activated without include subdomains and cookie set for a parent domain"
function generateStatsPage(counter, total, flask_total, django_total, root_dir) {
    let html = '<html>\
        <head>\
        <!--Load the AJAX API-->\
            <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>\
            <script type="text/javascript">\
                google.charts.load("current", {"packages":["corechart"]});\
                google.charts.setOnLoadCallback(drawChart);\
                function drawChart() {\
                    var data = new google.visualization.DataTable();\
                    data.addColumn("string", "Vulnerability");\
                    data.addColumn("number", "Number of Repos");\
                    data.addRows([\
                        ["Secure cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"] + '],\
                        ["HSTS not activated", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header"]["HSTS_header"] + '],\
                        ["HSTS activated without include subdomains and cookie set for a parent domain", ' + counter["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"] + '],\
                        ["HTTPOnly cookie attribute not set", ' + counter["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"] + ']\
                    ]);\
                    var options = {"title":"Session Hijacking","width":1000,"height":300};\
                    var chart = new google.visualization.BarChart(document.getElementById("chart_div"));\
                    chart.draw(data, options);\
                }\
            </script>\
        </head>\
        <body>\
            <div id="chart_div"></div>\
        </body>\
    </html>';
    fs.writeFileSync(root_dir + '/stats.html', html);
    console.log(JSON.stringify(counter) + "\n");
    console.log(total + "\n");
    console.log(flask_total + "\n");
    console.log(django_total + "\n");
}

export { countRepos, generateStatsPage }
