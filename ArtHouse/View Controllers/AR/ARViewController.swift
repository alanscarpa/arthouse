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

    // This is the value that will determine our UI state
    var artworkState: ArtworkState {
        didSet {
            configureUI()
            SessionManager.sharedSession.didCompleteArtworkTutorial = artworkState.didCompleteTutorial
        }
    }

    // MARK: - Init
    
    init(_ artwork: Artwork) {
        self.artwork = artwork
        let tutorialProgress: ArtworkState.TutorialProgress  = SessionManager.sharedSession.didCompleteArtworkTutorial ? .finishedInAnotherSession : .standThreeFeetAway
        artworkState = ArtworkState(tutorialProgress: tutorialProgress, artwork: artwork)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpBuyNowButtonAnimation()
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

    private func configureUI() {
        tutorialLabel.text = artworkState.tutorialText
        tutorialLabel.isHidden = artworkState.tutorialText == nil
        tutorialButton.titleLabel?.text = artworkState.tutorialButtonText
        tutorialButton.isHidden = artworkState.tutorialButtonText == nil
        artworkDetailsLabel.text = artworkState.detailsText
        artworkDetailsLabel.isHidden = !artworkState.shouldShowArtDetails
        buyNowButton.isHidden = !artworkState.shouldShowPurchaseButton
    }
    
    // MARK: - Setup
    
    private func setUpBuyNowButtonAnimation() {
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

    func setUpSceneView() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureRecognizer)
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
        guard touches.first?.tapCount == 1 else { return }
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }

        let cameraTransform = currentFrame.camera.transform
        print(sceneView.session.currentFrame?.camera.eulerAngles.z ?? "No camera transform frame")
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
        let yaw = currentFrame.camera.eulerAngles.y
        let orientationCompensation = currentFrame.camera.eulerAngles.z < -0.5 ? Float.pi/2 : 0
        let roll = sceneView.session.currentFrame!.camera.eulerAngles.z + orientationCompensation
        let newRotation = SCNVector3Make(pitch, yaw, roll)
        artworkNode.eulerAngles = newRotation
        sceneView.scene.rootNode.addChildNode(artworkNode)

        artworkState.updateArtworkPosition(position)
        artworkState.updateTutorialProgress()
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappednode = hits.first?.node, let result = hits.first {
            let position = SCNVector3Make(result.worldCoordinates.x, result.worldCoordinates.y, artworkNode.position.z)
            tappednode.position = position
            artworkState.updateArtworkPosition(position)
            artworkState.updateTutorialProgress()
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
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped() {
        RootViewController.shared.popViewController()
    }

    @IBAction func tutorialButtonTapped(_ sender: Any) {
        artworkState.updateTutorialProgress()
    }

    @IBAction func buyNowButtonTapped() {
        guard let buyNowURL = URL(string: artwork.buyURLString) else { return }
        let safariVC = SFSafariViewController(url: buyNowURL)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }
}
