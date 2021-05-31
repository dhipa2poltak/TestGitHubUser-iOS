//
//  User.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation

class User: Codable {

    let login: String?
    let id: Int?
    let nodeId: String?
    let avatarUrl: String?
    let gravatarId: String?
    let url: String?
    let htmlUrl: String?
    let followersUrl: String?
    let subscriptionsUrl: String?
    let organizationsUrl: String?
    let reposUrl: String?
    let receivedEventsUrl: String?
    let type: String?
    let score: Int?
    let followingUrl: String?
    let gistsUrl: String?
    let starredUrl: String?
    let eventsUrl: String?
    let siteAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case nodeId = "node_id"
        case avatarUrl = "avatar_url"
        case gravatarId = "gravatar_id"
        case url
        case htmlUrl = "html_url"
        case followersUrl = "followers_url"
        case subscriptionsUrl = "subscriptions_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case receivedEventsUrl = "received_events_url"
        case type
        case score
        case followingUrl = "following_url"
        case gistsUrl = "gists_url"
        case starredUrl = "starred_url"
        case eventsUrl = "events_url"
        case siteAdmin = "site_admin"
    }

    init(
        login: String?,
        id: Int?,
        nodeId: String?,
        avatarUrl: String?,
        gravatarId: String?,
        url: String?,
        htmlUrl: String?,
        followersUrl: String?,
        subscriptionsUrl: String?,
        organizationsUrl: String?,
        reposUrl: String?,
        receivedEventsUrl: String?,
        type: String?,
        score: Int?,
        followingUrl: String?,
        gistsUrl: String?,
        starredUrl: String?,
        eventsUrl: String?,
        siteAdmin: Bool?
    ) {
        self.login = login
        self.id = id
        self.nodeId = nodeId
        self.avatarUrl = avatarUrl
        self.gravatarId = gravatarId
        self.url = url
        self.htmlUrl = htmlUrl
        self.followersUrl = followersUrl
        self.subscriptionsUrl = subscriptionsUrl
        self.organizationsUrl = organizationsUrl
        self.reposUrl = reposUrl
        self.receivedEventsUrl = receivedEventsUrl
        self.type = type
        self.score = score
        self.followingUrl = followingUrl
        self.gistsUrl = gistsUrl
        self.starredUrl = starredUrl
        self.eventsUrl = eventsUrl
        self.siteAdmin = siteAdmin
    }
}
