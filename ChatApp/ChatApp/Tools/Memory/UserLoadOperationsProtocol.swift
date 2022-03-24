//
//  UserLoadOperationsProtocol.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

protocol UserLoadOperations {
    var result: Result<Codable, Error>? { get }
}
