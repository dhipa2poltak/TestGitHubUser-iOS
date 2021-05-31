//
//  DataResponse+Ext.swift
//  TestTMDB
//
//  Created by user on 24/03/21.
//

import Foundation

import Alamofire
import EZAlertController
import Foundation
import SVProgressHUD
import SwiftyJSON

private let successCodes: [String] = ["00", "01", "08", "200", "99"]

extension DataResponse {
    // swiftlint:disable cyclomatic_complexity
    func validate(alert: Bool = true, _ completion: @escaping (_ data: JSON) -> Void) {
        SVProgressHUD.dismiss()

        if let error = result.error {
            SVProgressHUD.showDismissableError(with: error.localizedDescription)
            return
        }
        // force logout if getting 403 forbidden
        switch response?.statusCode {
        case 401:
            /*
            EZAlertController.alert(localizable("warning"),
                                    message: localizable("anda.terdeteksi.login.perangkat.lain"),
                                    buttons: ["Logout"]) { _, _ in
                // CacheManager.didLogout()
            }
            */
            return

        case 403:
            // CacheManager.didLogout()
            return

        case 428:
            /*
            EZAlertController.alert(localizable("warning"),
                                    message: "Optional update")
            */
            return

        case 426:
            return

        default:
            break
        }

        let commonString = "API Response invalidate."

        guard let value = result.value else {
            if alert {
                SVProgressHUD.showDismissableError(with: commonString)
            }
            return
        }

        let json = JSON(value)

        if let code = json["code"].string, !successCodes.contains(code) {
            if alert {
                if code == "10" {
                    EZAlertController.alert("", message: json["message"].stringValue)

                    completion(json)
                } else {
                    SVProgressHUD.showDismissableError(with: hideSuccessMessageButFailure(json["message"].string))
                }
            }
            return
        }

        if let code = json["status"]["code"].string, !successCodes.contains(code) {
            if alert, let message = json["message"].string {
                SVProgressHUD.showDismissableError(with: message)
            } else if alert, let message = json["status"]["message"].string {
                SVProgressHUD.showDismissableError(with: hideSuccessMessageButFailure(message))
            } else {
                completion(json)
            }

            return
        }

        // api direct
        if let code = json["status"].int, code > 299 {
            if alert {
                let message: String = json["message"].stringValue + " " + json["error"].stringValue
                SVProgressHUD.showDismissableError(with: message)
            }
            return
        }

        completion(json)
    }
}

private func hideSuccessMessageButFailure(_ string: String?) -> String? {
    var message: String? = string
    if message?.lowercased() == "success" {
        message = nil
    }
    return message
}
