//
//  SharingMenu.swift
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

import Cocoa
import DependencyInjection

#if swift(>=5.9)
@Injectable
#endif
@MainActor
final class SharingMenu: NSMenu, Injectable {
    let dependencies: DependencyStorage

    @Injected
    var windowManager: WindowManagerProtocol

    @Injected
    var duckPlayer: DuckPlayer

    init(dependencyProvider: DependencyProvider) {
        self.dependencies = .init(dependencyProvider)

        super.init(title: UserText.shareMenuItem)
    }

    required init(coder: NSCoder) {
        fatalError("\(Self.self): Bad initializer")
    }

    override func update() {
        self.removeAllItems()
        self.autoenablesItems = false

        let isEnabled = windowManager.lastKeyMainWindowController?.mainViewController
            .tabCollectionViewModel.selectedTabViewModel?.canReload ?? false

        // not real sharing URL, used for generating items for NSURL
        var services = NSSharingService.sharingServices(forItems: [URL.duckDuckGo])

        if let copyLink = NSSharingService(named: .copyLink) {
            services.insert(copyLink, at: 0)
        }
        services.append(QRSharingService())

        let readingListService = NSSharingService(named: .addToSafariReadingList)
        for service in services where service != readingListService {
            let menuItem = NSMenuItem(service: service)
            menuItem.target = self
            menuItem.action = #selector(sharingItemSelected(_:))
            menuItem.isEnabled = isEnabled
            self.addItem(menuItem)
        }

        let moreItem = NSMenuItem(title: UserText.moreMenuItem,
                                  action: #selector(openSharingPreferences(_:)),
                                  keyEquivalent: "")
        moreItem.target = self
        moreItem.image = .more
        self.addItem(moreItem)
    }

    @objc func openSharingPreferences(_ sender: NSMenuItem) {
        let url = URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane")
        let plist = [
            "action": "revealExtensionPoint",
            "protocol": "com.apple.share-services"
        ]
        let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let descriptor = NSAppleEventDescriptor(descriptorType: .openSharingSubpane, data: data)

        NSWorkspace.shared.open([url],
                                withAppBundleIdentifier: nil,
                                options: .async,
                                additionalEventParamDescriptor: descriptor,
                                launchIdentifiers: nil)
    }

    @objc func sharingItemSelected(_ sender: NSMenuItem) {
        guard let service = sender.representedObject as? NSSharingService else {
            assertionFailure("representedObject is not NSSharingService")
            return
        }
        guard let tabViewModel = windowManager.lastKeyMainWindowController?.mainViewController
                .tabCollectionViewModel.selectedTabViewModel,
              let url = tabViewModel.tab.content.url
        else {
            return
        }
        if service == NSSharingService(named: .copyLink) {
            NSPasteboard.general.copy(url)
            return
        }

        let sharingData = duckPlayer.sharingData(for: tabViewModel.title, url: url) ?? (tabViewModel.title, url)
        service.subject = sharingData.title
        service.perform(withItems: [sharingData.url])
    }

}

private extension NSMenuItem {

    convenience init(service: NSSharingService) {
        var isMailService = false
        if service.responds(to: NSSelectorFromString("name")),
           let name = service.value(forKey: "name") as? NSSharingService.Name,
           name == .composeEmail {
            isMailService = true
        }

        self.init(title: service.menuItemTitle, action: nil, keyEquivalent: isMailService ? "I" : "")
        if isMailService {
            self.keyEquivalentModifierMask = [.command, .shift]
        }
        self.image = service.image
        self.representedObject = service
    }

}

private extension NSImage {

    static var more: NSImage? {
        let sharedMoreMenuImageSelector = NSSelectorFromString("sharedMoreMenuImage")
        guard NSSharingServicePicker.responds(to: sharedMoreMenuImageSelector) else { return nil }
        return NSSharingServicePicker.perform(sharedMoreMenuImageSelector)?.takeUnretainedValue() as? NSImage
    }

}

private extension DescType {

    static let openSharingSubpane: DescType = 0x70747275

}

private extension NSSharingService.Name {
    static let copyLink = NSSharingService.Name("com.apple.CloudSharingUI.CopyLink")
}
