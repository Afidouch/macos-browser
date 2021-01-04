//
//  WindowManager.swift
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
import os.log

class WindowsManager {

    class var windows: [NSWindow] {
        return NSApplication.shared.windows
    }

    class func closeWindows(except window: NSWindow? = nil) {
        NSApplication.shared.windows.forEach {
            if $0 != window {
                $0.close()
            }
        }
    }

    class func openNewWindow(with initialTab: Tab? = nil) {
        guard let mainWindowController = makeNewWindow() else {
            return
        }

        if let initialTab = initialTab {
            guard let mainViewController = mainWindowController.contentViewController as? MainViewController else {
                return
            }

            mainViewController.tabCollectionViewModel.append(tab: initialTab)
            mainViewController.tabCollectionViewModel.remove(at: 0)
        }
        mainWindowController.showWindow(self)
    }

    class func openNewWindow(with initialUrl: URL) {
        guard let mainWindowController = makeNewWindow() else {
            return
        }

        mainWindowController.showWindow(self)

        guard let mainViewController = mainWindowController.contentViewController as? MainViewController else {
            os_log("MainWindowController: Failed to get reference to main view controller", type: .error)
            return
        }
        guard let newTab = mainViewController.tabCollectionViewModel.tabCollection.tabs.first else {
            os_log("MainWindowController: Failed to get initial tab", type: .error)
            return
        }

        newTab.url = initialUrl
    }

    private class func makeNewWindow() -> MainWindowController? {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        guard let mainWindowController = mainStoryboard.instantiateInitialController() as? MainWindowController else {
            os_log("MainViewController: Failed to init MainWindowController", type: .error)
            return nil
        }

        mainWindowController.window?.animationBehavior = .documentWindow
        return mainWindowController
    }
}
