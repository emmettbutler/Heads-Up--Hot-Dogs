import SpriteKit
import GameplayKit

class OptionsScene: BaseScene {
    var backgroundClouds: BackgroundClouds? = nil
    let backButton: TextButton = TextButton(text: "Back")
    let overlay: BaseSprite = BaseSprite(imageNamed: "Options_Overlay.png")
    let creditsButton: TextButton = TextButton(text: "Credits", image: "Options_Btn.png")
    let scoresButton: TextButton = TextButton(text: "Clear Scores", image: "Options_Btn.png")
    let sfxButton: TextButton = TextButton(text: "SFX Off", image: "Options_Btn.png")
    let creditsBackground:SKSpriteNode = SKSpriteNode(imageNamed: "Pause_BG.png")
    let creditsTitle: BaseText = BaseText()
    let creditsText: BaseText = BaseText()
    
    override init() {
        super.init()
        overlay.setScene(scene: self)
        for button in [backButton, creditsButton, scoresButton, sfxButton] {
            button.setScene(scene: self)
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Splash_BG_clean.png")
        background.xScale = UIScreen.main.bounds.width / background.size.width
        background.yScale = UIScreen.main.bounds.height / background.size.height
        addChild(background)
        
        backgroundClouds = BackgroundClouds(scene:self)
        
        overlay.zPosition = 2
        
        backButton.setZ(zPosition: 21)
        backButton.setPosition(position: CGPoint(x:UIScreen.main.bounds.width / -2 + backButton.buttonBackground.calculateAccumulatedFrame().width + 20 * scaleFactor,
                                                 y:UIScreen.main.bounds.height / -4))
        
        scoresButton.setZ(zPosition: 21)
        scoresButton.setPosition(position: CGPoint(x:0, y:creditsButton.buttonBackground.calculateAccumulatedFrame().height * 2))
        
        creditsButton.setZ(zPosition: 21)
        creditsButton.setPosition(position: CGPoint(x:0, y:0))
        
        sfxButton.setZ(zPosition: 21)
        sfxButton.setPosition(position: CGPoint(x:0, y:creditsButton.buttonBackground.calculateAccumulatedFrame().height * -2))
        
        creditsBackground.xScale = UIScreen.main.bounds.width / creditsBackground.size.width
        creditsBackground.yScale = UIScreen.main.bounds.height / creditsBackground.size.height
        creditsBackground.zPosition = 80
        creditsBackground.isHidden = true
        addChild(creditsBackground)
        
        creditsTitle.text = "Credits"
        creditsTitle.position = CGPoint(x: 0,
                                        y: UIScreen.main.bounds.height / 2 - creditsTitle.calculateAccumulatedFrame().height - 10 * scaleFactor)
        creditsTitle.zPosition = 81
        creditsTitle.isHidden = true
        creditsTitle.setScene(scene: self)
        
        creditsText.text = "Emmett Butler: design & program\nDiego Garcia: design & art\nMusic: Benjamin Carignan - \"Space Boyfriend\"\nLuke Silas - \"knife city\"\nTesters: Nick Johnson, Dave Mauro, Nina Freeman, Sam Bosma, Kali Ciesemier, Grace Yang, Mike Bartnett, Aaron Koenigsberg, Zach Cimafonte, Noah Lemen\nSpecial thanks to Muhammed Ali Khan and Anna Anthropy"
        creditsText.position = CGPoint(x: 0, y: 0)
        creditsText.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.9
        creditsText.zPosition = 81
        creditsText.numberOfLines = 0
        creditsText.isHidden = true
        creditsText.setScene(scene: self)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if backButton.touchZone.contains(pos) {
            let controller = self.view?.window?.rootViewController as! GameViewController
            controller.changeScene(key: nil)
        }
        if (creditsBackground.isHidden == true && creditsButton.touchZone.contains(pos)) ||
            creditsBackground.isHidden == false
        {
            toggleCredits()
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func toggleCredits() {
        creditsBackground.isHidden = !creditsBackground.isHidden
        creditsTitle.isHidden = !creditsTitle.isHidden
        creditsText.isHidden = !creditsText.isHidden
    }
}
