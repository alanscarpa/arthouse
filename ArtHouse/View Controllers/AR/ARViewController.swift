//
//  ViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 3/21/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SafariServices

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var tutorialLabel: UILabel!
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var artworkDetailsLabel: UILabel!

    let artwork: Artwork
    var artworkNode = SCNNode()

    var currentStep = SessionManager.sharedSession.didCompleteArtworkTutorial ? Step.none : Step.standThreeFeet

    // MARK: - Init
    
    init(_ artwork: Artwork) {
        self.artwork = artwork
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.shared.showNavigationBar = false
        setUpARWorldTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Setup
    
    private func setUpUI() {
        buyNowButton.isHidden = true
        artworkDetailsLabel.isHidden = true

        configureUIForStep(currentStep)

        // Set up button animation
        let scaleDelta = CGFloat(0.15)
        let wiggleOutHorizontally = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0)
        let wiggleOutVertically = CGAffineTransform(scaleX: 1.0, y: 1.0 + scaleDelta)
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.buyNowButton.transform = wiggleOutHorizontally
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.buyNowButton.transform = wiggleOutVertically
            })
        })
    }

    private func configureUIForStep(_ step: Step) {
        switch step {
        case .none:
            [tutorialLabel,
            tutorialButton,
            buyNowButton,
            artworkDetailsLabel].forEach({ $0.isHidden = true})
        case .standThreeFeet:
            tutorialLabel.text =  """
            STEP \(step.rawValue):
            Stand 3 feet (0.91 meters) away from your wall.  This is will ensure accurate artwork size!
            """
            tutorialButton.titleLabel?.text = "I'm 3 feet from my wall. NEXT!"
            tutorialLabel.isHidden = false
            tutorialButton.isHidden = false
        case .tapToPlace:
            tutorialLabel.text =  """
            STEP \(step.rawValue):
            Now tap a spot on the wall to hang your artwork!
            """
            tutorialLabel.isHidden = false
            tutorialButton.isHidden = true
        case .touchAndDrag:
            tutorialLabel.text = """
            STEP \(step.rawValue):
            Use 1 finger to move your artwork.

            NOTE: You can't resize the artwork. This is a real world representation of how it will look on your wall.
            """
            tutorialLabel.isHidden = false
            tutorialButton.isHidden = true
        case .done:
            tutorialLabel.isHidden = true
            tutorialButton.isHidden = true
            showArtworkDetails()
            showBuyButton()
        }
    }
    
    func setUpSceneView() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
    }
    
    func setUpARWorldTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    func artworkNode(position: SCNVector3) -> SCNNode {
        let boxGeometry = SCNBox(width: artwork.width * 0.0254, height: artwork.height * 0.0254, length: 0.02, chamferRadius: 0.0)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = artwork.image
        let blackFrameMaterial = SCNMaterial()
        blackFrameMaterial.diffuse.contents = UIColor.black
        boxGeometry.materials = [imageMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial]
        let node = SCNNode(geometry: boxGeometry)
        node.position = position
        return node
    }
    
    // MARK: - UIEvents
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard artworkNode.parent == nil else { return }
        guard touches.first!.tapCount == 1 else { return }
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else { return }
        print(sceneView.session.currentFrame!.camera.eulerAngles.z)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        let pointTransform = matrix_multiply(cameraTransform, translation)
        let normalizedZValue = sceneView.projectPoint(SCNVector3Make(
            pointTransform.columns.3.x,
            pointTransform.columns.3.y,
            pointTransform.columns.3.z)).z
        let position = sceneView.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), normalizedZValue))
        
        artworkNode = self.artworkNode(position: position)

        let pitch: Float = 0
        let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
        let orientationCompensation = sceneView.session.currentFrame!.camera.eulerAngles.z < -0.5 ? Float.pi/2 : 0
        let roll = sceneView.session.currentFrame!.camera.eulerAngles.z + orientationCompensation
        let newRotation = SCNVector3Make(pitch, yaw!, roll)
        artworkNode.eulerAngles = newRotation
        
        sceneView.scene.rootNode.addChildNode(artworkNode)

        if SessionManager.sharedSession.didCompleteArtworkTutorial {
            showArtworkDetails()
            showBuyButton()
        } else {
            goToNextStep(from: currentStep)
        }
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        gesture.minimumNumberOfTouches = 1
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappednode = hits.first?.node, let result = hits.first {
            let position = SCNVector3Make(result.worldCoordinates.x, result.worldCoordinates.y, artworkNode.position.z)
            tappednode.position = position
            if !SessionManager.sharedSession.didCompleteArtworkTutorial {
                goToNextStep(from: currentStep)
            }
        }
    }

    // MARK: - ARSCNViewDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Helpers

    private func showArtworkDetails() {
        artworkDetailsLabel.isHidden = false
        artworkDetailsLabel.text =
        """
        \(artwork.title)
        Size: \(artwork.width)" W x \(artwork.height)" H
        """
    }
    
    private func showBuyButton() {
        buyNowButton.isHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped() {
        RootViewController.shared.popViewController()
    }

    @IBAction func tutorialButtonTapped(_ sender: Any) {
        goToNextStep(from: currentStep)
    }

    @IBAction func buyNowButtonTapped() {
        guard let buyNowURL = URL(string: artwork.buyURLString) else { return }
        let safariVC = SFSafariViewController(url: buyNowURL)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }
}

// Step Machine (aka StairMaster)

extension ARViewController {
    enum Step: Int {
        // `none` is used when there will be no tutorial flow required.
        case none
        case standThreeFeet
        case tapToPlace
        case touchAndDrag
        case done
    }

    func nextStep(from currentStep: Step) -> Step {
        switch currentStep {
        case .standThreeFeet:
            return .tapToPlace
        case .tapToPlace:
            return .touchAndDrag
        case .touchAndDrag:
            return .done
        case .done:
            // If we get here, then there has been some weird programmer error. But it
            // won't break the app.
            return .done
        case .none:
            // If we are in a `none` step, then that means there is no tutorial
            // required and therefore no next steps.
            return .none
        }
    }

    private func goToNextStep(from step: Step) {
        // We shouldn't be going to a next step if we are done or in a none state.
        guard currentStep != .done, currentStep != .none else { return }
        currentStep = nextStep(from: step)
        configureUIForStep(currentStep)
        if currentStep == .done {
            SessionManager.sharedSession.didCompleteArtworkTutorial = true
        }
    }
}
