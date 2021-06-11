//
//  MainVM.swift
//  TestGitHubUser
//
//  Created by user on 31/05/21.
//

import Foundation

class MainVM: BaseVM {

    var page = 1
    var searchText = ""
    var isNewSearch = true
    var isAllDataLoaded = false

    var users: [User] = []
    var searchUsersReponse: SearchUsersResponse?
    let notifyList: LiveData<Bool> = LiveData(false)

    var isShowHistory = true
    var isShowNoData = false
    let doShowNoData: LiveData<Bool?> = LiveData(false)

    var histories: [History]?

    var appRepository: AppRepository?

    func initViewModel(appRepository: AppRepository?) {
        self.appRepository = appRepository

        histories = appRepository?.getAllHistoryFromDb()
        if let value = histories?.isEmpty {
            isShowNoData = value
            doShowNoData.value = self.isShowNoData
        }

        appRepository?.toastMessage.observe { [weak self] value in
            if !value.isEmpty {
                self?.toastMessage.value = value
                self?.appRepository?.toastMessage.value = ""
            }
        }
    }

    func searchUsers(q: String, page: Int, perPage: Int = Constant.ROW_PER_PAGE) {
        if (isAllDataLoaded) {
            return
        }

        isShowDialogLoading.value = true
        appRepository?.searchUsers(q: q, page: page, perPage: perPage).responseJSON { [weak self] resp in
            self?.isShowDialogLoading.value = false
            resp.validate { json in
                do {
                    let data = try json.rawData(options: .prettyPrinted)

                    let response = try JSONDecoder().decode(SearchUsersResponse.self, from: data)
                    self?.searchUsersReponse = response

                    self?.isShowHistory = false
                    self?.isShowNoData = false
                    self?.doShowNoData.value = self?.isShowNoData
                    if let items = response.items {
                        if items.count > 0 {

                            if (self?.isNewSearch ?? false) {
                                self?.users.removeAll()
                                self?.isNewSearch = false
                            }

                            for user in items {
                                self?.users.append(user)
                                //self?.userData.value = user
                            }

                            self?.page = page
                        } else {
                            self?.isShowNoData = self?.users.isEmpty ?? true
                            self?.doShowNoData.value = self?.isShowNoData
                        }
                    } else {
                        self?.isShowNoData = self?.users.isEmpty ?? true
                        self?.doShowNoData.value = self?.isShowNoData
                    }

                    self?.notifyList.value = true
                } catch {
                    self?.toastMessage.value = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    func processInputUserName() {
        if searchText.isEmpty {
            toastMessage.value = "Error: please input the username"
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
            self.notifyList.value = true
        }
    }
}
