//
//  OpenAccessPlayer.swift
//  NYPLAudiobookToolkit
//
//  Created by Dean Silfen on 1/31/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

class OpenAccessPlayer: NSObject, Player {
    func seekTo(_ offsetInChapter: Float) {
    }
    
    var delegate: PlayerDelegate?
    
    func jumpToChapter(_ description: ChapterDescription) {

    }
    
    func skipForward() {

    }
    
    func skipBack() {

    }
    
    var isPlaying: Bool {
        return false
    }

    func play() {
        
    }
    
    func pause() {
        
    }
    
    private let spine: [OpenAccessSpineElement]
    public init(spine: [OpenAccessSpineElement]) {
        self.spine = spine
    }
}
