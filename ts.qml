
/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.2
import bb.data 1.0
import lib.anpho 1.0
NavigationPane {
    id: nav
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            onTriggered: {
                var page = Qt.createComponent("about.qml").createObject(nav);
                nav.push(page)
            }
        }
        actions: [
            ActionItem {
                title: qsTr("Review")
                imageSource: "asset:///icon/ic_open.png"
                onTriggered: {
                    Qt.openUrlExternally("http://appworld.blackberry.com/webstore/content/59963510")
                }
            }
        ]
    }
    property string state_loading: qsTr("Loading RSS")
    property string state_done: qsTr("RSS Loaded")
    property string state_error: qsTr("RSS load failed")
    Page {
        titleBar: TitleBar {
            title: qsTr("Penti News")
            scrollBehavior: TitleBarScrollBehavior.NonSticky
        }

        Container {
            layout: DockLayout {

            }
            ListView {
                id: tugualist
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                dataModel: ArrayDataModel {
                    id: adm
                }
                function requestOpenViewer(uri) {
                    var page = Qt.createComponent("webviewer.qml").createObject(nav);
                    page.uri = uri;
                    nav.push(page)
                }
                scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                attachedObjects: [
                    LayoutUpdateHandler {
                        onLayoutFrameChanged: {
                            tugualist.wwidth = layoutFrame.width
                        }
                    }
                ]
                property int wwidth: 50
                listItemComponents: [
                    ListItemComponent {
                        type: ""
                        Container {
                            gestureHandlers: [
                                TapHandler {
                                    onTapped: {
                                        itemroot.ListItem.view.requestOpenViewer(ListItemData.description)

                                    }
                                }
                            ]
                            id: itemroot
                            horizontalAlignment: HorizontalAlignment.Fill
                            leftPadding: 10.0
                            topPadding: 10.0
                            rightPadding: 10.0
                            bottomPadding: 10.0
                            property string fulltitle: ListItemData.title
                            property int splitindex: ListItemData.title.indexOf(String.fromCharCode(12305)) + 1
                            property string title_intro: ListItemData.title.substring(splitindex)
                            property string readurl: ListItemData.description
                            Header {
                                subtitle: ListItemData.title.substring(0, ListItemData.title.indexOf(String.fromCharCode(12305)) + 1).trim()
                            }
                            Container {
                                layout: DockLayout {

                                }
                                WebImageView {
                                    url: ListItemData.imgurl
                                    scalingMethod: ScalingMethod.AspectFill
                                    loadEffect: ImageViewLoadEffect.FadeZoom
                                    preferredWidth: itemroot.ListItem.view.wwidth
                                    preferredHeight: preferredWidth /2
                                    id: iconOnLeft
                                    horizontalAlignment: HorizontalAlignment.Fill
                                }
                                Container {
                                    background: Color.create("#acffffff")
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Bottom
                                    topPadding: 20.0
                                    leftPadding: 20.0
                                    bottomPadding: 20.0
                                    rightPadding: 20.0
                                    Label {
                                        multiline: true
                                        text: ListItemData.title.substring(ListItemData.title.indexOf(String.fromCharCode(12305)) + 1)
                                        textStyle.color: Color.Black
                                        textStyle.textAlign: TextAlign.Left
                                    }
                                }

                            }
                        }
                    }
                ]
            }
            Container {
                id: stateContainer
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                ActivityIndicator {
                    running: true
                    id: act
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Label {
                    text: state_loading
                    id: statelabel
                    onTextChanged: {
                        if (text != state_loading) {
                            act.running = false;
                        }
                    }
                }
            }
        }
        onCreationCompleted: {
            ds.load()
        }
        attachedObjects: [
            DataSource {
                id: ds
                source: "http://dapenti.com/blog/tuguaapp.asp"
                remote: true
                type: DataSourceType.Xml
                onDataLoaded: {
                    console.log(JSON.stringify(data))
                    if (! adm.isEmpty()) {
                        adm.clear()
                    }
                    adm.append(data.item)
                    stateContainer.visible = false;
                }
                onError: {
                    console.log(errorMessage);
                    statelabel.text = errorMessage
                }
                query: "rss/channel"
            }
        ]
    }

}


--








-----------------------------------------------
---------------------------------------------

import bb.cascades 1.2

Page {
    property bool darkmode: _app.getValue("darkmode", "false") == "true"
    property alias uri: webv.url
    titleBar: TitleBar {
        title: webv.title
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    actions: [
        ActionItem {
            title: qsTr("Open in browser")
            onTriggered: {
                Qt.openUrlExternally(uri)
            }
            imageSource: "asset:///icon/ic_open.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: qsTr("Dark mode")
            imageSource: darkmode ? "asset:///icon/ic_disable.png" : "asset:///icon/ic_enable.png"
            onTriggered: {
                if (darkmode) {
                    webv.settings.userStyleSheetLocation = "blank.css"
                } else {
                    webv.settings.userStyleSheetLocation = "dark.css"
                }
                darkmode = ! darkmode
                _app.setValue("darkmode", darkmode);
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    Container {
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill

        background: Color.Black
        ScrollView {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollRole: ScrollRole.Main
            WebView {
                id: webv
                horizontalAlignment: HorizontalAlignment.Fill
                preferredHeight: Infinity
                settings.userStyleSheetLocation: darkmode ? "dark.css" : "blank.css"
                onNavigationRequested: {
                    if (url.toString().trim().length == 0) {
                        return;
                    }
                    if (request.navigationType == WebNavigationType.LinkClicked || request.navigationType == WebNavigationType.OpenWindow) {
                        request.action = WebNavigationRequestAction.Ignore
                        var page = Qt.createComponent("webviewer.qml").createObject(nav);
                        page.uri = request.url;
                        nav.push(page)
                    }
                }
                settings.userAgent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
                settings.defaultFontSizeFollowsSystemFontSize: true
                settings.zoomToFitEnabled: true
                settings.activeTextEnabled: false

            }
        }
    }
}
