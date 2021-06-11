//
//  AppRepository.swift
//  TestGitHubUser
//
//  Created by user on 11/06/21.
//

import Alamofire
import Foundation
import CoreData

class AppRepository {

    var managedObjectContext: NSManagedObjectContext?

    let toastMessage = LiveData("")

    init(managedObjectContext: NSManagedObjectContext?) {
        self.managedObjectContext = managedObjectContext
    }

    func searchUsers(q: String, page: Int, perPage: Int = Constant.ROW_PER_PAGE) -> DataRequest {

        return request(RestService.searchUsers(q: q, page: page, perPage: perPage))
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
