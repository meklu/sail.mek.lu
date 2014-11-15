import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/db.js" as Settings


Page {
	id: page
	allowedOrientations: Orientation.All
	function objectifyColor(color) {
		return {
			r: color[0],
			g: color[1],
			b: color[2]
		};
	}
	function parseLine(str) {
		var ret = {
			mStr: str,
			mColor: [ 1.0, 1.0, 1.0 ]
		}, colors = {
			/* partial VT100 color code table */
			"36": [ 0.0, 1.0, 1.0 ],
			"33": [ 1.0, 0.7, 0.0 ],
			"32": [ 0.0, 1.0, 0.0 ],
			"31": [ 1.0, 0.0, 0.0 ]
		}, matches;
		/* Holy regex batman! Since mek.lu only uses per-line color,
		 * this should be mostly fine. */
		matches = str.match(/^\033\[([0-9]+)m(.*?)(\033\[0)m$/);
		if (!matches || matches.length !== 4) {
			return ret;
		}
		/* matches[0]: contains everything
		 * matches[1]: the color number
		 * matches[2]: the string
		 * matches[3]: the color terminator */
		ret.mStr = matches[2];
		if (typeof(colors[matches[1]]) !== "undefined") {
			ret.mColor = colors[matches[1]];
		}
		return ret;
	}
	function pushLine(str) {
		var line = parseLine(str);
		var db = Settings.connect();
		var scrollback = parseInt(Settings.readSetting(db, "scrollback"));
		if (listView.model.count === scrollback) {
			listView.model.remove(0, 1);
		}
		line.mColor = objectifyColor(line.mColor);
		listView.model.append(line);
	}
	Rectangle {
		color: Qt.rgba(0, 0, 0, 0.4)
		height: page.height
		width: page.width
	}
	SilicaListView {
		id: listView
		quickScroll: true
		model: ListModel { }
		anchors.fill: parent
		header: PageHeader {
			title: qsTr("Server Log")
		}
		delegate: ListItem {
			id: delegate
			height: label.height + Theme.paddingSmall
			width: listView.width
			contentHeight: height

			Label {
				id: label
				x: Theme.paddingLarge
				anchors.verticalCenter: parent.verticalCenter
				width: parent.width - x
				font.pixelSize: Theme.fontSizeTiny
				lineHeight: 1
				wrapMode: Text.WordWrap
				textFormat: Text.PlainText
				text: mStr
				color: Qt.rgba(mColor.r, mColor.g, mColor.b, 1.0)
			}
		}

		VerticalScrollDecorator {
			flickable: listView
		}
	}
}
