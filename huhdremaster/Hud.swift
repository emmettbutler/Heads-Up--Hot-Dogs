import SpriteKit

class HeadsUpDisplay: BaseSprite {
    let backgroundTexture: SKTexture = SKTexture(imageNamed: "DogHud_BG.png")
    let hotDogTexture: SKTexture = SKTexture(imageNamed: "DogHud_Dog.png")
    var xTextures: [SKTexture] = [SKTexture]()
    var indicators: [BaseSprite] = [BaseSprite]()
    var subtractAnimation: SKAction? = nil
    
    init(scene: BaseScene) {
        super.init(texture: backgroundTexture)
        self.setScene(scene: scene)
        
        self.zPosition = 60
        self.position = CGPoint(x: 0, y: UIScreen.main.bounds.height / 2 - 50 * scene.scaleFactor)
        
        for idx in (-2 ... 2).reversed() {
            let indicator = BaseSprite(texture: hotDogTexture)
            indicator.setScene(scene: scene)
            indicator.zPosition = self.zPosition + 1
            indicator.position = CGPoint(
                x: self.position.x + (CGFloat(idx) * (indicator.calculateAccumulatedFrame().width + 7 * scene.scaleFactor)),
                y: self.position.y)
            indicators.append(indicator)
        }
        
        for idx in 1 ... 6 {
            xTextures.append(SKTexture(imageNamed: NSString(format: "DogHud_X_%d.png", idx) as String))
        }
        
        subtractAnimation = SKAction.animate(with: self.xTextures, timePerFrame: 0.15, resize: true, restore: false)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func subtract() {
        for idx in 0 ... 4 {
            if self.indicators[idx].texture == hotDogTexture {
                self.indicators[idx].run(self.subtractAnimation!)
                break
            }
        }
    }
    
    func add() {
        for idx in (0 ... 4).reversed() {
            if self.indicators[idx].texture == xTextures.last {
                self.indicators[idx].texture = hotDogTexture
                self.indicators[idx].size = hotDogTexture.size()
                break
            }
        }
    }
}
