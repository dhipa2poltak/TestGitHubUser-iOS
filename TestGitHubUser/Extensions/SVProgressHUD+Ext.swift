//
//  SVProgressHUD+Ext.swift
//  TestTMDB
//
//  Created by user on 24/03/21.
//

import Foundation
import SVProgressHUD

/// Ref: https://stackoverflow.com/a/41111242/425694
extension SVProgressHUD {
    public static func showDismissableError(with status: String?) {
        let nc = NotificationCenter.default
        nc.addObserver(
            self, selector: #selector(hudTapped(_:)),
            name: NSNotification.Name.SVProgressHUDDidReceiveTouchEvent,
            object: nil
        )
        nc.addObserver(
            self, selector: #selector(hudDisappeared(_:)),
            name: NSNotification.Name.SVProgressHUDWillDisappear,
            object: nil
        )
        SVProgressHUD.showError(withStatus: status)
        SVProgressHUD.setDefaultMaskType(.clear)
    }

    @objc
    private static func hudTapped(_: Notification) {
        SVProgressHUD.dismiss()
        SVProgressHUD.setDefaultMaskType(.none)
    }

    @objc
    private static func hudDisappeared(_: Notification) {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name.SVProgressHUDDidReceiveTouchEvent, object: nil)
        nc.removeObserver(self, name: NSNotification.Name.SVProgressHUDWillDisappear, object: nil)
        SVProgressHUD.setDefaultMaskType(.none)
    }

    public static func showGradient() {
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()
    }
}
