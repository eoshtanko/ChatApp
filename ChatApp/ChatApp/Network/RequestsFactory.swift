//
//  RequestsFactory.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

struct RequestsFactory {
    struct ImageRequests {
        static func getImages(pageNumber: Int) -> RequestConfig<ImageParser> {
            return RequestConfig<ImageParser>(request: GetImagesRequest(pageNumber: pageNumber), parser: ImageParser())
        }
    }
}
