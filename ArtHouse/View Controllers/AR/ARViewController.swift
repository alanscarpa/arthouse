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
import FirebaseAnalytics

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

    // Used to keep track of where the user initially touched to calculate the delta
    // when the user drags their finger.
    var referenceTouchPoint = SCNVector3()

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
        self.viewModel = ARViewControllerViewModel(with: artwork)
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

        trackLoadForAnalytics()
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
        backButton.round()
        instructionsLabelContainerView.round()
        artworkTitleContainer.round()
        buyNowButton.round()
        instructionsButton.round()
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

        updateArtworkNodeSize(with: viewModel.currentSize)
    }
    
    // MARK: - Setup

    private func addSizeButtons(for sizes: [String]) {
        stackView = UIStackView(arrangedSubviews: sizes.map { size -> SizeButton in
            let displaySize = viewModel.displaySize(for: size)
            let button = SizeButton(title: displaySize)
            button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: SizeButton.widthHeight).isActive = true
            button.widthAnchor.constraint(equalToConstant: SizeButton.widthHeight).isActive = true
            return button
        })
        stackView.axis = .vertical
        stackView.spacing = 20
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
        panGestureRecognizer.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func setUpARWorldTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    func artworkNode(position: SCNVector3, size: (width: CGFloat, height: CGFloat), eulerAngles: SCNVector3) -> SCNNode {
        let length = viewModel.artworkLength
        let boxGeometry = SCNBox(width: size.width * 0.03, height: size.height * 0.03, length: length, chamferRadius: 0.0)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = artwork.image

        if let diffuseTransform = viewModel.diffuseTransform {
            imageMaterial.diffuse.contentsTransform = diffuseTransform
        }
        
        let blackFrameMaterial = SCNMaterial()
        blackFrameMaterial.diffuse.contents = UIColor.black
        boxGeometry.materials = [imageMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial]
        let node = SCNNode(geometry: boxGeometry)
        node.position = position

        node.eulerAngles = eulerAngles
        return node
    }
    
    // MARK: - UIEvents
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.tapCount == 1 else { return }
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }

        // Needed because when the finger begins to drag, we need to calculate
        // the delta from this point and adjust the center position accordingly.
        referenceTouchPoint = viewModel.vectorPosition(from: touchPoint, in: sceneView, with: currentFrame)

        guard viewModel.canPlaceArtwork else { return }
        guard artworkNode.parent == nil else { return }

        let position = viewModel.vectorPosition(from: touchPoint, in: sceneView, with: currentFrame)
        artworkNode = artworkNode(position: position, size: viewModel.currentSize, eulerAngles: viewModel.eulerAngles(from: currentFrame))
        sceneView.scene.rootNode.addChildNode(artworkNode)

        viewModel.updateArtworkPosition(position)
        viewModel.updateTutorialProgress()
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappednode = hits.first?.node, let result = hits.first {
            let newX = result.worldCoordinates.x
            let oldCenterX = tappednode.worldPosition.x
            let deltaX = newX - referenceTouchPoint.x
            let newCenterX = deltaX + oldCenterX

            let newY = result.worldCoordinates.y
            let oldCenterY = tappednode.worldPosition.y
            let deltaY = newY - referenceTouchPoint.y
            let newCenterY = deltaY + oldCenterY

            let newPosition = SCNVector3Make(newCenterX, newCenterY, artworkNode.position.z)
            tappednode.position = newPosition
            viewModel.updateArtworkPosition(newPosition)
            viewModel.updateTutorialProgress()

            referenceTouchPoint = SCNVector3(CGFloat(newX), CGFloat(newY), CGFloat(referenceTouchPoint.z))
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
        trackBuyNowButtonTapped()
        let safariVC = SFSafariViewController(url: buyNowURL)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }

    @objc func sizeButtonTapped(_ sizeButton: SizeButton) {
        let selectedIndex = stackView.arrangedSubviews.firstIndex(of: sizeButton)
        viewModel.sizeButtonTapped(at: selectedIndex!)
    }

    private func updateArtworkNodeSize(with size: (width: CGFloat, height: CGFloat)) {
        guard artworkNode.parent != nil else { return }
        artworkNode.removeFromParentNode()
        artworkNode = artworkNode(position: artworkNode.position, size: size, eulerAngles: artworkNode.eulerAngles)
        sceneView.scene.rootNode.addChildNode(artworkNode)
    }

    // MARK: - Helpers

    private func showSizeButtons(_ shouldShow: Bool) {
        stackView.isHidden = !shouldShow
    }

    // MARK: - Analytics

    private func trackLoadForAnalytics() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: "id-AR-Screen",
            AnalyticsParameterItemName: "AR Screen for: \(artwork.title)"
        ])
    }

    private func trackBuyNowButtonTapped() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: "id-Buy-Now-Button-Tapped",
            AnalyticsParameterItemName: "Buy Now Button tapped for: \(artwork.title)"
        ])
    }
}
