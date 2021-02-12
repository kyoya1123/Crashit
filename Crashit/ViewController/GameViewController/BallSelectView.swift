import UIKit
import Firebase

class BallSelectView: UIView {
    
    @IBOutlet weak var infoBlurView: UIVisualEffectView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var selectBallLabel: UILabel!
    @IBOutlet var ballButtons: [UIButton]!
    @IBOutlet var ballImageViews: [UIImageView]!
    @IBOutlet var difficultyLabels: [UILabel]!
    @IBOutlet var scoreLabels: [UILabel]!
    
    var playerData: UserDataSet!
    var ballType: BallType!
    var delegate: BallSelectViewDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("BallSelectView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func didMoveToSuperview() {
        setupViews()
    }
    
    func setupViews() {
        ballImageViews.forEach {
            $0.roundCorner(radius: $0.frame.height / 2)
        }
        ballButtons.forEach {
            let colorImage = #colorLiteral(red: 0.6648618579, green: 0.6648618579, blue: 0.6648618579, alpha: 0.4).createImage()
            $0.setBackgroundImage(colorImage, for: .highlighted)
            $0.roundCorner(radius: 5)
            $0.addTarget(self, action: #selector(didSelectBall), for: .touchUpInside)
        }
        scoreLabels.forEach {
            let key = BallType.allCases[$0.tag].scoreKey
            $0.text = String(playerData.scoreData[key]!)
        }
    }
    
    func countdown() {
        //開始のカウントダウン
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.infoLabel.font = UIFont(name: "Futura-medium", size: 100)
            self.infoLabel.text = "3"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.infoLabel.text = "2"
            self.delegate?.fetchColors()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            self.infoLabel.text = "1"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.removeFromSuperview()
            self.delegate?.start()
        }
    }
    
    @objc func didSelectBall(_ sender: UIButton) {
        ballButtons.forEach { $0.isHidden = true }
        ballImageViews.forEach { $0.isHidden = true }
        difficultyLabels.forEach { $0.isHidden = true }
        scoreLabels.forEach { $0.isHidden = true }
        selectBallLabel.isHidden = true
        infoLabel.isHidden = false
        delegate?.ballType = BallType.allCases[sender.tag]
        delegate?.didSelectBall()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.delegate?.setupScene()
            self.countdown()
        }
    }
}

protocol BallSelectViewDelegate {
    var ballType: BallType! { get set }
    func didSelectBall()
    func fetchColors()
    func setupScene()
    func start()
}
