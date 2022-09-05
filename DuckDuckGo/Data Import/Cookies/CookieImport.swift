//
//  CookieImport.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

enum CookieImportSource {
    case chromium
    case duckduckgoWebKit
    case firefox
    case safari
}

struct CookieImportResult: Equatable {
    var successful: Int
    var failed: Int

    static func += (left: inout CookieImportResult, right: CookieImportResult) {
        left.successful += right.successful
        left.failed += right.failed
    }
}

protocol CookieImporter {

    func importCookies(_ cookies: [HTTPCookie]) async -> CookieImportResult

}
