import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as Settings


Page {
	id: page
	function kick() {
		app.status = -1;
		col.load();
		fp.spawnProcess();
	}
	function kill() {
		fp.killProcess();
	}

	// To enable PullDownMenu, place our content in a SilicaFlickable
	SilicaFlickable {
		anchors.fill: parent

		// PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
		PullDownMenu {
			MenuItem {
				text: qsTr("Show Log")
				onClicked: pageStack.push(app.secondpage)
			}
			MenuItem {
				text: qsTr("Settings")
				onClicked: pageStack.push(app.settingspage)
			}
		}

		PageHeader {
			title: qsTr("sail.mek.lu")
		}

		Column {
			id: col;
			width: parent.width
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			function load() {
				var db = Settings.connect();
				fp.port = Settings.readSetting(db, "port");
				fp.symlinks = Settings.readSetting(db, "symlinks") === "1" ? true : false;
				fp.docroot = Settings.readSetting(db, "docroot");
				fp.logfile = Settings.readSetting(db, "logfile");
			}

			Button {
				enabled: app.status === 0
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Launch")
				onClicked: {
					page.kick();
				}
			}

			GlassItem {
				property bool jiddy : false
				id: ball
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - Theme.paddingMedium
				height: width
				radius: rad.value
				falloffRadius: 1.5 * radius
				color: app.status_color
				states: State {
					name: "loading"
					when: status === -1
					PropertyChanges {
						target: ball
						jiddy: true
					}
				}
				transitions: [
					Transition {
						from: ""
						to: "loading"
						reversible: true
						SequentialAnimation {
							loops: Animation.Infinite
							running: /* ball.jiddy && app.status === -1 && */ Qt.application.active
							NumberAnimation {
								properties: "radius"
								from: rad.value
								to: 0.5 * rad.value
								easing.type: Easing.InOutQuad
								duration: tim.value
							}
							NumberAnimation {
								properties: "radius"
								from: 0.5 * rad.value
								to: rad.value
								easing.type: Easing.InOutQuad
								duration: tim.value
							}
						}
					}
				]
				Behavior on color {
					ParallelAnimation {
						FadeAnimation { property: "color.r" }
						FadeAnimation { property: "color.g" }
						FadeAnimation { property: "color.b" }
					}
				}
				MouseArea {
					anchors.fill: ball
					width: ball.width
					height: ball.width
					/*onClicked: ball.jiddy = !ball.jiddy*/
				}
			}

			Button {
				enabled: app.status === 1
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Kill")
				onClicked: {
					page.kill();
				}
			}

			Item {
				id: rad
				property double value: 0.15
			}

			Item {
				id: tim
				property int value: 1200
			}

			/*
			Slider {
				id: rad
				value: 0.15
				minimumValue: 0.0
				maximumValue: 1.0
				valueText: value.toFixed(4)
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
			}

			Slider {
				id: tim
				value: 1200
				minimumValue: 100
				maximumValue: 2000
				valueText: value.toFixed(0)
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
			}
			*/
		}
	}
}
