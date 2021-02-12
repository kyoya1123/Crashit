import SceneKit

class BlockParticleNode: SCNNode {
    
    init(position: SCNVector3) {
        super.init()
        let particleSystem = SCNParticleSystem(named: "block.scnp", inDirectory: "art.scnassets")
        self.addParticleSystem(particleSystem!)
        self.position = position
        self.runAction(SCNAction.wait(duration: Double((particleSystem?.particleLifeSpan)!))) {
            self.removeFromParentNode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
