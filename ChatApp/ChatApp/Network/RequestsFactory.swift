//
//  RequestsFactory.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

struct RequestsFactory {
    struct ImageRequests {
        static func getImages() -> RequestConfig<ImageParser> {
            return RequestConfig<ImageParser>(request: GetImagesRequest(), parser: ImageParser())
        }
    }
}
