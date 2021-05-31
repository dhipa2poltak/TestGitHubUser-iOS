//
//  BaseVM.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation

class BaseVM: NSObject {
    private var owner: String = ""

    override init() {
        super.init()
    }

    convenience init(vc: BaseVC) {
        self.init()
        owner = addressString(vc)
    }

    func didLayout() {
        print("POST: layouting-\(type(of: self))")
        NotificationCenter.default.post(name: NSNotification.Name("layouting-\(owner)"),
                                        object: nil)
    }
}
