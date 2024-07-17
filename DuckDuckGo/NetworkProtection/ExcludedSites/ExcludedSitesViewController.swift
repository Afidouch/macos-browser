//
//  ExcludedSitesViewController.swift
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import AppKit

final class ExcludedSitesViewController: NSViewController {

    enum Constants {
        static let storyboardName = "ExcludedSites"
        static let identifier = "ExcludedSitesViewController"
        static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ExcludedSiteCell")
    }

    static func create() -> ExcludedSitesViewController {
        let storyboard = loadStoryboard()

        return storyboard.instantiateController(identifier: Constants.identifier) { coder -> ExcludedSitesViewController in

            return ExcludedSitesViewController(model: DefaultExcludedSitesViewModel())
        }
    }

    static func loadStoryboard() -> NSStoryboard {
        NSStoryboard(name: Constants.storyboardName, bundle: nil)
    }

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var removeDomainButton: NSButton!
    @IBOutlet var addSiteButton: NSButton!
    @IBOutlet var doneButton: NSButton!
    @IBOutlet var fireproofSitesLabel: NSTextField!

    private var allFireproofDomains = [String]()
    private var filteredFireproofDomains: [String]?

    private var fireproofDomains: [String] {
        return filteredFireproofDomains ?? allFireproofDomains
    }

    private let model: ExcludedSitesViewModel

    init(model: ExcludedSitesViewModel) {
        self.model = model

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModalWindowStyleIfNeeded()
        reloadData()
        setUpStrings()
    }

    private func setUpStrings() {
        removeDomainButton.title = UserText.remove
        removeAllDomainsButton.title = UserText.fireproofRemoveAllButton
        doneButton.title = UserText.done
        fireproofSitesLabel.stringValue = UserText.fireproofSites
    }

    private func updateRemoveButtonState() {
        removeDomainButton.isEnabled = tableView.selectedRow > -1
    }

    fileprivate func reloadData() {
        allFireproofDomains = FireproofDomains.shared.fireproofDomains.sorted { (lhs, rhs) -> Bool in
            return lhs < rhs
        }

        tableView.reloadData()
        updateRemoveButtonState()
    }

    @IBAction func doneButtonClicked(_ sender: NSButton) {
        dismiss()
    }

    @IBAction func removeSelectedDomain(_ sender: NSButton) {
        guard tableView.selectedRow > -1 else {
            updateRemoveButtonState()
            return
        }

        let selectedDomain = fireproofDomains[tableView.selectedRow]
        FireproofDomains.shared.remove(domain: selectedDomain)
        reloadData()
    }

    @IBAction func removeAllDomains(_ sender: NSButton) {
        FireproofDomains.shared.clearAll()
        reloadData()
    }

}

extension ExcludedSitesViewController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return fireproofDomains.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return fireproofDomains[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: Constants.cellIdentifier, owner: nil) as? NSTableCellView {
            let domain = fireproofDomains[row]
            cell.textField?.stringValue = domain
            cell.imageView?.image = faviconManagement.getCachedFavicon(for: domain, sizeCategory: .small)?.image
            cell.imageView?.applyFaviconStyle()

            return cell
        }

        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateRemoveButtonState()
    }

}

extension ExcludedSitesViewController: NSTextFieldDelegate {

    func controlTextDidChange(_ notification: Notification) {
        guard let field = notification.object as? NSSearchField else { return }

        if field.stringValue.isEmpty {
            filteredFireproofDomains = nil
        } else {
            filteredFireproofDomains = allFireproofDomains.filter { $0.contains(field.stringValue) }
        }

        reloadData()
    }

}
