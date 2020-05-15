.pragma library

.import 'database.js' as Db

var api_url = "https://apitest.laji.fi/v0/";
var access_token = "Q1cVCk7I8sc2PCqIbhMHt1rib2FyZwJF9OhUXmxIIAy6R0bSeKEMWgtq47ecYVYo";

var request_count = 0;
var db;
var page_stack;

function get_person_token() {
    var person_token = ""
    try {
        var person_info = Db.dbGetUser();
        person_token = person_info.person_token;
    }
    catch (err) {
        console.log("Login error: " + err)
    }
    return person_token
}

function processRequest(xhr, callback, e) {

    if (xhr.readyState === 4) {
        console.log(xhr.status)
        var response
        try {
            response = JSON.parse(xhr.responseText);
        }
        catch (e) {
            response = xhr.responseText
        }
        callback(xhr.status, response);
    }
}

function api_qet(callback, end_point, params) {
    var xhr = new XMLHttpRequest();
    request_count += 1;
    console.log("request_count: " + request_count)
    params = params || {}
    //var end_point = ep;
    var parameters = ""

    for (var p in params) {
        parameters += "&" + p + "=" + params[p]
    }

    var request = api_url + end_point + "?access_token=" + access_token + "&personToken=" + get_person_token() + parameters
    console.log(request)
    xhr.onreadystatechange = function() {processRequest(xhr, callback);};

    xhr.open('GET', request, true);
    xhr.send();
}

function api_post(callback, end_point, send_data, params) {
    var xhr = new XMLHttpRequest();
    params = params || {};

    var parameters = "";
    for (var p in params) {
        parameters += "&" + p + "=" + params[p];
    }
    var request = api_url + end_point + "?personToken=" + get_person_token() + "&access_token=" + access_token + parameters;
    console.log(request)
    send_data = JSON.stringify(send_data)
    console.log(send_data)

    xhr.onreadystatechange = function() {processRequest(xhr, callback);};

    xhr.open('POST', request, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");
    xhr.send(send_data);
}

function get_xeno_canto_audio(callback, scientific_name) {
    var xhr = new XMLHttpRequest();

    var xeno_canto_api = "https://www.xeno-canto.org/api/2/recordings?query="

    var request = xeno_canto_api + scientific_name + "+q:A"// + "+cnt:finland"
    console.log(request)
    xhr.onreadystatechange = function() {processRequest(xhr, callback);};

    xhr.open('GET', request, true);
    xhr.send();
}
