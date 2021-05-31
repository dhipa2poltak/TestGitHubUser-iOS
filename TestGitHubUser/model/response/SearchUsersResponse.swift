//
//  SearchUsersResponse.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation

class SearchUsersResponse: Codable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [User]?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }

    init(
        totalCount: Int?,
        incompleteResults: Bool?,
        items: [User]?
    ) {
        self.totalCount = totalCount
        self.incompleteResults = incompleteResults
        self.items = items
    }
}
