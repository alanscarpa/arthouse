//
//  something.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/7/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import Foundation
import ARKit

struct ArtworkState {
    enum TutorialProgress {
        case standThreeFeetAway
        case tapToPlace
        case touchAndDrag
        case finishedInThisSession
        case finishedInAnotherSession
    }

    private(set) var tutorialProgress: TutorialProgress

    var realWorldPosition: SCNVector3? {
        didSet {
            guard oldValue != nil else { return }
            hasMovedFromInitialPosition = true
        }
    }

    private(set) var hasMovedFromInitialPosition = false

    init(tutorialProgress: TutorialProgress) {
        self.tutorialProgress = tutorialProgress
    }

    mutating func updateArtworkPosition(_ position: SCNVector3) {
        realWorldPosition = position
    }

    var didCompleteTutorial: Bool {
        switch tutorialProgress {
        case .finishedInThisSession, .finishedInAnotherSession:
            return true
        case .standThreeFeetAway, .tapToPlace, .touchAndDrag:
            return false
        }
    }

    mutating func updateTutorialProgress() {
        switch tutorialProgress {
        case .standThreeFeetAway:
            tutorialProgress = .tapToPlace
        case .tapToPlace:
            tutorialProgress = .touchAndDrag
        case .touchAndDrag, .finishedInThisSession:
            tutorialProgress = .finishedInThisSession
        case .finishedInAnotherSession:
            tutorialProgress = .finishedInAnotherSession
        }
    }

    mutating func restartTutorial() {
        tutorialProgress = .standThreeFeetAway
    }

    var tutorialText: String? {
        switch tutorialProgress {
        case .finishedInAnotherSession, .finishedInThisSession:
            return nil
        case .standThreeFeetAway:
            return """
            STEP 1:
            Stand 3 feet (0.91 meters) away from your wall.  This is will ensure accurate artwork size!
            """
        case .tapToPlace:
            return """
            STEP 2:
            Now tap a spot on the wall to hang your artwork!
            """
        case .touchAndDrag:
            return """
            STEP 3:
            Use 1 finger to move your artwork.
            NOTE: You can't resize the artwork. This is a real world representation of how it will look on your wall.
            """
        }
    }

    var tutorialButtonText: String? {
        switch tutorialProgress {
        case .finishedInAnotherSession, .finishedInThisSession, .tapToPlace, .touchAndDrag:
            return nil
        case .standThreeFeetAway:
            return "I'm 3 feet from my wall. NEXT!"
        }
    }

    var shouldShowPurchaseButton: Bool {
        switch (tutorialProgress, hasMovedFromInitialPosition, realWorldPosition)  {
        case (.standThreeFeetAway, _, _),
             (.tapToPlace, _, _),
             (.touchAndDrag, _, _):
            return false
        case (.finishedInThisSession, true, .some):
            return true
        case (.finishedInThisSession, true, nil):
            return false
        case (.finishedInThisSession, false, .some):
            return false
        case (.finishedInThisSession, false, nil):
            return false
        case (.finishedInAnotherSession, _, .some):
            return true
        case (.finishedInAnotherSession, _, nil):
            return false
        }
    }

    var shouldShowArtDetails: Bool {
        // We only show the art details when we show the purchase button.
        // This could change in the future but for now, no need to duplicate the logic.
        return shouldShowPurchaseButton
    }
}
