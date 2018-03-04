.pragma library

.import 'database.js' as Db

var api_url = "https://apitest.laji.fi/v0/";
var access_token = "Q1cVCk7I8sc2PCqIbhMHt1rib2FyZwJF9OhUXmxIIAy6R0bSeKEMWgtq47ecYVYo";
var person_token
var response = {};
var response_ready = false;
var xhr = new XMLHttpRequest();
var request_count = 0;
var db;
var page_stack;

function get_person_token() {
    try {
        var person_info = Db.dbGetUser();
        person_token = person_info.person_token;
    }
    catch (err) {
        console.log("Login error: " + err)
        person_token = ""
    }
}

function processRequest(e) {
    console.log(xhr.readyState)
    console.log(xhr.status)

    if (xhr.readyState === 4) {
        if (xhr.status === 200) {
            response = JSON.parse(xhr.responseText);
            response_ready = true
        }
        else {
            var error_message
            try{
                error_message = JSON.parse(xhr.responseText).error.message
            }
            catch (e) {
                error_message = xhr.responseText;
            }
            response_ready = true
            page_stack.push(Qt.resolvedUrl("../components/ErrorPage.qml"), {message: error_message})
            console.log(JSON.parse(xhr.responseText).error.message)
        }
    }
}

function api_qet(ep, params) {
    request_count += 1;
    console.log("request_count: " + request_count)
    params = params || {}
    response_ready = false
    response = {}
    var end_point = ep;
    var parameters = ""

    for (var p in params) {
        parameters += "&" + p + "=" + params[p]
    }

    var request = api_url + end_point + "?access_token=" + access_token + "&personToken=" + person_token + parameters

    xhr.onreadystatechange = processRequest;

    xhr.open('GET', request, true);
    xhr.send();
}

function api_post(ep, send_data, params) {
    params = params || {};
    response_ready = false;
    response = {};
    var end_point = ep;
    var parameters = "";
    for (var p in params) {
        parameters += "&" + p + "=" + params[p];
    }
    var request = api_url + end_point + "?personToken=" + person_token + "&access_token=" + access_token + parameters;
    console.log(request)
    send_data = JSON.stringify(send_data)
    console.log(send_data)

    xhr.onreadystatechange = processRequest;

    xhr.open('POST', request, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");
    xhr.send(send_data);
}

get_person_token();
