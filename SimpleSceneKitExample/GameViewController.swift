//
//  GameViewController.swift
//  SimpleSceneKitExample
//
//  Created by Ram Mhapasekar on 28/03/17.
//  Copyright © 2017 rammhapasekar. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var gameView: SCNView!
    
    @IBOutlet weak var scoreLbl: UILabel!
    
    @IBOutlet weak var life: UILabel!
    
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0

    var radius: CGFloat = 1
    var score = 0
    var lifes =  10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
    }
    
    func initView(){
        
        gameView.backgroundColor = UIColor.clear
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }

    
    func initScene(){
        
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initCamera(){
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createTarget(r: CGFloat){
        let geometry: SCNGeometry = SCNSphere(radius: r)
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.cyan : UIColor.orange
        geometry.materials.first?.diffuse.contents = randomColor
        
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.orange{
            geometryNode.name = "enemy"
        }
        else{
            geometryNode.name = "friend"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y:0.05, z:0.05), asImpulse: true)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if time > targetCreationTime{
            createTarget(r: radius)
            
            if radius > 0.90{
              targetCreationTime = time + 0.6
            }
            else if radius > 0.80 && radius <= 90{
                targetCreationTime = time + 0.5
            }
            else if radius > 0.70 && radius <= 80{
                targetCreationTime = time + 0.4
            }
            else if radius > 0.60 && radius <= 70{
                targetCreationTime = time + 0.3
            }
            else{
                targetCreationTime = time + 0.2
            }
        }
        
        cleanup()
    }
    
    func cleanup(){
    
        for node in gameScene.rootNode.childNodes{
           if node.presentation.position.y < -2{
                node.removeFromParentNode()
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let location = touch?.location(in: gameView)
        
        let hitList = gameView.hitTest(location!, options: nil)
        
        if let hitObject = hitList.first{
            
            let node = hitObject.node

            if node.name == "friend"{
                score += 1
                scoreLbl.textColor = UIColor.white
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.clear
            }
            else{
                score -= 1
                lifes -= 1
                scoreLbl.textColor = UIColor.orange
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
                if radius > 0.45{
                    radius -= 0.05
                }
            }
            scoreLbl.text = "\(score)"
            
            if lifes < 10{
                
                lifes = score % 100 == 0 ? lifes+1 : lifes
            }
            life.text = "\(lifes)"
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
