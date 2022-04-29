//
//  IRequestSender.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

 protocol IRequestSender {
     func send<Parser>(config: RequestConfig<Parser>, competionHandler: @escaping (Result<Parser.Model, Error>) -> Void)
 }
