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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var paintingPlane: SCNPlane {
        // 1 in = 0.0254 m
        let height: CGFloat = 18
        let width: CGFloat = 6
        let plane = SCNPlane(width: width * 0.0254, height: height * 0.0254)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = UIImage(named: "cat.jpg")
        plane.materials = [imageMaterial]
        return plane
    }
    var planes = [ARPlaneAnchor: SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSceneView()
        setUpTapGestureRecognizer()
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
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene = SCNScene()
    }
    
    func setUpTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpARWorldTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    // Inserting 3D Geometry for ARHitTestResult
    func insertGeometry(for result: ARHitTestResult) {
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let cube = SCNNode(geometry: boxGeometry)
        
        // Method 1: Add Anchor to the scene
        sceneView.session.add(anchor: result.anchor!)
        
        // OR
        
        // Method 2: Add SCNNode at position
        let position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
            )
        cube.position = position
        sceneView.scene.rootNode.addChildNode(cube)
    }
    
//     Intercept a touch on screen and hit-test against a plane surface
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let point = touch.location(in: sceneView)
//
//        let result = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
//        guard result.count > 0 else {
//            print("No plane surfaces found")
//            return
//        }
//
//        insertGeometry(for: result[0])
//    }
//
    // Get transform using ARCamera
    
    func getCameraPosition() -> SCNVector3? {
        guard let lastFrame = sceneView.session.currentFrame else {
            return nil
        }
        let position = lastFrame.camera.transform * float4(x: 0, y: 0, z: 0, w: 1)
        let vector: SCNVector3 = SCNVector3(position.x, position.y, position.z)
        return vector
    }
    
    func getCameraTransform(for camera: ARCamera) -> MDLTransform {
        return MDLTransform(matrix: camera.transform)
    }
    
    
    // Intercept touch and place object not on plane
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first!.tapCount == 1 else { return }
        guard let camera = sceneView.session.currentFrame?.camera else { return }
        
        
        // Get touch point
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        
//        // Compute near & far points
//        let nearVector = SCNVector3(x: Float(touchPoint.x), y: Float(touchPoint.y), z: 0)
//        let nearScenePoint = sceneView.unprojectPoint(nearVector)
//        let farVector = SCNVector3(x: Float(touchPoint.x), y: Float(touchPoint.y), z: 1)
//        let farScenePoint = sceneView.unprojectPoint(farVector)
//
//        // Compute view vector
//        let viewVector = SCNVector3(x: Float(farScenePoint.x - nearScenePoint.x), y: Float(farScenePoint.y - nearScenePoint.y), z: Float(farScenePoint.z - nearScenePoint.z))
//
//        // Normalize view vector
//        let vectorLength = sqrt(viewVector.x*viewVector.x + viewVector.y*viewVector.y + viewVector.z*viewVector.z)
//        let normalizedViewVector = SCNVector3(x: viewVector.x/vectorLength, y: viewVector.y/vectorLength, z: viewVector.z/vectorLength)
//
//        // Scale normalized vector to find scene point
//        let scale = Float(1.2)
//        let scenePoint = SCNVector3(x: normalizedViewVector.x*scale, y: normalizedViewVector.y*scale, z: normalizedViewVector.z*scale)
//
//        print("2D point: \(touchPoint). 3D point: \(nearScenePoint). Far point: \(farScenePoint). scene point: \(scenePoint)")
//        //5. Create An SCNBox At The Point
//        let boxNode = SCNNode()
//        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        boxNode.geometry = boxGeometry
//        boxNode.position = scenePoint
//        sceneView.scene.rootNode.addChildNode(boxNode)
        
        

        //1. Get The Current Touch Point
//        guard let currentTouchPoint = touches.first,
//            //2. Perform A Hit Test Against Any Feature Points
//            let result = sceneView.hitTest(currentTouchPoint.location(in: sceneView), types: .featurePoint).last else { return }
//
//
//        //3. Get The World Coordinates Of The Result
//        let transform = SCNMatrix4(result.worldTransform)
//
//        //4. Get The Positional Data From The Transform
//        let vectorFromTransform = SCNVector3(transform.m41, transform.m42, transform.m43)
//
//        //5. Create An SCNBox At The Point
//        let boxNode = SCNNode()
//        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        boxNode.geometry = boxGeometry
//        boxNode.position = vectorFromTransform
//        sceneView.scene.rootNode.addChildNode(boxNode)
//
//        let projectedOrigin = sceneView.projectPoint(SCNVector3Make(0, 0, -0.8))
//        let vp = touchPoint
//        let vpWithZ = SCNVector3(x: Float(vp.x), y: Float(vp.y), z:  projectedOrigin.z)
//        let worldPoint = sceneView.unprojectPoint(vpWithZ)
//

        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let cube = SCNNode(geometry: boxGeometry)
        // set up z translation for 20 cm in front of whatever
        // last column of a 4x4 transform matrix is translation vector
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.8
        
        // get camera transform the ARKit way
        let cameraTransform = sceneView.session.currentFrame!.camera.transform
        // if we wanted, we could go the SceneKit way instead; result is the same
        // let cameraTransform = view.pointOfView.simdTransform
        
        // set node transform by multiplying matrices
        //cube.simdTransform = cameraTransform * translation
        let point = cameraTransform * translation
        let normalizedZValue = sceneView.projectPoint(SCNVector3Make(point.columns.3.x, point.columns.3.y, point.columns.3.z)).z
        let position = sceneView.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), normalizedZValue))
        cube.position = position
//        var translation = matrix_identity_float4x4
//        translation.columns.3.x = Float(touchPoint.x)
//        translation.columns.3.y = Float(touchPoint.y)
//        translation.columns.3.z = -0.8
        //cube.position = worldPoint
        //cube.simdTransform = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translation)
        sceneView.scene.rootNode.addChildNode(cube)
    }
//
//
//    func pointInFrontOfPoint(point: SCNVector3, direction: SCNVector3, distance: Float) -> SCNVector3 {
//        var x = Float()
//        var y = Float()
//        var z = Float()
//
//        x = point.x + distance * direction.x
//        y = point.y + distance * direction.y
//        z = point.z + distance * direction.z
//
//        let result = SCNVector3Make(x, y, z)
//        return result
//    }
//
//    func calculateCameraDirection(cameraNode: SCNNode) -> SCNVector3 {
//        let x = -cameraNode.rotation.x
//        let y = -cameraNode.rotation.y
//        let z = -cameraNode.rotation.z
//        let w = cameraNode.rotation.w
//        let cameraRotationMatrix = GLKMatrix3Make(cos(w) + pow(x, 2) * (1 - cos(w)),
//                                                  x * y * (1 - cos(w)) - z * sin(w),
//                                                  x * z * (1 - cos(w)) + y*sin(w),
//
//                                                  y*x*(1-cos(w)) + z*sin(w),
//                                                  cos(w) + pow(y, 2) * (1 - cos(w)),
//                                                  y*z*(1-cos(w)) - x*sin(w),
//
//                                                  z*x*(1 - cos(w)) - y*sin(w),
//                                                  z*y*(1 - cos(w)) + x*sin(w),
//                                                  cos(w) + pow(z, 2) * ( 1 - cos(w)))
//
//        let cameraDirection = GLKMatrix3MultiplyVector3(cameraRotationMatrix, GLKVector3Make(0.0, 0.0, -1.0))
//        return SCNVector3FromGLKVector3(cameraDirection)
//    }
//
    
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let transform = sceneView.session.currentFrame!.camera.transform
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        
        
//        let tapLocation = recognizer.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
//
//        guard let hitTestResult = hitTestResults.first else { return }
//        let translation = hitTestResult.worldTransform.columns.3
//        let x = translation.x
//        let y = translation.y
//        let z = translation.z
//
//        let planeNode = SCNNode(geometry: paintingPlane)
//        planeNode.position = SCNVector3(x,y,z)
//        sceneView.scene.rootNode.addChildNode(planeNode)
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        addPlane(for: node, at: anchor)
    }
    
    
    func addPlane(for node: SCNNode, at anchor: ARPlaneAnchor) {
        let w = CGFloat(anchor.extent.x)
        let h = CGFloat(anchor.extent.z)
        //let l = CGFloat(anchor.extent.z)
        
        let plane = SCNPlane(width: w, height: h)
        plane.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(
            anchor.center.x,
            anchor.center.y,
            anchor.center.z
        )
        planeNode.eulerAngles.x = -.pi / 2
        planes[anchor] = planeNode
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        updatePlane(for: anchor)
    }
    
    func updatePlane(for anchor: ARPlaneAnchor) {
        // Pull the plane that needs to get updated
        let plane = self.planes[anchor]
        
        // Update its geometry
        if let geometry = plane?.geometry as? SCNBox {
            geometry.width  = CGFloat(anchor.extent.x)
            geometry.length = CGFloat(anchor.extent.y)
            geometry.height = 0.01
        }
        
        // Update its position
        plane?.position = SCNVector3(
            anchor.center.x,
            anchor.center.y,
            anchor.center.z
        )
    }
    
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
