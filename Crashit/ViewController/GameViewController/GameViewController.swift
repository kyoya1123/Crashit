import UIKit
import FirebaseDatabase
import SceneKit
import ARKit
import AVFoundation
import AudioToolbox
import ColorThiefSwift

class GameViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var remainingBallLabel: UILabel!
    
    @IBOutlet weak var reflectorImageView: UIImageView!
    @IBOutlet weak var reflectorExpansionLabel: UILabel!
    
    @IBOutlet weak var doubleScoreImageView: UIImageView!
    @IBOutlet weak var doubleScoreLabel: UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var highScoreBlurView: UIVisualEffectView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreBlurView: UIVisualEffectView!
    
    @IBOutlet weak var indicateLabel: UILabel!
    @IBOutlet weak var indicateBlurView: UIVisualEffectView!
    
    @IBOutlet weak var ultimateView: UIView!
    @IBOutlet weak var ultimateButton: UIButton!
    @IBOutlet weak var ultimateGaugeView: UIView!
    
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var quitBlurView: UIVisualEffectView!
    
    let soundEffectPlayer = SoundEffectPlayer.shared
    var playerData: UserDataSet!
    var ultimateType: UltimateType!
    var ballType: BallType!
    var wallNodes: WallNodeSet!
    var ballNodes = [BallNode]()
    var reflectorNode: ReflectorNode!
    var blockNodes: [BlockNode]!
    var remainingBalls = 5
    var highScore = 0
    var score = 0
    var breakCount: Float = 0
    let ultimateRequired: Float = 10
    var reflectorExpansionTimer: Timer!
    var doubleScoreTimer: Timer!
    var usingUltimate = false
    var databaseRef: DatabaseReference!
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator()
    
    var blockColors = [UIColor]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setExclusiveTouch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLabels()
        setupButtons()
        setupBallSelect()
        setupProgress()
        setupFeedback()
    }
}

//MARK: Configuration Methods
extension GameViewController {
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3(0,0,0)
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(ARWorldTrackingConfiguration())
    }
    
    func setupLabels() {
        remainingBallLabel.roundCorner(radius: remainingBallLabel.frame.height / 2)
        remainingBallLabel.text = "×\(remainingBalls)"
        highScoreLabel.text = String(highScore)
        highScoreBlurView.roundCorner(radius: 10)
        scoreBlurView.roundCorner(radius: 10)
        reflectorImageView.roundCorner(radius: 10)
        doubleScoreImageView.roundCorner(radius: 10)
        indicateBlurView.roundCorner(radius: 10)
    }
    
    func setupButtons() {
        quitButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        quitBlurView.roundCorner(radius: 10)
        ultimateButton.addTarget(self, action: #selector(didtapUltimate), for: .touchUpInside)
    }
    
    func setupBallSelect() {
        let ballSelectView = BallSelectView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        ballSelectView.delegate = self
        ballSelectView.playerData = playerData
        ballSelectView.roundCorner(radius: 10)
        ballSelectView.center = view.center
        view.addSubview(ballSelectView)
    }
    
    func setupProgress() {
        ultimateView.roundCorner(radius: ultimateView.frame.height / 2)
    }
    
    func setupFeedback() {
        notificationFeedback.prepare()
        impactFeedback.prepare()
    }
}

//MARK: Action Methods
extension GameViewController {
    
    @objc func didtapScreen() {
        //ボールがない場合新しく発射
        if !ballNodes.isEmpty {
            return
        }
        //ステージエリア外の場合は発射できない
        let position = sceneView.pointOfView!.presentation.position
        let borderCoordinate = wallNodes.borderCoordinate
        if  position.x < borderCoordinate[0] ||
            position.x > borderCoordinate[1] ||
            position.y < borderCoordinate[2] ||
            position.y > borderCoordinate[3] ||
            position.z < borderCoordinate[4] ||
            position.z > borderCoordinate[5] {
            let message = "Go back to stage!"
            if indicateBlurView.isHidden || (indicateLabel.text != message && !indicateLabel.isHidden) {
                DispatchQueue.main.async {
                    self.indicateBlurView.isHidden = false
                    self.indicateLabel.text = message
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.indicateBlurView.isHidden = true
                }
            }
            return
        }
        launchBall()
        DispatchQueue.main.async {
            self.indicateBlurView.isHidden = true
        }
    }
    
    @objc func didtapUltimate() {
        //Ultimateの使用
        breakCount = 0
        DispatchQueue.main.async {
            self.ultimateButton.isEnabled = false
            self.ultimateView.layer.borderWidth = 0
        }
        usingUltimate = true
        switch ultimateType {
        case .explode:
            explode()
        case .split:
            split()
        case .penetrate:
            penetrate()
        case .none:
            return
        }
    }
    
    func penetrate() {
        //貫通
        if !ballNodes.isEmpty {
            ballNodes[0].useUltimate(.penetrate)
            ballNodes[0].collidesWithBlocks(false)
        }
        
        UIView.animate(withDuration: 15, animations: {
            self.ultimateGaugeView.frame.origin.y = self.ultimateGaugeView.frame.height
        }) { _ in
            self.usingUltimate = false
            if !self.ballNodes.isEmpty {
                self.ballNodes[0].removeAllParticleSystems()
                self.ballNodes[0].collidesWithBlocks(true)
            }
        }
    }
    
    func split() {
        //分裂
        usingUltimate = true
        let ball = BallNode(type: ballType)
        ball.position = ballNodes[0].presentation.position
        ball.physicsBody?.velocity = ballNodes[0].physicsBody!.velocity
        ball.physicsBody?.velocity.x += 0.5
        sceneView.scene.rootNode.addChildNode(ball)
        ballNodes.append(ball)
    }
    
    func explode() {
        //爆発
        let geometry = SCNSphere(radius: 0.5)
        let explodeNode = SCNNode(geometry: geometry)
        explodeNode.name = "explode"
        explodeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        explodeNode.physicsBody?.categoryBitMask = NodeType.explode.rawValue
        explodeNode.position = ballNodes[0].presentation.position
        explodeNode.opacity = 0
        ballNodes[0].useUltimate(.explode)
        explodeNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 0.3),
            SCNAction.removeFromParentNode()
        ])) {
            self.ballNodes[0].removeAllParticleSystems()
            self.usingUltimate = false
            DispatchQueue.main.async {
                self.ultimateGaugeView.frame.origin.y = self.ultimateGaugeView.frame.height
            }
        }
        sceneView.scene.rootNode.addChildNode(explodeNode)
    }
}

//MARK: Other Methods
extension GameViewController: ResultViewDelegate, BallSelectViewDelegate {
    
    func didSelectBall() {
        remainingBallLabel.backgroundColor = ballType.uiColor
        highScore = playerData.scoreData[ballType.scoreKey]!
        highScoreLabel.text = String(highScore)
    }
    
    func fetchColors() {
        //ブロックの色の抽出、Ultimate決定
        DispatchQueue.global().async {
            let mainColors = ColorThief.getPalette(from: self.sceneView.snapshot(), colorCount: 5, quality: 10, ignoreWhite: true)!
            let lightColors = mainColors.sorted { $0.lightness > $1.lightness }
            let saturateColors = lightColors.dropFirst().dropLast().sorted { $0.saturation > $1.saturation }
            let saturateColor = saturateColors.first!
            self.blockColors = [lightColors.first!.makeUIColor(), saturateColor.makeUIColor(), lightColors.last!.makeUIColor()]
            print(saturateColor.hue)
            switch saturateColor.hue {
            case 300...360, 0..<60:
                //red
                self.ultimateType = .explode
            case 60..<180:
                //green
                self.ultimateType = .split
            case  180..<300:
                //blue
                self.ultimateType = .penetrate
            default:
                return
            }
        }
    }
    
    func start() {
        indicateLabel.text = "Tap to lanuch!"
        indicateBlurView.isHidden = false
        if ultimateType != nil {
            ultimateButton.setBackgroundImage(ultimateType.image, for: .normal)
        } else {
            ultimateButton.isEnabled = false
        }
        placeReflector(.normal)
        placeWall()
        placeBlock(blockColors)
        BlockGenerationTimer().startTimer(interval: 10) {
            self.placeBlock(self.blockColors)
        }
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didtapScreen)))
        soundEffectPlayer.play(.start)
    }
    
    func placeReflector(_ size: ReflectorSize) {
        //反射板
        if reflectorNode != nil {
            reflectorNode.removeFromParentNode()
        }
        reflectorNode = ReflectorNode(size: size)
        sceneView.scene.rootNode.addChildNode(reflectorNode)
    }
    
    func placeWall() {
        //カメラの前方に壁を生成
        var position = sceneView.pointOfView!.position
        position.z -= 2.8
        wallNodes = WallNodeSet(width: 1, height: 1, depth: 3, thickness: 0.01, position: position)
        sceneView.scene.rootNode.addChildNode(wallNodes.backWall)
        wallNodes.roundWalls.forEach { sceneView.scene.rootNode.addChildNode($0) }
    }
    
    func placeBlock(_ colors: [UIColor]) {
        for _ in 0...5 {
            //ブロックを配置する範囲の算出
            let size = Float.random(in: 0.1...0.3)
            let excess = size / 2
            let blockArea = wallNodes.blockArea
            let xPosition = Float.random(in: blockArea[0] + excess...blockArea[1] - excess)
            let yPosition = Float.random(in: blockArea[2] + excess...blockArea[3] - excess)
            let zPosition = blockArea[4] + excess
            let position = SCNVector3(xPosition, yPosition, zPosition)
            var destination = position
            destination.z = blockArea[5]
            let block = BlockNode(size: CGFloat(size), colors: colors, destination: destination)
            block.position = position
            sceneView.scene.rootNode.addChildNode(block)
        }
    }
    
    func launchBall() {
        remainingBalls -= 1
        DispatchQueue.main.async {
            self.remainingBallLabel.text = "×\(self.remainingBalls)"
            if self.breakCount >= self.ultimateRequired {
                self.ultimateButton.isEnabled = true
            }
        }
        let ballNode = BallNode(type: ballType)
        //デバイスの向いている方向に生成、発射
        let transform = sceneView.pointOfView!.presentation.transform
        let direction = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        ballNode.physicsBody?.velocity = direction
        let cameraPos = SCNVector3(0, 0, -0.05)
        let position = sceneView.pointOfView!.convertPosition(cameraPos, to: nil)
        ballNode.position = position
        if usingUltimate {
            ballNode.useUltimate(.penetrate)
            ballNode.collidesWithBlocks(false)
        }
        sceneView.scene.rootNode.addChildNode(ballNode)
        ballNodes.append(ballNode)
    }
    
    func putCircleNode(_ contact: SCNPhysicsContact) {
        //円のエフェクトを表示
        var position = contact.contactPoint
        var eulerAngles = contact.nodeA.eulerAngles
        let thickness: Float = 0.005
        switch contact.nodeA.name {
        case "w-back":
            position.z = contact.nodeA.position.z + thickness
            eulerAngles.x = -.pi / 2
        case "w-left":
            position.x = contact.nodeA.position.x + thickness
            eulerAngles.x = -.pi / 2
        case "w-right":
            position.x = contact.nodeA.position.x - thickness
            eulerAngles.x = -.pi / 2
        case "w-top":
            position.y = contact.nodeA.position.y - thickness
            eulerAngles.z = -.pi / 2
        case "w-bottom":
            position.y = contact.nodeA.position.y + thickness
            eulerAngles.z = -.pi / 2
        default:
            break
        }
        let circleNode = CircleNode(size: 0.03, position: position, eulerAngles: eulerAngles)
        sceneView.scene.rootNode.addChildNode(circleNode)
    }
    
    func addScore(_ block: BlockNode) {
        if doubleScoreTimer != nil && doubleScoreTimer.isValid {
            score += block.point * 2
        } else {
            score += block.point
        }
        if score > highScore {
            highScore = score
        }
        DispatchQueue.main.async {
            self.scoreLabel.text = String(self.score)
            self.highScoreLabel.text = String(self.highScore)
        }
    }
    
    func updateUltimateGauge() {
        //Ultimateゲージ更新
        if ultimateType == nil || usingUltimate { return }
        breakCount += 1
        DispatchQueue.main.async {
            if self.breakCount <= self.ultimateRequired {
                self.ultimateGaugeView.frame.origin.y = (self.ultimateButton.frame.origin.y + 80) - CGFloat(self.breakCount * (Float(self.ultimateGaugeView.frame.height) / self.ultimateRequired))
                if self.breakCount == self.ultimateRequired {
                    self.ultimateButton.isEnabled = true
                    self.ultimateView.layer.borderWidth = 5
                    self.ultimateView.layer.borderColor = self.ultimateGaugeView.backgroundColor!.darkerColor()
                }
            }
        }
    }
    
    func spawnItem(_ block: BlockNode) {
        //一定確率でアイテム出現
        let rand = Int.random(in: 0..<100)
        if !(0..<5 ~= rand) { return }
        var itemNode: ItemNode!
        var destination = block.position
        destination.z = wallNodes.borderCoordinate[5]
        switch rand {
        case 0..<1:
            itemNode = ItemNode(type: .addBall, destination: destination)
        case 1..<3:
            itemNode = ItemNode(type: .expandReflector, destination: destination)
        case 3..<5:
            itemNode = ItemNode(type: .doubleScore, destination: destination)
        default:
            break
        }
        itemNode.position = block.position
        sceneView.scene.rootNode.addChildNode(itemNode)
    }
    
    func expandReflector(for interval: Int) {
        //リフレクターの拡張
        DispatchQueue.main.async {
            self.reflectorExpansionLabel.text = interval.timerFormat
        }
        if reflectorExpansionTimer != nil {
            reflectorExpansionTimer.invalidate()
        }
        placeReflector(.big)
        DispatchQueue.main.async {
            self.reflectorExpansionLabel.isHidden = false
            self.reflectorImageView.isHidden = false
        }
        reflectorExpansionTimer = ItemTimer().startTimer(time: interval, timerEnded: {
            self.placeReflector(.normal)
            DispatchQueue.main.async {
                self.reflectorExpansionLabel.isHidden = true
                self.reflectorImageView.isHidden = true
            }
        }) { count in
            DispatchQueue.main.async {
                self.reflectorExpansionLabel.text = count.timerFormat
            }
        }
    }
    
    func addBall() {
        //ボール+1
        remainingBalls += 1
        DispatchQueue.main.async {
            self.remainingBallLabel.text = "×\(self.remainingBalls)"
        }
    }
    
    func doubleScore(for interval: Int) {
        //加算スコア2倍
        DispatchQueue.main.async {
            self.doubleScoreLabel.text = interval.timerFormat
        }
        if doubleScoreTimer != nil {
            doubleScoreTimer.invalidate()
        }
        DispatchQueue.main.async {
            self.doubleScoreLabel.isHidden = false
            self.doubleScoreImageView.isHidden = false
        }
        doubleScoreTimer = ItemTimer().startTimer(time: interval, timerEnded: {
            DispatchQueue.main.async {
                self.doubleScoreLabel.isHidden = true
                self.doubleScoreImageView.isHidden = true
            }
        }) { count in
            DispatchQueue.main.async {
                self.doubleScoreLabel.text = count.timerFormat
            }
        }
    }
    
    func wentOut(_ ball: BallNode) {
        //外に出た場合
        ball.removeFromParentNode()
        ballNodes.remove(at: ballNodes.firstIndex(of: ball)!)
        if !ballNodes.isEmpty {
            usingUltimate = false
            DispatchQueue.main.async {
                self.ultimateGaugeView.frame.origin.y = self.ultimateGaugeView.frame.height
            }
            return
        }
        
        DispatchQueue.main.async {
            self.ultimateButton.isEnabled = false
        }
        notificationFeedback.notificationOccurred(.error)
        soundEffectPlayer.play(.missed)
        if remainingBalls == 0 {
            gameOver()
            return
        } else {
            DispatchQueue.main.async {
                self.indicateLabel.text = "Tap to launch!"
                self.indicateBlurView.isHidden = false
            }
        }
        wallNodes.changeTexture(.missed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.wallNodes.changeTexture(.normal)
        }
    }
    
    func gameOver() {
        //残ボールゼロの場合
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        soundEffectPlayer.play(.gameover)
        DispatchQueue.main.async {
            self.sceneView.gestureRecognizers = nil
        }
        wallNodes.changeTexture(.missed)
        sceneView.scene.rootNode.removeAllActions()
        DispatchQueue.main.async {
            self.showResult()
        }
    }
    
    func showResult() {
        //結果表示
        let resultView = ResultView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        resultView.score = score
        resultView.playerData = playerData
        resultView.ballType = ballType
        resultView.delegate = self
        view.addSubview(resultView)
        databaseRef = Database.database().reference().child("users")
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        databaseRef.child(deviceID).updateChildValues([ballType.scoreKey : highScore])
    }
    
    //ResultViewDelegate
    @objc func backToHome() {
        dismiss(animated: true, completion: nil)
    }
}

extension GameViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //リフレクターのtransformとカメラのtransformを同期
        if let reflector = reflectorNode {
            reflector.transform = sceneView.pointOfView!.presentation.transform
        }
        
        if ballNodes.isEmpty { return }
        
        ballNodes.forEach { ball in
            //ボールのVelocity調整、奥に留まらないようにする
            var velocity = ball.physicsBody!.velocity.normalized()
            if abs(velocity.x) < 0.005 {
                velocity.x += 0.02 * sign(velocity.x)
            }
            if abs(velocity.y) < 0.005 {
                velocity.y += 0.02 * sign(velocity.y)
            }
            if abs(velocity.z) < 0.6 {
                velocity.z += 0.05 * sign(velocity.z)
            }
            ball.physicsBody?.velocity = velocity * ballType.speed
            //エリア外に出たらアウト
            if !wallNodes.borderCoordinate.isEmpty {
                let borderCoordinate = wallNodes.borderCoordinate
                let position = ball.presentation.position
                let tolerance: Float = 0.1
                if  position.x < borderCoordinate[0] - tolerance ||
                    position.x > borderCoordinate[1] + tolerance ||
                    position.y < borderCoordinate[2] - tolerance ||
                    position.y > borderCoordinate[3] + tolerance ||
                    position.z < borderCoordinate[4] - tolerance ||
                    position.z > borderCoordinate[5] + tolerance  {
                    wentOut(ball)
                }
            }
        }
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeNames = [contact.nodeA.name, contact.nodeB.name]
        //Collisionが起こった時の処理
        
        if nodeNames.contains("reflector") {
            soundEffectPlayer.play(.hitWall)
        }
        
        if nodeNames[0]!.hasPrefix("w") {
            putCircleNode(contact)
            soundEffectPlayer.play(.hitWall)
        } else if nodeNames.contains("block") || nodeNames.contains("explode") {
            //ブロックとの衝突
            let touchedObject = nodeNames[0] == "block" ? contact.nodeA : contact.nodeB
            impactFeedback.impactOccurred()
            let blockNode = touchedObject as! BlockNode
            addScore(blockNode)
            updateUltimateGauge()
            spawnItem(blockNode)
            soundEffectPlayer.play(.breakBlock)
            sceneView.scene.rootNode.addChildNode(BlockParticleNode(position: touchedObject.position))
            touchedObject.removeFromParentNode()
        } else if nodeNames.contains("item") {
            //アイテムとリフレクターの衝突
            let touchedObject = nodeNames[0] == "item" ? contact.nodeA : contact.nodeB
            let item = touchedObject as! ItemNode
            switch item.type {
            case .addBall:
                addBall()
            case .expandReflector:
                expandReflector(for: 20)
            case .doubleScore:
                doubleScore(for: 20)
            case .none:
                break
            }
            soundEffectPlayer.play(.item)
            touchedObject.removeFromParentNode()
        }
    }
}
