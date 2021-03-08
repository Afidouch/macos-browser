//
//  WebExtensionsManager.swift
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
import Combine

class WebExtensionsManager {

    static let shared = WebExtensionsManager()

    private init() {
        // Temporary
        activeExtensions = [] //webExtensions.filter({$0.manifest.name == "Borderify" || $0.manifest.name == "Emoji Substitution"})
    }

    @Published var activeExtensions: [WebExtension]

    var webExtensions: [WebExtension] = {
        let url = Bundle.main.bundleURL.appendingPathComponent("Contents/PlugIns/WebExtensions")
        //        print("\(url)")
        let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        let extensionUrls = contents?.filter({ $0.pathExtension.isEmpty })
        return extensionUrls?.compactMap({ WebExtension(path: $0) }) ?? []
    }()

}
