import SceneKit

class CircleNode: SCNNode {
    
    init(size: CGFloat, position: SCNVector3, eulerAngles: SCNVector3) {
        super.init()
        let geometry = SCNCone(topRadius: size, bottomRadius: size, height: 0.001)
        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = UIColor.white
        self.geometry = geometry
        self.eulerAngles = eulerAngles
        self.position = position
        self.castsShadow = false
        self.runAction(SCNAction.sequence([
            SCNAction.scale(to: 0, duration: 0.5),
            SCNAction.removeFromParentNode()
            ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
