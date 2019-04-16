.import QtQuick.LocalStorage 2.0 as Sql

function getDB() {
    try {
        var db = Sql.LocalStorage.openDatabaseSync("Karttatesti", "1.0", "StorageDatabase", 100000);
        return db;
    } catch (err) {
        console.log("Database error: " + err)
    };
}

function dbInit() {
    var db = Sql.LocalStorage.openDatabaseSync("Karttatesti", "1.0", "StorageDatabase", 100000);
    try {
        db.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS user_data (person_token text, person_id text, name text)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS document_backups (document text)')
        })
    } catch (err) {
        console.log("Database creation error: " + err)
    };
}

function dbCreateUser(pToken, pId, pName) {
    var db = getDB();
    dbDeleteUser();
    var rowid = 0;
    db.transaction(function (tx) {
        tx.executeSql('INSERT INTO user_data VALUES(?, ?, ?)',
                      [pToken, pId, pName]);
        var result = tx.executeSql('SELECT last_insert_rowid()');
        rowid = result.insertId;
    });
    return rowid;
}

function dbGetUser() {
    var db = getDB();
    var person;
    db.transaction(function (tx) {
        var person_info = tx.executeSql('SELECT person_token, person_id, name FROM user_data').rows.item(0);
        person = {"person_token": person_info.person_token, "person_id": person_info.person_id, "name": person_info.name}
    });
    console.log("User data from database: " + JSON.stringify(person));
    return person;
}

function dbDeleteUser() {
    var db = getDB()
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM user_data');
    });
}

function saveDocument(document) {
    var db = getDB();
    var document_string = JSON.stringify(document)
    console.log("Saving document: " + document_string)
    var rowid = 0;
    db.transaction(function (tx) {
        tx.executeSql('INSERT INTO document_backups VALUES(?)',
                      [document_string]);
        var result = tx.executeSql('SELECT last_insert_rowid()');
        rowid = result.insertId;
    });
    return rowid;
}

function getDocuments() {
    var db = getDB();
    var documents;
    db.transaction(function (tx) {
        documents = tx.executeSql('SELECT document FROM document_backups');
    });
    return documents;
}

function deleteDocument(string_document) {
    var db = getDB();
    console.log("Deleting: " + string_document)
    db.transaction(function (tx) {
        tx.executeSql("DELETE FROM document_backups WHERE document='" + string_document + "'")
    });
}

function deleteAllDocuments() {
    var db = getDB();
    console.log("Deleting all document backups")
    db.transaction(function (tx) {
        tx.executeSql("DELETE FROM document_backups")
    });
}
