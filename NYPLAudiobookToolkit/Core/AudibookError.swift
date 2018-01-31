//
//  AudibookError.swift
//  NYPLAudiobookToolkit
//
//  Created by Dean Silfen on 1/26/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

@objc public protocol AudiobookError {
    var error: Any { get }
    var audiobookID: String { get }
}

class DefaultAudiobookError: AudiobookError {
    let error: Any
    let audiobookID: String
    init(error: Error, audiobookID: String) {
        self.error = error
        self.audiobookID = audiobookID
    }
}