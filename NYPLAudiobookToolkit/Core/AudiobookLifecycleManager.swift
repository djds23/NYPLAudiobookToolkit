//
//  AudiobookLifecycleManager.swift
//  NYPLAudibookKit
//
//  Created by Dean Silfen on 1/12/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import AudioEngine
import AVFoundation

/// Delegate to be notified when the state of the lifecycle manager has changed
@objc public protocol AudiobookLifecycleManagerDelegate: class {

    /**
     General notifications about the state of the manager.
    */
    func audiobookLifecycleManagerDidUpdate(_ audiobookLifecycleManager: AudiobookLifeCycleManager)
    func audiobookLifecycleManagerWillTerminate(_ audiobookLifecycleManager: AudiobookLifeCycleManager)
    func audiobookLifecycleManagerDidEnterBackground(_ audiobookLifecycleManager: AudiobookLifeCycleManager)
}

/// Implementers of this protocol should hook into Lifecycle events in AppDelegate.swift.
/// They should also listen to notifications found in AudioEngine in order to update their internal state.
/// This is a wrapper around the stateful aspects of AudioEngine and avoids objects listening to NSNotifications directly.
@objc public protocol AudiobookLifeCycleManager: class {
    var audioEngineDatabaseHasBeenVerified: Bool { get }
    func didFinishLaunching()
    func didEnterBackground()
    func willTerminate()
    func registerDelegate(_ delegate: AudiobookLifecycleManagerDelegate)
    func removeDelegate(_ delegate: AudiobookLifecycleManagerDelegate)
}


/// Hooks into life cycle events for AppDelegate.swift. Listens to notifcations from
/// AudioEngine to ensure other objects know when it is safe to perform operations on
/// their SDK.
public class DefaultAudiobookLifecycleManager: NSObject, AudiobookLifeCycleManager {
    /**
     The shared instance of the lifecycle manager intended for usage throughout the framework.
     */
    public static let shared = DefaultAudiobookLifecycleManager()
    private var delegates: NSHashTable<AudiobookLifecycleManagerDelegate> = NSHashTable(options: [NSPointerFunctions.Options.weakMemory])
    public var audioEngineDatabaseHasBeenVerified: Bool {
        return _audioEngineDatabaseHasBeenVerified
    }
    private var _audioEngineDatabaseHasBeenVerified = false
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DefaultAudiobookLifecycleManager.audioEngineDatabaseVerificationStatusHasBeenUpdated(_:)),
            name: NSNotification.Name.FAEDatabaseVerificationComplete,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func registerDelegate(_ delegate: AudiobookLifecycleManagerDelegate) {
        self.delegates.add(delegate)
    }
    
    public func removeDelegate(_ delegate: AudiobookLifecycleManagerDelegate) {
        self.delegates.remove(delegate)
    }

    @objc public func audioEngineDatabaseVerificationStatusHasBeenUpdated(_ notification: NSNotification) {
        self._audioEngineDatabaseHasBeenVerified = true
        self.delegates.allObjects.forEach { (delegate) in
            delegate.audiobookLifecycleManagerDidUpdate(self)
        }
    }
}

extension DefaultAudiobookLifecycleManager {
    public func didFinishLaunching () {
        FAEAudioEngine.shared()?.didFinishLaunching()
        FAELogEngine.setLogLevel(.none)

        try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSessionCategoryPlayback
        )
        try? AVAudioSession.sharedInstance().setMode(
            AVAudioSessionModeDefault
        )
    }
    
    public func didEnterBackground () {
        FAEAudioEngine.shared()?.didEnterBackground()
        self.delegates.allObjects.forEach { (delegate) in
            delegate.audiobookLifecycleManagerDidEnterBackground(self)
        }
    }
    
    public func willTerminate () {
        FAEAudioEngine.shared()?.willTerminate()
        self.delegates.allObjects.forEach { (delegate) in
            delegate.audiobookLifecycleManagerWillTerminate(self)
        }
    }
    
    public func handleEventsForBackgroundURLSession(for identifier: String, completionHandler: @escaping () -> Void) {
        if identifier.contains("FWAE") {
            FAEAudioEngine.shared()?.downloadEngine?.addCompletionHandler(completionHandler, forSession: identifier)
        }
        FAEAudioEngine.shared()?.didFinishLaunching()
    }
}
