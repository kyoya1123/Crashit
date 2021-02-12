import UIKit
import Firebase

class ResultView: UIView {
    
    @IBOutlet weak var ballImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonBlurView: UIVisualEffectView!
    @IBOutlet weak var backButton: UIButton!
    
    var score: Int!
    var playerData: UserDataSet!
    var ballType: BallType!
    var delegate: ResultViewDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("ResultView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func didMoveToSuperview() {
        setupImageView()
        setupLabel()
        setupButton()
    }
    
    func setupImageView() {
        ballImageView.image = UIImage(named: ballType.rawValue)
        ballImageView.roundCorner(radius: ballImageView.frame.height / 2)
    }
    
    func setupLabel() {
        scoreLabel.text = String(score)
        let highScore = playerData.scoreData[ballType.scoreKey]!
        if score >= highScore {
            messageLabel.text = "New Record!"
        } else {
            messageLabel.text = "high score: \(highScore)"
        }
    }
    
    func setupButton() {
        buttonBlurView.roundCorner(radius: buttonBlurView.frame.height / 2)
        backButton.addTarget(self, action: #selector(didtapBack), for: .touchUpInside)
    }
    
    @objc func didtapBack() {
        delegate?.backToHome()
    }

}

protocol ResultViewDelegate {
    func backToHome()
}
