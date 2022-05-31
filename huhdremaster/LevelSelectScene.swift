import SpriteKit
import GameplayKit

class LevelSelectScene: BaseScene {
    var backgroundClouds: BackgroundClouds? = nil
    let backButton: TextButton = TextButton(text: "Back")
    let levelBand: BaseSprite = BaseSprite(imageNamed: "Lvl_Band.png")
    let levelThumb: BaseSprite = BaseSprite(imageNamed: "Philly_Thumb.png")
    let levelTextBox: BaseSprite = BaseSprite(imageNamed: "Lvl_TextBox.png")
    let arrowLeft: BaseSprite = BaseSprite(imageNamed: "LvlArrow.png")
    let arrowRight: BaseSprite = BaseSprite(imageNamed: "LvlArrow.png")
    let titleText: BaseText = BaseText()
    let levelText: BaseText = BaseText()
    var currentLevelIndex: Int = 0
    var allLevels: Array<Level>? = nil
    
    override init() {
        super.init()
        for sprite in [levelBand, levelThumb, levelTextBox, arrowLeft, arrowRight] {
            sprite.setScene(scene: self)
        }
        backButton.setScene(scene: self)
        for text in [titleText, levelText] {
            text.setScene(scene: self)
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        allLevels = getAllLevels()
        
        let background = SKSpriteNode(imageNamed: "Splash_BG_clean.png")
        background.xScale = UIScreen.main.bounds.width / background.size.width
        background.yScale = UIScreen.main.bounds.height / background.size.height
        addChild(background)
        
        backgroundClouds = BackgroundClouds(scene:self)
        
        backButton.setZ(zPosition: 21)
        backButton.setPosition(position: CGPoint(x:-200 * scaleFactor, y:-150 * scaleFactor))
        
        levelBand.zPosition = 20
        
        levelThumb.zPosition = 21
        levelThumb.position = CGPoint(x: 0, y: 20 * scaleFactor)
        
        let currentLevel: Level = allLevels![currentLevelIndex]
        
        levelTextBox.zPosition = 21
        levelTextBox.position = CGPoint(x: 0, y: -90 * scaleFactor)
        levelText.zPosition = 22
        levelText.text = currentLevel.name + "\nHigh score: 000000"
        levelText.numberOfLines = 0
        levelText.position = CGPoint(x: levelTextBox.position.x, y: levelTextBox.position.y - levelTextBox.calculateAccumulatedFrame().height / 2)
        levelText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        titleText.text = "SELECT LEVEL"
        titleText.zPosition = 21
        titleText.fontSize = 40 * scaleFactor
        titleText.position = CGPoint(x: 0, y: 150 * scaleFactor)
        
        arrowLeft.zPosition = 21
        arrowLeft.position = CGPoint(x: -180 * scaleFactor, y:0)
        
        arrowRight.zPosition = 21
        arrowRight.position = CGPoint(x: 180 * scaleFactor, y:0)
        arrowRight.xScale *= -1
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let controller = self.view?.window?.rootViewController as! GameViewController
        if backButton.touchZone.contains(pos) {
            controller.changeScene(key: "title")
        }
        if arrowLeft.contains(pos) {
            currentLevelIndex = currentLevelIndex == 0 ? allLevels!.count - 1 : currentLevelIndex - 1
        }
        if arrowRight.contains(pos) {
            currentLevelIndex = currentLevelIndex == allLevels!.count - 1 ? 0 : currentLevelIndex + 1
        }
        levelText.text = allLevels![currentLevelIndex].name + "\nHigh score: 000000"
        levelThumb.texture = SKTexture(imageNamed: allLevels![currentLevelIndex].thumbnail)
        if levelThumb.contains(pos) {
            controller.changeScene(key: allLevels![currentLevelIndex].slug)
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
}
