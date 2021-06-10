//
//  BaseVM.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation

class BaseVM: NSObject {

    let isShowDialogLoading = LiveData(false)
    var isLoadingData = false

    let toastMessage = LiveData("")
}
