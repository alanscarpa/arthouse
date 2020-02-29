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
    @IBOutlet weak var instructionsLabelContainerView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var artworkTitleContainer: UIView!
    @IBOutlet weak var artworkTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    var stackView = UIStackView()

    let artwork: Artwork
    var artworkNode = SCNNode()
    var sizeButtons = [SizeButton]()

    // This is the value that will determine our UI state
    var viewModel: ARViewControllerViewModel {
        didSet {
            configureUI()
            SessionManager.sharedSession.didCompleteArtworkTutorial = viewModel.didCompleteTutorial
        }
    }

    // MARK: - Init
    
    init(_ artwork: Artwork) {
        self.artwork = artwork
        let tutorialProgress: ARViewControllerViewModel.TutorialProgress  = SessionManager.sharedSession.didCompleteArtworkTutorial ? .finishedInAnotherSession : .standThreeFeetAway
        viewModel = ARViewControllerViewModel(tutorialProgress: tutorialProgress, artwork: artwork)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // We only want to set up our UI one time.
        setUpUI()

        // We can configure our UI multiplee times based on
        // changes in state.
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

    private func setUpUI() {
        backButton.roundCorners()
        instructionsLabelContainerView.roundCorners()
        artworkTitleContainer.roundCorners()
        buyNowButton.roundCorners()
        instructionsButton.roundCorners()
        addSizeButtons(for: viewModel.sizes)
    }

    // MARK: - Configuration

    // Called whenever our ViewModel updates.
    private func configureUI() {
        instructionsLabelContainerView.isHidden = !viewModel.shouldShowInstructions
        instructionsLabel.text = viewModel.instructionsText
        instructionsButton.setTitle(viewModel.instructionsButtonText, for: .normal)
        instructionsButton.isHidden = !viewModel.shouldShowInstructionsButton
        artworkTitleContainer.isHidden = !viewModel.shouldShowArtDetails
        artworkTitleLabel.text = viewModel.detailsText
        buyNowButton.isHidden = !viewModel.shouldShowPurchaseButton
        showSizeButtons(viewModel.shouldShowSizeButtons)

        for (index, view) in stackView.arrangedSubviews.enumerated() {
            let button = view as? SizeButton
            button?.isSelected = index == viewModel.sizeButtonSelectedIndex
        }

        updateArtworkOnScreenSize(with: viewModel.currentSize)
    }
    
    // MARK: - Setup

    private func addSizeButtons(for sizes: [String]) {
        stackView = UIStackView(arrangedSubviews: sizes.map { size -> SizeButton in
            let button = SizeButton(title: size)
            button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: SizeButton.widthHeight).isActive = true
            button.widthAnchor.constraint(equalToConstant: SizeButton.widthHeight).isActive = true
            return button
        })
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -8),
            stackView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                            constant: 10)])
    }
    
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
    
    func artworkNode(position: SCNVector3, size: (width: CGFloat, height: CGFloat)) -> SCNNode {
        let length = viewModel.artworkLength
        let boxGeometry = SCNBox(width: size.width * 0.0254, height: size.height * 0.0254, length: length, chamferRadius: 0.0)
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
        guard viewModel.canPlaceArtwork else { return }
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
        artworkNode = self.artworkNode(position: position, size: viewModel.currentSize)

        let pitch: Float = 0
        let yaw = currentFrame.camera.eulerAngles.y
        let orientationCompensation = currentFrame.camera.eulerAngles.z < -0.5 ? Float.pi/2 : 0
        let roll = sceneView.session.currentFrame!.camera.eulerAngles.z + orientationCompensation
        let newRotation = SCNVector3Make(pitch, yaw, roll)
        artworkNode.eulerAngles = newRotation
        sceneView.scene.rootNode.addChildNode(artworkNode)

        viewModel.updateArtworkPosition(position)
        viewModel.updateTutorialProgress()
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappednode = hits.first?.node, let result = hits.first {
            let position = SCNVector3Make(result.worldCoordinates.x, result.worldCoordinates.y, artworkNode.position.z)
            tappednode.position = position
            viewModel.updateArtworkPosition(position)
            viewModel.updateTutorialProgress()
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

    @IBAction func instructionsButtonTapped(_ sender: Any) {
        viewModel.updateTutorialProgress()
    }

    @IBAction func buyNowButtonTapped() {
        guard let buyNowURL = URL(string: artwork.buyURLString) else { return }
        let safariVC = SFSafariViewController(url: buyNowURL)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }

    @objc func sizeButtonTapped(_ sizeButton: SizeButton) {
        let selectedIndex = stackView.arrangedSubviews.firstIndex(of: sizeButton)
        viewModel.sizeButtonTapped(at: selectedIndex!)
    }

    private func updateArtworkOnScreenSize(with size: (width: CGFloat, height: CGFloat)) {
        guard artworkNode.parent != nil else { return }
        let eulerAngles = artworkNode.eulerAngles
        let position = artworkNode.position
        artworkNode.removeFromParentNode()
        artworkNode = artworkNode(position: position, size: size)
        artworkNode.eulerAngles = eulerAngles
        sceneView.scene.rootNode.addChildNode(artworkNode)
    }

    // MARK: - Helpers

    private func showSizeButtons(_ shouldShow: Bool) {
        stackView.isHidden = !shouldShow
    }
}
