import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
	Column {
		width: parent.width
		anchors.centerIn: parent
		Label {
			id: label
			anchors.horizontalCenter: parent.horizontalCenter
			text: app.status_str
		}

		GlassItem {
			id: state
			anchors.horizontalCenter: parent.horizontalCenter
			y: 0 - label.height
			width: parent.width
			height: width
			color: app.status_color
			radius: 0.17
			falloffRadius: 1.2 * radius
			Behavior on color {
				ParallelAnimation {
					FadeAnimation { property: "color.r" }
					FadeAnimation { property: "color.g" }
					FadeAnimation { property: "color.b" }
				}
			}
		}
	}

	CoverActionList {
		id: caAlive
		enabled: app.status === 1

		CoverAction {
			iconSource: "image://theme/icon-cover-cancel"
			onTriggered: app.firstpage.kill()
		}
	}
	CoverActionList {
		id: caDead
		enabled: app.status === 0

		CoverAction {
			iconSource: "image://theme/icon-cover-next"
			onTriggered: app.firstpage.kick()
		}
	}
}
