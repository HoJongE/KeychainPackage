//
//  File.swift
//  
//
//  Created by JongHo Park on 2022/08/30.
//

import Foundation

protocol Queryable {
    var query: [String: Any] { get }
}

struct PasswordQuery {
    private let service: String
    private let appGroup: String?

    init(service: String, appGroup: String? = nil) {
        self.service = service
        self.appGroup = appGroup
    }

}

extension PasswordQuery: Queryable {
    var query: [String : Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        #if !targetEnvironment(simulator)
        if let appGroup = appGroup {
            query[String(kSecAttrAccessGroup)] = appGroup
        }
        #endif
        return query
    }
}
