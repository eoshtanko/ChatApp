//
//  RequestConfig.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

 struct RequestConfig<Parser> where Parser: IParser {
    let request: IRequest
    let parser: Parser
 }
