//
//  ARViewControllerViewModel.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/7/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import Foundation
import ARKit

struct ARViewControllerViewModel {

    typealias Size = (width: CGFloat, height: CGFloat)

    enum TutorialProgress {
        case standThreeFeetAway
        case tapToPlace
        case touchAndDrag
        case finishedInThisSession
        case finishedInAnotherSession
    }

    init(with artwork: Artwork) {
        self.tutorialProgress  = SessionManager.sharedSession.didCompleteArtworkTutorial ? .finishedInAnotherSession : .standThreeFeetAway
        self.artwork = artwork
        self.detailsText = "\(artwork.title)"
        self.sizes = artwork.sizes
        self.currentSize = artwork.sizes.first!.artworkSize()
    }

    var sizes: [String]
    
    var artwork: Artwork

    // We are only concerned with width and height here.
    // Length is a hardcoded value.
    private(set) var currentSize: Size

    var artworkLength: CGFloat {
        switch artwork.category {
        case .framedPrints, .posters, .prints, .woodWallArt:
            return 0.02
        case .wallHanging, .wallTapestry:
            return 0
        }
    }

    private var tutorialProgress: TutorialProgress

    var realWorldPosition: SCNVector3? {
        didSet {
            guard oldValue != nil else { return }
            hasMovedFromInitialPosition = true
        }
    }

    var detailsText: String

    private(set) var hasMovedFromInitialPosition = false

    mutating func updateArtworkPosition(_ position: SCNVector3) {
        realWorldPosition = position
    }

    var shouldShowInstructions: Bool {
        return !shouldShowPurchaseButton
    }

    var didCompleteTutorial: Bool {
        switch tutorialProgress {
        case .finishedInThisSession, .finishedInAnotherSession:
            return true
        case .standThreeFeetAway, .tapToPlace, .touchAndDrag:
            return false
        }
    }

    var canPlaceArtwork: Bool {
        if didCompleteTutorial {
            return true
        } else {
            switch tutorialProgress {
            case .standThreeFeetAway:
                return false
            case .tapToPlace, .touchAndDrag, .finishedInThisSession, .finishedInAnotherSession:
                return true
            }
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

    var instructionsText: String? {
        switch tutorialProgress {
        case .finishedInAnotherSession, .finishedInThisSession:
            return "Tap wall to place artwork"
        case .standThreeFeetAway:
            return """
            STEP 1:
            Stand 3 feet away from your wall.  This is will ensure accurate artwork size!
            """
        case .tapToPlace:
            return """
            STEP 2:
            Now tap a spot on the wall to hang your artwork!
            """
        case .touchAndDrag:
            return """
            STEP 3:
            Use 1 finger to move your artwork around.
            """
        }
    }

    var instructionsButtonText: String? {
        switch tutorialProgress {
        case .finishedInAnotherSession, .finishedInThisSession, .tapToPlace, .touchAndDrag:
            return nil
        case .standThreeFeetAway:
            return "Next"
        }
    }

    var shouldShowInstructionsButton: Bool {
        switch tutorialProgress {
        case .standThreeFeetAway:
            return true
        case .finishedInAnotherSession, .finishedInThisSession, .tapToPlace, .touchAndDrag:
        return false
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

    var shouldShowSizeButtons: Bool {
        // We only show the size buttons when we show the purchase button.
        // This could change in the future but for now, no need to duplicate the logic.
        return shouldShowPurchaseButton
    }

    var sizeButtonSelectedIndex: Int {
        sizes.firstIndex { $0.artworkSize() == currentSize }!
    }

    mutating func sizeButtonTapped(at index: Int) {
        currentSize = sizes[index].artworkSize()
    }
}

class SizeButton: UIButton {
    static let widthHeight: CGFloat = 60

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        layer.cornerRadius =  SizeButton.widthHeight / 2
        layer.borderWidth = 2
        backgroundColor = .clear
        setTitleColor(.ahPrimaryBlue, for: .selected)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Avenir Next", size: 14)
        self.setUnselectedUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var isSelected: Bool {
        didSet {
            self.isSelected ? setSelectedUI() : setUnselectedUI()
        }
    }

    private func setSelectedUI() {
        layer.borderColor = CGColor(srgbRed: 113.0 / 255.0, green: 193.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
    }

    private func setUnselectedUI() {
        layer.borderColor = CGColor(srgbRed: 255, green: 255, blue: 255, alpha: 1)
    }
}

extension String {
    func artworkSize() -> (width: CGFloat, height: CGFloat) {
        let sizeArray = components(separatedBy: "X")
        let width = CGFloat(exactly: NumberFormatter().number(from: sizeArray[0])!)!
        let height = CGFloat(exactly: NumberFormatter().number(from: sizeArray[1])!)!
        return (width: width, height: height)
    }
}
