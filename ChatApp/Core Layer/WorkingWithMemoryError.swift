//
//  WorkingWithMemoryError.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation

public enum WorkingWithMemoryError: Error {
    case readError
    case writeError
    case formatError
}
