.pragma library
.import QtQuick.LocalStorage 2.0 as LS

function connect() {
	var db = LS.LocalStorage.openDatabaseSync(
		"sail.mek.lu",
		"1.0",
		"sail.mek.lu settings",
		16384
	);
	db.transaction(function (tx) {
		tx.executeSql(
			"CREATE TABLE IF NOT EXISTS settings( " +
				"key TEXT PRIMARY KEY, " +
				"value TEXT" +
			");"
		);
	});
	return db;
}

function readSetting(db, key, def) {
	var setting = null;
	db.readTransaction(function (tx) {
		var ret = tx.executeSql(
			"SELECT value FROM settings WHERE key=?;",
			[key]
		);
		if (ret.rows.length === 1) {
			setting = ret.rows.item(0).value;
		}
	});
	if (setting === null) {
		if (typeof(def) !== "undefined") {
			setting = def;
		} else {
			setting = "";
		}
	}
	console.debug("readSetting: " + key + " => " + setting);
	return setting;
}

function writeSetting(db, key, value) {
	console.debug("writeSetting: " + key + " => " + value);
	db.transaction(function (tx) {
		tx.executeSql(
			"DELETE FROM settings WHERE key=?;",
			[key]
		);
		tx.executeSql(
			"INSERT INTO settings VALUES (?, ?);",
			[key, value]
		)
	});
}
