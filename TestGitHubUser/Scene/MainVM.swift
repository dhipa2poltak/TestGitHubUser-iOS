//
//  MainVM.swift
//  TestGitHubUser
//
//  Created by user on 31/05/21.
//

import Foundation
import Alamofire
import SVProgressHUD
import EZAlertController
import CoreData

class MainVM: BaseVM {

    var page = 1
    var searchText = ""
    var isNewSearch = true
    var isAllDataLoaded = false

    var users: [User] = []
    var searchUsersReponse: SearchUsersResponse?

    var isShowHistory = true
    var isShowNoData = false

    var managedObjectContext: NSManagedObjectContext?
    var histories: [History]?

    func initViewModel() {
        histories = getAllHistoryFromDb()
    }

    func searchUsers(q: String, page: Int, perPage: Int = Constant.ROW_PER_PAGE) {
        if (isAllDataLoaded) {
            return
        }

        SVProgressHUD.showGradient()
        request(RestService.searchUsers(q: q, page: page, perPage: perPage)).responseJSON { [weak self] resp in
            SVProgressHUD.dismiss()
            resp.validate { json in
                do {
                    let data = try json.rawData(options: .prettyPrinted)

                    let response = try JSONDecoder().decode(SearchUsersResponse.self, from: data)
                    self?.searchUsersReponse = response

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
                            self?.isShowNoData = true
                        }
                    } else {
                        self?.isShowNoData = true
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
            self.didLayout()
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
                EZAlertController.alert("error", message: error.localizedFailureReason ?? "error getting all history")
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
                EZAlertController.alert("error", message: error.localizedFailureReason ?? "error getting history")
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
                EZAlertController.alert("error", message: error.localizedFailureReason ?? "error saving history")
            }
        }
    }

    func deleteHistoryFromDb(history: History) {
        if let managedObjectContext = managedObjectContext {
            do {
                managedObjectContext.delete(history)
                try managedObjectContext.save()
            } catch let error as NSError {
                EZAlertController.alert("error", message: error.localizedFailureReason ?? "error deleting history")
            }
        }
    }
}
