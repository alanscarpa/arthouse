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

class HomeViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
//    var paintingPlane: SCNPlane {
//        // 1 in = 0.0254 m
//        let height: CGFloat = 8 // inches
//        let width: CGFloat = 11.5 // inches
//        let plane = SCNPlane(width: width * 0.0254, height: height * 0.0254)
//        let imageMaterial = SCNMaterial()
//        imageMaterial.diffuse.contents = UIImage(named: "framed-print-sample")
//        plane.materials = [imageMaterial]
//        return plane
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpARWorldTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Setup
    
    func setUpSceneView() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
    }
    
    func setUpARWorldTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    func paintingCube() -> SCNNode {
        let boxGeometry = SCNBox(width: 10 * 0.0254, height: 12 * 0.0254, length: 0.02, chamferRadius: 0.0)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = UIImage(named: "framed-print-sample")
        let blackFrameMaterial = SCNMaterial()
        blackFrameMaterial.diffuse.contents = UIColor.black
        boxGeometry.materials = [imageMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial, blackFrameMaterial]
        return SCNNode(geometry: boxGeometry)
    }
    
    // MARK: - UIEvents
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first!.tapCount == 1 else { return }
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else { return }
        print(sceneView.session.currentFrame!.camera.eulerAngles.z)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        let pointTransform = matrix_multiply(cameraTransform, translation)
        let normalizedZValue = sceneView.projectPoint(SCNVector3Make(pointTransform.columns.3.x, pointTransform.columns.3.y, pointTransform.columns.3.z)).z
        let position = sceneView.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), normalizedZValue))
        
        let paintingNode = paintingCube()
        paintingNode.position = position

        let pitch: Float = 0
        let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
        let orientationCompensation = sceneView.session.currentFrame!.camera.eulerAngles.z < -0.5 ? Float.pi/2 : 0
        let roll = sceneView.session.currentFrame!.camera.eulerAngles.z + orientationCompensation
        let newRotation = SCNVector3Make(pitch, yaw!, roll)
        paintingNode.eulerAngles = newRotation
        sceneView.scene.rootNode.addChildNode(paintingNode)
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
}
