//
//  MainVM.swift
//  TestGitHubUser
//
//  Created by user on 31/05/21.
//

import Foundation
import SVProgressHUD
import EZAlertController

class MainVM: BaseVM {

    var page = 1
    var searchText = ""
    var isNewSearch = true
    var isAllDataLoaded = false

    var users: [User] = []

    var isShowHistory = true
    var isShowNoData = false

    var appRepository: AppRepository?
    var histories: [History]?

    func initViewModel(appRepository: AppRepository) {
        self.appRepository = appRepository
        
        histories = appRepository.getAllHistoryFromDb()

        if let value = histories?.isEmpty {
            isShowNoData = value
            self.didLayout()
        }
    }

    func searchUsers(q: String, page: Int) {
        if (isAllDataLoaded) {
            return
        }

        if users.isEmpty {
            SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: UIApplication.shared.keyWindow?.center.x ?? 0, vertical: UIApplication.shared.keyWindow?.center.y ?? 0))
            SVProgressHUD.showGradient()
        }
        appRepository?.searchUsers(q: q, page: page).responseJSON { [weak self] resp in
            SVProgressHUD.dismiss()
            resp.validate { json in
                do {
                    let data = try json.rawData(options: .prettyPrinted)

                    let response = try JSONDecoder().decode(SearchUsersResponse.self, from: data)

                    self?.isShowHistory = false
                    self?.isShowNoData = false
                    if let items = response.items {
                        if items.count > 0 {

                            if (self?.isNewSearch ?? false) {
                                self?.users.removeAll()
                                self?.isNewSearch = false
                            }

                            for user in items {
                                self?.users.append(user)
                            }

                            self?.page = page
                        } else {
                            self?.isShowNoData = self?.users.isEmpty ?? true
                        }
                    } else {
                        self?.isShowNoData = self?.users.isEmpty ?? true
                    }

                    self?.didLayout()
                } catch {
                    SVProgressHUD.showDismissableError(with: error.localizedDescription)
                }
            }
        }
    }

    func processInputUserName() {
        if searchText.isEmpty {
            EZAlertController.alert("error", message: "please input the username")
            return
        }

        saveSearchText(searchText: searchText)

        page = 1
        isNewSearch = true
        isAllDataLoaded = false
        searchUsers(q: searchText, page: page)
    }

    func saveSearchText(searchText: String) {
        let history = appRepository?.getHistoryFromDb(sHistory: searchText)

        if (history != nil) {
            if let histories = histories, let history = history, histories.contains(history) {

                appRepository?.deleteHistoryFromDb(history: history)
                self.histories = appRepository?.getAllHistoryFromDb()
            }
        }

        if var histories = histories {
            while (histories.count >= Constant.MAX_HISTORY_COUNT) {
                histories.remove(at: histories.count - 1)

                if let dHistories = appRepository?.getAllHistoryFromDb() {
                    appRepository?.deleteHistoryFromDb(history: dHistories[dHistories.count - 1])
                }
            }

            appRepository?.saveHistoryToDb(sHistory: searchText)

            self.histories = appRepository?.getAllHistoryFromDb()
            self.didLayout()
        }
    }    
}
