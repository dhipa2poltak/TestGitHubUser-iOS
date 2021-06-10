//
//  LiveData.swift
//  TestGitHubUser
//
//  Created by user on 09/06/21.
//

import Foundation

class LiveData<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func observe(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
