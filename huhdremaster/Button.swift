//
//  Button.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/30/22.
//

import SpriteKit


class TextButton {
    var buttonBackground: BaseSprite = BaseSprite(imageNamed: "MenuItems_BG.png")
    let buttonText: BaseText = BaseText()
    var touchZone: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let touchZoneScaleFactor: CGFloat = 1.5
    var _scene: BaseScene?
    
    init(text: String) {
        buttonText.text = text
    }
    
    convenience init(text: String, image: String) {
        self.init(text: text)
        buttonBackground = BaseSprite(imageNamed: image)
    }
    
    func setScene(scene: BaseScene) {
        buttonBackground.setScene(scene: scene)
        buttonText.setScene(scene: scene)
        _scene = scene
    }
    
    func setZ(zPosition: CGFloat) {
        buttonBackground.zPosition = zPosition
        buttonText.zPosition = zPosition + 1
    }
    
    func setPosition(position: CGPoint) {
        buttonBackground.position = position
        buttonText.position = CGPoint(x:buttonBackground.position.x,
                                      y:buttonBackground.position.y - 8 * _scene!.scaleFactor)
        let touchZoneWidth = buttonBackground.calculateAccumulatedFrame().width * touchZoneScaleFactor
        let touchZoneHeight = buttonBackground.calculateAccumulatedFrame().height * touchZoneScaleFactor
        touchZone = CGRect(x: buttonBackground.position.x - touchZoneWidth / 2,
                           y: buttonBackground.position.y - touchZoneHeight / 2,
                           width: touchZoneWidth,
                           height: touchZoneHeight)
    }
}
