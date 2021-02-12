import UIKit
import Firebase

class TopViewController: UIViewController {
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var endlessButton: UIButton!
    @IBOutlet var ballSelectButtons: [UIButton]!
    @IBOutlet weak var rankingTable: UITableView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var playerRankLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    var databaseRef: DatabaseReference!
    var userData = [UserDataSet]()
    var ballType: BallType!
    var playerData: UserDataSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setExclusiveTouch()
        databaseRef = Database.database().reference().child("users")
        setupTextField()
        setupButtons()
        setupRankingTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //データ取得後にtable表示
        loadUserData()
    }
}

//MARK: Configuration Methods
extension TopViewController {
    
    func setupTextField() {
        nameTextField.layer.borderColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6)
        nameTextField.layer.borderWidth = 2
        nameTextField.roundCorner(radius: nameTextField.frame.height / 2)
        nameTextField.delegate = self
    }
    
    func setupButtons() {
        speakerButton.addTarget(self, action: #selector(didtapSpeaker), for: .touchUpInside)
        speakerButton.roundCorner(radius: speakerButton.frame.height / 2)
        helpButton.roundCorner(radius: helpButton.frame.height / 2)
        helpButton.addTarget(self, action: #selector(didtapHelp), for: .touchUpInside)
        endlessButton.roundCorner(radius: endlessButton.frame.height / 2)
        endlessButton.addTarget(self, action: #selector(didtapEndless), for: .touchUpInside)
        ballSelectButtons.forEach {
            $0.roundCorner(radius: $0.frame.height / 2)
            $0.addTarget(self, action: #selector(changeTable), for: .touchDown)
        }
    }
    
    func enableBallSelect() {
        if ballType == nil {
            changeTable(ballSelectButtons[1])
        } else {
            changeTable(ballSelectButtons[BallType.allCases.firstIndex(of: ballType)!])
        }
    }
    
    func setupRankingTable() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .white
        rankingTable.refreshControl = refreshControl
        rankingTable.dataSource = self
        rankingTable.register(UINib(nibName: "RankingTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        rankingTable.tableFooterView = UIView()
    }
}

//MARK: Action Methods
extension TopViewController {
    
    @objc func didtapSpeaker() {
        SoundEffectPlayer.shared.isEnabled.toggle()
        if SoundEffectPlayer.shared.isEnabled {
            speakerButton.setImage(UIImage(systemName: "speaker"), for: .normal)
        } else {
            speakerButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        }
    }
    
    @objc func didtapHelp() {
        let helpView = HelpView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(helpView)
    }
    
    @objc func didtapEndless() {
        let gameView = self.storyboard!.instantiateViewController(withIdentifier: "GameView") as! GameViewController
        gameView.playerData = playerData
        gameView.modalPresentationStyle = .fullScreen
        present(gameView, animated: true, completion: nil)
    }
    
    @objc func changeTable(_ sender: UIButton) {
        ballSelectButtons.forEach {
            $0.isEnabled = true
            $0.isHighlighted = false
        }
        sender.isHighlighted = true
        sender.isEnabled = false
        ballType = BallType.allCases[sender.tag]
        let key = ballType.scoreKey
        userData.sort { $0.scoreData[key]! > $1.scoreData[key]! }
        userData.forEach {
            if $0.deviceID == UIDevice.current.identifierForVendor?.uuidString {
                updatePlayerLabel($0)
            }
        }
        rankingTable.reloadData()
        rankingTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        loadUserData {
            self.rankingTable.reloadData()
            sender.endRefreshing()
        }
    }
}

//MARK: Other Methods
extension TopViewController {
    
    func loadUserData(completion: @escaping () -> Void = {}) {
        nameTextField.isEnabled = false
        fetchUserData {
            self.enableBallSelect()
            self.userData.sort { $0.scoreData[self.ballType.scoreKey]! > $1.scoreData[self.ballType.scoreKey]! }
            self.rankingTable.reloadData()
            self.nameTextField.text = self.playerData.name
            self.nameTextField.isEnabled = true
            self.endlessButton.isEnabled = true
            completion()
        }
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
        fetchPlayerData {
            //他のユーザーのデータ取得
            self.databaseRef.observeSingleEvent(of: .value) { snapshot in
                let dataArray = snapshot.children.allObjects as! [DataSnapshot]
                self.userData = dataArray.map { UserDataSet($0.value as! [String : Any]) }
                self.userData.forEach {
                    if $0.deviceID == UIDevice.current.identifierForVendor?.uuidString {
                        self.playerData = $0
                    }
                }
                completion()
            }
        }
    }
    
    func fetchPlayerData(completion: @escaping () -> Void) {
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        databaseRef.child(deviceID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                //自分のスコア取得
                let data = snapshot.value as! [String : Any]
                self.playerData = UserDataSet(data)
                completion()
            } else {
                //サーバーに記録がない場合
                self.databaseRef.child(deviceID).setValue(
                    ["name" : UIDevice.current.name,
                     BallType.green.scoreKey : 0,
                     BallType.blue.scoreKey : 0,
                     BallType.red.scoreKey : 0,
                     "deviceID" : deviceID]) { _, _ in
                        completion()
                }
            }
        }
    }
    
    func updateName(_ name: String, completion: @escaping () -> Void) {
        //名前変更
        userData.forEach {
            if $0.deviceID == UIDevice.current.identifierForVendor?.uuidString {
                $0.name = name
                playerData = $0
            }
        }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        databaseRef.child(deviceID).updateChildValues(["name" : nameTextField.text!]) { _, _ in
            completion()
        }
    }
    
    func updatePlayerLabel(_ user: UserDataSet) {
        let rank = userData.firstIndex(of: user)! + 1
        let score = user.scoreData[ballType.scoreKey]!
        playerRankLabel.text = "rank:  \(rank)"
        playerScoreLabel.text = "score: \(score)"
    }
}

extension TopViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let typedText = textField.text!
        if typedText.isEmpty || playerData.name == typedText {
            textField.text = playerData.name
        } else {
            updateName(textField.text!) {
                self.rankingTable.reloadData()
            }
        }
    }
}

extension TopViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RankingTableViewCell else { return UITableViewCell() }
        let rank = indexPath.row + 1
        let user = userData[indexPath.row]
        let key = ballType.scoreKey
        let score = user.scoreData[key]!
        cell.setupLabels(rank, user, score, ballType)
        return cell
    }
}
