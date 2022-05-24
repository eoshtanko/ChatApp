//
//  IParser.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

 protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
 }
