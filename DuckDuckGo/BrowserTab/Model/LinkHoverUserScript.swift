//
//  LinkHoverUserScript.swift
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BrowserServicesKit

protocol LinkHoverUserScriptDelegate: NSObjectProtocol {

    func mouseDidEnter(_: LinkHoverUserScript, link: String)
    func mouseDidExit(_: LinkHoverUserScript, link: String)

}

class LinkHoverUserScript: NSObject, StaticUserScript {

    private struct MessageName {
        static let mouseDidEnter = "mouseDidEnter"
        static let mouseDidExit = "mouseDidExit"
    }

    weak var delegate: LinkHoverUserScriptDelegate?

    static var injectionTime: WKUserScriptInjectionTime { .atDocumentStart }
    static var forMainFrameOnly: Bool { false }
    static let source = """

    (function() {

            window.onmouseover = function(event) {
                var closestAnchor = event.target.closest('a')
                if (closestAnchor) {
                    window.webkit.messageHandlers.mouseDidEnter.postMessage(closestAnchor.href);
                }
            }
            window.onmouseout = function(event) {
                var closestAnchor = event.target.closest('a')
                if (closestAnchor) {
                    window.webkit.messageHandlers.mouseDidExit.postMessage(closestAnchor.href);
                }
            }

    }) ();
    """

    static var script: WKUserScript = LinkHoverUserScript.makeWKUserScript()

    var messageNames: [String] {
        [MessageName.mouseDidEnter, MessageName.mouseDidExit]
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == MessageName.mouseDidEnter, let link = message.body as? String {
            delegate?.mouseDidEnter(self, link: link)
        } else if message.name == MessageName.mouseDidExit, let link = message.body as? String {
            delegate?.mouseDidExit(self, link: link)
        }
    }

}
