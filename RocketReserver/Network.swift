//
//  Network.swift
//  RocketReserver
//
//  Created by Chatchai Lokniyom on 2020/08/26.
//  Copyright © 2020 RocketReserver. All rights reserved.
//

import Foundation
import Apollo
import KeychainSwift

class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com")!)
}

extension Network: HTTPNetworkTransportPreflightDelegate {
    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }
    
    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        let keychain = KeychainSwift()
        if let token = keychain.get(LoginViewController.loginKeychainKey) {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
    }
    
}
