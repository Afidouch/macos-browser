//
//  TabCollectionTests.swift
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

class TabCollectionTests: XCTestCase {

    func testWhenTabIsPrependThenItsIndexIs0() throws {
        let tabCollection = TabCollection()
        let tab1 = Tab()
        tab1.url = URL.duckDuckGo

        let tab2 = Tab()

        tabCollection.prepend(tab: tab1)
        XCTAssertEqual(tabCollection.tabs[0], tab1)

        tabCollection.prepend(tab: tab2)
        XCTAssertEqual(tabCollection.tabs[0], tab2)
    }

}
