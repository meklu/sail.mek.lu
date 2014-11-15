import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as Settings


Dialog {
	id: page
	function save() {
		var db = Settings.connect();
		Settings.writeSetting(db, "port", port.text);
		Settings.writeSetting(db, "symlinks", symlinks.checked ? "1" : "0");
		Settings.writeSetting(db, "docroot", docroot.text);
		Settings.writeSetting(db, "logfile", logfile.text);
		Settings.writeSetting(db, "scrollback", scrollback.text);
	}

	function load() {
		var db = Settings.connect();
		port.text = Settings.readSetting(db, "port");
		symlinks.checked = Settings.readSetting(db, "symlinks") === "1" ? true : false;
		docroot.text = Settings.readSetting(db, "docroot");
		logfile.text = Settings.readSetting(db, "logfile");
		scrollback.text = Settings.readSetting(db, "scrollback");
	}
	onOpened: {
		load();
	}
	onAccepted: {
		save();
	}

	Column {
		id: column
		anchors.fill: parent;

		width: page.width
		spacing: Theme.paddingMedium

		DialogHeader {
			title: qsTr("Settings")
			acceptText: qsTr("Save")
			enabled: page.canAccept
		}

		TextField {
			id: port
			width: column.width
			placeholderText: qsTr("Port")
			label: placeholderText
			inputMethodHints: Qt.ImhDigitsOnly
			validator: IntValidator {
				// restrict to non-root ports
				bottom: 1024
				top: 65535
			}
			EnterKey.enabled: text.length > 0
			EnterKey.iconSource: "image://theme/icon-m-enter-next"
			EnterKey.onClicked: docroot.focus = true
		}
		TextSwitch {
			id: symlinks
			text: qsTr("Follow symlinks")
		}
		TextField {
			id: docroot
			width: column.width
			placeholderText: qsTr("Document root")
			label: placeholderText
			EnterKey.enabled: text.length > 0
			EnterKey.iconSource: "image://theme/icon-m-enter-next"
			EnterKey.onClicked: logfile.focus = true
		}
		TextField {
			id: logfile
			width: column.width
			placeholderText: qsTr("Log file")
			label: placeholderText
			EnterKey.enabled: text.length > 0
			EnterKey.iconSource: "image://theme/icon-m-enter-next"
			EnterKey.onClicked: scrollback.focus = true
		}
		TextField {
			id: scrollback
			width: column.width
			placeholderText: qsTr("Scrollback")
			label: placeholderText
			inputMethodHints: Qt.ImhDigitsOnly
			validator: IntValidator {
				bottom: 0
				top: 10000
			}
			EnterKey.enabled: text.length > 0
			EnterKey.iconSource: "image://theme/icon-m-enter-accept"
			EnterKey.onClicked: page.accept()
		}
	}
	canAccept: {
		scrollback.acceptableInput &&
		logfile.acceptableInput &&
		docroot.acceptableInput &&
		port.acceptableInput
	}
}
