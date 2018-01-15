//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Rafsan Chowdhury on 1/12/18.
//  Copyright © 2018 appimas24. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    var startingPosition: SCNNode?
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.delegate = self
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let currentFrame = sceneView.session.currentFrame else {return}
        
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        
        let camera = currentFrame.camera // Gives us information about POV and etc
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4 // 4X4 matrix
        translationMatrix.columns.3.z = -0.1
        var modifiedMatrix = simd_mul(transform, translationMatrix)
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = modifiedMatrix // Node will be position exactly where the phone is
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // triggered 60 times a second
        guard let startingPosition = self.startingPosition else {return} // Only if user tapped on a starting position
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = String(format: "%.2f", zDistance) + "m"
            self.distance.text = String(format: "%.2f", self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance))
        }
    }
    
    func distanceTravelled(x: Float, y: Float, z: Float) -> Float {
        
        return (sqrtf(x*x + y*y + z*z))
    }
}

