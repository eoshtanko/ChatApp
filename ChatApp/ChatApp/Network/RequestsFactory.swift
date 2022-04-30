//
//  RequestsFactory.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

struct RequestsFactory {
    struct ImageRequests {
        static func getImages(pageNumber: Int) -> RequestConfig<ApiImageParser> {
            return RequestConfig<ApiImageParser>(request: GetImagesRequest(pageNumber: pageNumber), parser: ApiImageParser())
        }
        
        static func getImage(urlString: String) -> RequestConfig<ImageParser> {
            return RequestConfig<ImageParser>(request: GetImageRequest(urlString: urlString), parser: ImageParser())
        }
    }
}
