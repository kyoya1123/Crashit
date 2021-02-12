import UIKit

class HelpView: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var itemImageViews: [UIImageView]!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("HelpView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func didMoveToSuperview() {
        setupButton()
        setupImageViews()
    }
    
    func setupImageViews() {
        itemImageViews.forEach { $0.roundCorner(radius: 10) }
    }
    
    func setupButton() {
        closeButton.roundCorner(radius: closeButton.frame.height / 2)
        closeButton.addTarget(self, action: #selector(didtapClose), for: .touchUpInside)
    }
    
    @objc func didtapClose() {
        self.removeFromSuperview()
    }
}
