//
//  HistoryStoreMock.swift
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import XCTest
@testable import DuckDuckGo_Privacy_Browser

class HistoryStoreMock: HistoryStore {

    var loadWebsiteVisitsCalled = false
    var websiteVisits: [WebsiteVisit]?
    var error: Error?

    func loadWebsiteVisits(textQuery: String?, limit: Int, completion: @escaping ([WebsiteVisit]?, Error?) -> Void) {
        loadWebsiteVisitsCalled = true
        completion(self.websiteVisits, self.error)
    }

    var saveWebsiteVisitCalled = false
    var savedWebsiteVisit: WebsiteVisit?

    func saveWebsiteVisit(_ websiteVisit: WebsiteVisit) {
        saveWebsiteVisitCalled = true
        savedWebsiteVisit = websiteVisit
    }

    var removeAllWebsiteVisitsCalled = false

    func removeAllWebsiteVisits() {
        removeAllWebsiteVisitsCalled = true
    }
    
}
