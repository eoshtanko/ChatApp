//
//  RequestsFactory.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

struct RequestsFactory {
    
    struct ImageRequests {
        static func getImages(pageNumber: Int) -> RequestConfig<ApiImagesParser> {
            return RequestConfig<ApiImagesParser>(request: GetImagesRequest(pageNumber: pageNumber), parser: ApiImagesParser())
        }
        
        static func getImage(urlString: String) -> RequestConfig<ImageParser> {
            return RequestConfig<ImageParser>(request: GetImageRequest(urlString: urlString), parser: ImageParser())
        }
    }
}
