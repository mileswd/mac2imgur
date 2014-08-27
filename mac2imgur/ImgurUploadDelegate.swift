//
//  ImgurUploadDelegate.swift
//  mac2imgur
//
//  Created by Dexafree on 26/08/14.
//
//

protocol ImgurUploadDelegate {
    func uploadAttemptCompleted(successful: Bool, link: String, pathToImage: String) -> ()
}