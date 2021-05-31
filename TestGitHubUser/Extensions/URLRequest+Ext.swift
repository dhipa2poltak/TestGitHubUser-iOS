//
//  URLRequest+Ext.swift
//  TestTMDB
//
//  Created by user on 24/03/21.
//

import Foundation

extension URLRequest {
    func defaultURLRequest() -> URLRequest {
        let urlRequest = URLRequest(url: url!)

        //urlRequest.allHTTPHeaderFields = requestHeaders(token: "")

        return urlRequest
    }
}
