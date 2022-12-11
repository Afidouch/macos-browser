//
//  TargetSourcesChecker.swift
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

struct NoTargetsFoundError: Error {}

struct ExtraFilesError: Error {
    var target: String
    var files: [InputFile]

    init(target: String, actual: Set<InputFile>, expected: Set<InputFile>) {
        self.init(target: target, files: Array(actual.subtracting(expected)))
    }

    init(target: String, files: [InputFile]) {
        self.target = target
        self.files = files
    }

    var localizedDescription: String {
        files.map(\.fileName).joined(separator: "\n")
    }
}
