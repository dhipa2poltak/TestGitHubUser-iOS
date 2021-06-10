//
//  MainVM.swift
//  TestGitHubUser
//
//  Created by user on 31/05/21.
//

import Foundation
import Alamofire
import SVProgressHUD
import CoreData

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

    var managedObjectContext: NSManagedObjectContext?
    var histories: [History]?

    func initViewModel() {
        histories = getAllHistoryFromDb()
        if let value = histories?.isEmpty {
            isShowNoData = value
            doShowNoData.value = self.isShowNoData
        }
    }

    func searchUsers(q: String, page: Int, perPage: Int = Constant.ROW_PER_PAGE) {
        if (isAllDataLoaded) {
            return
        }

        isShowDialogLoading.value = true
        request(RestService.searchUsers(q: q, page: page, perPage: perPage)).responseJSON { [weak self] resp in
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
        let history = self.getHistoryFromDb(sHistory: searchText)

        if (history != nil) {
            if let histories = histories, let history = history, histories.contains(history) {

                self.deleteHistoryFromDb(history: history)
                self.histories = getAllHistoryFromDb()
            }
        }

        if var histories = histories {
            while (histories.count >= Constant.MAX_HISTORY_COUNT) {
                histories.remove(at: histories.count - 1)

                if let dHistories = self.getAllHistoryFromDb() {
                    self.deleteHistoryFromDb(history: dHistories[dHistories.count - 1])
                }
            }

            self.saveHistoryToDb(sHistory: searchText)

            self.histories = getAllHistoryFromDb()
            self.notifyList.value = true
        }
    }

    func getAllHistoryFromDb() -> [History]? {
        if let managedObjectContext = managedObjectContext {
            let fetchRequest = NSFetchRequest<History>(entityName: "History")
            let sort = NSSortDescriptor(key: #keyPath(History.added), ascending: false)
            fetchRequest.sortDescriptors = [sort]

            do {
                let histories = try managedObjectContext.fetch(fetchRequest)

                return histories
            } catch let error as NSError {
                toastMessage.value = "Error - " + String(describing:error.localizedFailureReason ?? "error getting all history")
            }
        }

        return nil
    }

    func getHistoryFromDb(sHistory: String) -> History? {
        if let managedObjectContext = managedObjectContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "History", in: managedObjectContext)

            let request = NSFetchRequest<History>(entityName: "History")
            request.entity = entityDescription

            let pred = NSPredicate(format: "(history = %@)", sHistory)
            request.predicate = pred

            do {
                let results = try managedObjectContext.fetch(request)

                if results.count > 0 {
                    return results[0]
                }
            } catch let error as NSError {
                toastMessage.value = "Error - " + String(describing:error.localizedFailureReason ?? "error getting history")
            }
        }

        return nil
    }

    func saveHistoryToDb(sHistory: String) {
        if let managedObjectContext = managedObjectContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "History", in: managedObjectContext)

            let history = History(entity: entityDescription!, insertInto: managedObjectContext)

            history.added = Date()
            history.history = sHistory

            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                toastMessage.value = "Error - " + String(describing:error.localizedFailureReason ?? "error saving history")
            }
        }
    }

    func deleteHistoryFromDb(history: History) {
        if let managedObjectContext = managedObjectContext {
            do {
                managedObjectContext.delete(history)
                try managedObjectContext.save()
            } catch let error as NSError {
                toastMessage.value = "Error - " + String(describing:error.localizedFailureReason ?? "error deleting history")
            }
        }
    }
}
