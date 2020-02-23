//
//  ARViewControllerViewModel.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/7/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import Foundation
import ARKit

extension String {
    func artworkSize() -> (width: CGFloat, height: CGFloat) {
        let sizeArray = components(separatedBy: "X")
        let width = CGFloat(exactly: NumberFormatter().number(from: sizeArray[0])!)!
        let height = CGFloat(exactly: NumberFormatter().number(from: sizeArray[1])!)!
        return (width: width, height: height)
    }
}

struct ARViewControllerViewModel {

    typealias Size = (width: CGFloat, height: CGFloat)

    enum TutorialProgress {
        case standThreeFeetAway
        case tapToPlace
        case touchAndDrag
        case finishedInThisSession
        case finishedInAnotherSession
    }

    init(tutorialProgress: TutorialProgress, artwork: Artwork) {
        self.tutorialProgress = tutorialProgress
        self.artwork = artwork
        self.detailsText = "\(artwork.title)"
        self.sizes = artwork.sizes
        self.currentSize = artwork.sizes.first?.artworkSize() ?? (0, 0)
    }

    var sizes: [String]

    var artwork: Artwork

    var shouldChangeSize = false

    mutating func changeSize(_ size: Size) {
        currentSize = size
        shouldChangeSize = true
    }

    // We are only concerned with width and height here.
    // Length is a hardcoded value.
    private(set) var currentSize: Size = (0, 0)

    var artworkLength: CGFloat {
        switch artwork.category {
        case .framedPrints, .posters, .prints, .woodWallArt:
            return 0.02
        case .wallHanging, .wallTapestry:
            return 0
        }
    }

    private(set) var tutorialProgress: TutorialProgress

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

    var shouldShowTutorialButton: Bool {
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

    lazy var sizeButtons: [SizeButton] = {
        return buildSizeButtons()
    }()

    mutating private func buildSizeButtons() -> [SizeButton] {
        var sizeButtons = [SizeButton]()
        for size in sizes {
            let button = SizeButton()
            button.size = size.artworkSize()
            if button.size == currentSize {
                button.isSelected = true
            }
            button.setTitle(size, for: .normal)
            sizeButtons.append(button)
        }
        shouldAddSizeButtons = false
        return sizeButtons
    }

    // We only want to add size buttons to the view once.
    // This will change to false by another function.
    private var shouldAddSizeButtons = true

    var shouldAddSizeButtonsToView: Bool {
        return shouldShowPurchaseButton && shouldAddSizeButtons
    }

    mutating func sizeButtonTapped(_ button: SizeButton) {
        sizeButtons.forEach({ $0.isSelected = false })
        button.isSelected = true
    }
}

class SizeButton: UIButton {
    var size: (width: CGFloat, height: CGFloat) = (0, 0)
    var action: ((SizeButton) -> Void)?

    static let widthHeight: CGFloat = 60

    override init(frame: CGRect) {
        super.init(frame: frame)
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

    func setAct(action: ((SizeButton) -> Void)?) {
        self.action = action
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
