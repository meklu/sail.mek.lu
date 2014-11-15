import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.saildotmekdotlu.ForkProcess 1.0
import "js/db.js" as Settings
import "cover"
import "pages"

ApplicationWindow
{
	id: app
	property string status_str : (
		status === 0 ? qsTr("Stopped") :
		status === 1 ? qsTr("Running") :
		status === -1 ? qsTr("Starting") :
		"wot"
	)
	property color status_color : (
		status === 0 ? Qt.rgba(1.0, 0.0, 0.0, 1.0) :
		status === 1 ? Qt.rgba(0.0, 1.0, 0.0, 1.0) :
		status === -1 ? Qt.rgba(1.0, 0.8, 0.0, 1.0) :
		Qt.rgba(1.0, 1.0, 1.0, 1.0)
	)
	/* 0: stopped, 1: running, -1: loading */
	property int status : 0
	/* forkprocess */
	property alias fp : fp
	property alias firstpage : firstpage
	property alias secondpage : secondpage
	property alias settingspage : settingspage
	property alias coverpage : coverpage

	ForkProcess {
		id: fp
		onLineReady: {
			secondpage.pushLine(str);
		}
		onStarted: {
			console.log("started");
			status = 1;
		}
		onStopped: {
			console.log("stopped");
			status = 0;
		}
	}

	FirstPage {
		id: firstpage
	}

	SecondPage {
		id: secondpage
	}

	SettingsPage {
		id: settingspage
	}

	CoverPage {
		id: coverpage
	}

	initialPage: firstpage
	cover: coverpage
}
