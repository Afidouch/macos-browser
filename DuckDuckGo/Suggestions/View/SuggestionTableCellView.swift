//
//  SuggestionTableCellView.swift
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

import Cocoa

class SuggestionTableCellView: NSTableCellView {

    static let identifier = "SuggestionTableCellView"
    @IBOutlet weak var iconImageView: NSImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.contentTintColor = NSColor.textColor
    }

    func display(_ suggestionViewModel: SuggestionViewModel) {
        textField?.attributedStringValue = suggestionViewModel.attributedString
        iconImageView.image = suggestionViewModel.icon
    }

}
