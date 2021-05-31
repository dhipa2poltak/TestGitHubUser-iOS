//
//  RestService.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Alamofire
import Foundation
import SwiftyJSON

enum RestService: URLRequestConvertible {
    case searchUsers(q: String, page: Int, perPage: Int)

    public func asURLRequest() throws -> URLRequest {
        var url: URL?

        switch self {
        default:
            url = URL(string: "\(Constant.API_BASE_URL)\(path)")
        }

        if let theUrl = url {
            var urlRequest = URLRequest(url: theUrl).defaultURLRequest()
            urlRequest.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            urlRequest.addValue("token \(Constant.TOKEN_GITHUB)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = method.rawValue
            if method == .post {
                do {
                    urlRequest.httpBody = try JSON(param).rawData(options: .prettyPrinted)
                } catch {
                    print("httpBody failed!")
                }
            }
            let encodedURLRequest = try URLEncoding.default.encode(urlRequest, with: nil)

            return encodedURLRequest
        }

        throw NSError()
    }

    var method: HTTPMethod {
        switch self {
        case .searchUsers: return .get
        }
    }

    var path: String {
        switch self {
        case let .searchUsers(q: q, page: page, perPage: perPage):
            return "search/users?q=\(q)&page=\(page)&per_page=\(perPage)"
        }
    }

    var param: Parameters {
        let p = Parameters()

        switch self {
        default:
            break
        }

        return p
    }
}
