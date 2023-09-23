import * as fs from 'fs';

export function generateReport(results, lib, dir) {
    let html = "<html><body><h1>" + lib + " Report (It will be prettier)</h1>";
    html += "<h2>Post Login Security</h2>";
    html += "<h3>Session Hijacking</h3><table><thead><tr>";
    if (lib === "Flask/Flask-login") {
        html += "<th>Vulnerability</th><th>Flask</th><th>Flask-login</th>";
        html += "</tr></thead><tbody>";
        html += "<tr><td>Secure cookie attribute not set</td>";
        html += "<td>" + results["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_session_cookie"][1] + "</td>";
        html += "<td>" + results["FLASK_COOKIE_QUERIES"]["Secure-cookie-attribute"]["secure_attribute_remember_cookie"][1] + "</td></tr>";
        html += "<tr><td>HSTS not activated</td>";
        html += "<td>" + results["FLASK_HSTS_QUERIES"]["HSTS-header"]["HSTS_header"][1] + "</td>";
        html += "<td>N/A</td></tr>";
        html += "<tr><td>HSTS activated without include subdomains option and cookie set for a parent domain</td>";
        if (results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"][0] && results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_session_cookie"][0]) {
            html += "<td>HSTS is activated without the includeSubDomains option and the cookie is set for a parent domain</td>";
        } else {
            html += "<td></td>";
        }
        if (results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["HSTS_header_no_subdomains"][0] && results["FLASK_HSTS_QUERIES"]["HSTS-header-and-cookie-domain"]["domain_attribute_remember_cookie"][0]) {
            html += "<td>HSTS is activated without the includeSubDomains option and the cookie is set for a parent domain</td></tr>";
        } else {
            html += "<td></td></tr>";
        }
        html += "<tr><td>HTTPOnly cookie attribute not set</td>";
        html += "<td>" + results["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_session_cookie"][1] + "</td>";
        html += "<td>" + results["FLASK_COOKIE_QUERIES"]["HTTPOnly-cookie-attribute"]["httponly_attribute_remember_cookie"][1] + "</td></tr>";
        html += '</tbody></table></body></html>';
    }
    fs.writeFileSync(dir + '/FinalReport.html', html);
}
