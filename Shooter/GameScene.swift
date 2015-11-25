//
//  GameScene.swift
//  Shooter
//
//  Created by Erv Noel on 11/17/15.
//  Copyright (c) 2015 ErvNoel. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    
    static let Enemy :UInt32 = 0x1 << 0
    static let Bullet :UInt32 = 0x1 << 1
    static let Player :UInt32 = 0x1 << 2
    static let PowerUp :UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //var player = SKSpriteNode(imageNamed: "Shooter")
    var player = SKSpriteNode(imageNamed: "DataBall")
    var enemyTimer = NSTimer()
    
    var powerUpTimer = NSTimer()
    
    var hits = 0
    var gameStarted = false
    var fadingAnim = SKAction()
    
    var score = 0
    var highScore = 0

    //var backgroundMusic: SKAudioNode!
    
    
    
    var tapToBeginLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var scoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var highScoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    
    var powerUpLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        
        let highScoreDefault = NSUserDefaults.standardUserDefaults()
        if highScoreDefault.valueForKey("Highscore") != nil {
            
            
            highScore = highScoreDefault.valueForKey("Highscore") as! Int
            highScoreLabel.text = "Highscore : \(highScore)"
        }
        
        
        tapToBeginLabel.text = "Tap To Begin"
        tapToBeginLabel.fontSize = 34
        tapToBeginLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2) // positions label in center
        tapToBeginLabel.fontColor = UIColor.whiteColor()
        tapToBeginLabel.zPosition = 2.0
        self.addChild(tapToBeginLabel)
        
        fadingAnim = SKAction.sequence([SKAction.fadeInWithDuration(1.0), SKAction.fadeOutWithDuration(1.0)])
        tapToBeginLabel.runAction(SKAction.repeatActionForever(fadingAnim))
        
        
        highScoreLabel.text = "Highscore : \(highScore)"
        highScoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        highScoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        self.addChild(highScoreLabel)
        
        scoreLabel.alpha = 0
        scoreLabel.fontSize = 35
        scoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        scoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)

        
        
        backgroundColor = UIColor.blackColor()
        //backgroundColor = UIColor(patternImage: (UIImage(named: "Image"))
        
        
        
        //let backgroundImg = SKSpriteNode(imageNamed: "Grid")
        //backgroundImg.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        //self.addChild(backgroundImg)
        
        player.size = CGSize(width: 225, height: 225)
        player.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2)
        //player.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        player.color = UIColor.whiteColor()
        player.colorBlendFactor = 0.5
        //player.colorBlendFactor = 1.0
        player.zPosition = 1.0;

        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.dynamic = false
        player.name = "Player"
        
        self.addChild(player)
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if ((firstBody.name == "Enemy") && (secondBody.name == "Bullet")) {
                
                collisionBullet(firstBody, Bullet: secondBody)
                
            }
            
            else if ((firstBody.name == "Bullet") && (secondBody.name == "Enemy")) {
                
                collisionBullet(secondBody, Bullet: firstBody)
                
            }
            
            else if ((firstBody.name == "Player") && (secondBody.name == "Enemy")) {
                
                collisionPlayer(secondBody)
                
                
            } else if ((firstBody.name == "Enemy") && (secondBody.name == "Player")) {
                
                collisionPlayer(firstBody)
                
            }
        
        }
        

        // makes the powerups be able to be hit
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            
            
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if ((firstBody.name == "Powerup") && (secondBody.name == "Bullet")) {
                
                
                
                (collisionBullet(firstBody, Bullet: secondBody))
                
                // Controls the downsize power up
                powerUpLabel.text = "Bytesize"
                powerUpLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
                powerUpLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
                powerUpLabel.runAction(SKAction.fadeInWithDuration(0.25))
                powerUpLabel.runAction(SKAction.fadeOutWithDuration(0.25))
                
                player.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.1), SKAction.colorizeWithColor(SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1)]))
                
                player.runAction(SKAction.scaleBy(0.5, duration: 0.4))
                
                
                powerUpLabel.removeFromParent()
                hits--
                self.addChild(powerUpLabel)
                //powerUpLabel.removeFromParent()
            }
                
            else if ((firstBody.name == "Bullet") && (secondBody.name == "Powerup")) {
                
                collisionBullet(secondBody, Bullet: firstBody)
                
                
                //powerUpLabel.text = "You Powered Up"
                //powerUpLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
                //powerUpLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
                //self.addChild(powerUpLabel)
                // powerUpLabel.runAction(SKAction.fadeInWithDuration(0.2))
                // powerUpLabel.runAction(SKAction.fadeOutWithDuration(0.2))
                
            }
            
            /*
            else if ((firstBody.name == "Player") && (secondBody.name == "Powerup")) {
                
                collisionPlayer(secondBody)
                
                
            } else if ((firstBody.name == "Powerup") && (secondBody.name == "Player")) {
                
                collisionPlayer(firstBody)
                
            }

            */
            
        }
        
    }
    
    
    // handles when things collide with the Player
    func collisionPlayer(Enemy : SKSpriteNode) {
        
        if hits < 2 {
            player.runAction(SKAction.scaleBy(1.5, duration: 0.4))
            Enemy.physicsBody?.affectedByGravity = true
            Enemy.removeAllActions()
            
            player.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.1), SKAction.colorizeWithColor(SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1)]))
            
            hits++
            Enemy.removeFromParent()
        }
        
        else { // initiates this code as soon as the game ends
            
            Enemy.removeFromParent()
            
            
            
            enemyTimer.invalidate()
            
            powerUpTimer.invalidate()
            
            gameStarted = false
            scoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            tapToBeginLabel.runAction(SKAction.fadeInWithDuration(1.0))
            tapToBeginLabel.runAction(SKAction.repeatActionForever(fadingAnim))
            highScoreLabel.runAction(SKAction.fadeInWithDuration(0.2))
            
            
            if score > highScore {
                let highScoreDefault = NSUserDefaults.standardUserDefaults()
                highScore = score
                highScoreDefault.setInteger(highScore, forKey: "Highscore")
                highScoreLabel.text = "Highscore : \(highScore)"
            }
            
        }
    }
    
    
    // handles when things collide with Bullet
    func collisionBullet(Enemy : SKSpriteNode, Bullet : SKSpriteNode) {
        
        Enemy.physicsBody?.dynamic = true
        
        Enemy.physicsBody?.affectedByGravity = true
        
        Enemy.physicsBody?.mass = 5.0
        Bullet.physicsBody?.mass = 5.0
        
        Enemy.removeAllActions()
        Bullet.removeAllActions()
        Enemy.physicsBody?.contactTestBitMask = 0
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.name = nil
        
        score++
        scoreLabel.text = "\(score)"
        //self.addChild(scoreLabel)
        
        
        
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted == false {
            enemyTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("Enemies"), userInfo: nil, repeats: true)
        
            powerUpTimer = NSTimer.scheduledTimerWithTimeInterval(7.5, target: self, selector: Selector("PowerUps"), userInfo: nil, repeats: true)
            
            gameStarted = true
            player.runAction(SKAction.scaleTo(0.44, duration: 0.2))
            hits = 0
            
            
            tapToBeginLabel.removeAllActions()
            tapToBeginLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            
            highScoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            
            scoreLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.fadeInWithDuration(1.0)]))
            
            score = 0
            scoreLabel.text = "\(score)"
            
        }
        else {
            
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let playerBullets = SKSpriteNode(imageNamed: "Shooter")
            playerBullets.zPosition = -1.0
            playerBullets.size = CGSizeMake(20, 20)
            playerBullets.position = player.position
            playerBullets.physicsBody = SKPhysicsBody(circleOfRadius: playerBullets.size.width / 2)
            playerBullets.physicsBody?.affectedByGravity = true
            
            playerBullets.color = UIColor(red: 0.1 , green: 0.65, blue: 0.95, alpha: 1.0)
            playerBullets.colorBlendFactor = 1.0
            
            playerBullets.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
            playerBullets.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            playerBullets.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            
            //playerBullets.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
            //playerBullets.physicsBody?.contactTestBitMask = PhysicsCategory.PowerUp
            
            playerBullets.name = "Bullet"
            playerBullets.physicsBody?.dynamic = true
            playerBullets.physicsBody?.affectedByGravity = true
            
            
            var dx = CGFloat(location.x - player.position.x)
            var dy = CGFloat(location.y - player.position.y)
            
            let magnitude = sqrt(dx * dx + dy * dy)
            
            dx /= magnitude
            dy /= magnitude
            
            self.addChild(playerBullets)
            
            let vector = CGVector(dx: 16.0 * dx, dy: 16.0 * dy)
            
            playerBullets.physicsBody?.applyImpulse(vector)
            
            
            }
        }
    }

    
    
    // creates the enemies and handles enemy physics
    func Enemies() {
        
        let enemy = SKSpriteNode(imageNamed: "Shooter")
        enemy.size = CGSize(width: 20, height: 20)
        enemy.color = UIColor.redColor()
        enemy.colorBlendFactor = 1.0
        
        
        // physics for the enemy
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.dynamic = true
        enemy.name = "Enemy"
        
        
        // gets random position for the enemies to pop out
        let randomPositionNum = arc4random() % 4
        
        switch randomPositionNum {
            
        case 0:
            
            enemy.position.x = 0
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            self.addChild(enemy)
            
            
            break
        case 1:
            
            enemy.position.y = 0
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            self.addChild(enemy)

            
            break
        case 2:
            
            enemy.position.y = frame.size.height
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            self.addChild(enemy)
            
            
            break
        case 3:
            
            enemy.position.x = frame.size.width
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            self.addChild(enemy)
            
            break
        default:
            
            break
            
        }
        
        enemy.runAction(SKAction.moveTo(player.position, duration: 3))
    }
    
    
    
    func PowerUps() {
        
        let powerUp = SKSpriteNode(imageNamed: "Powerups")
        powerUp.size = CGSize(width: 27, height: 27)
        //powerUp.color = UIColor.greenColor()
        //powerUp.colorBlendFactor = 0.5
        
        
        
        // physics for the powerups
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // | PhysicsCategory.Player
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.Bullet // | PhysicsCategory.Player
        powerUp.physicsBody?.affectedByGravity = false
        powerUp.physicsBody?.dynamic = true
        powerUp.name = "Powerup"
        
        
        // gets random position for the powerups to pop out
        let randomPositionNum = arc4random() % 4
        
        switch randomPositionNum {
        
    /*
        case 0:
            
            powerUp.position.x = 0
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            powerUp.position.y = CGFloat(positionY)
            self.addChild(powerUp)

            
            
            break


        case 0:
            
            powerUp.position.y = 0
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            powerUp.position.x = CGFloat(positionX)
            self.addChild(powerUp)
            

            break

        */


        
        case 0:
            
            powerUp.position.y = frame.size.height
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            powerUp.position.x = CGFloat(positionX)
            self.addChild(powerUp)
            

            break

        /*
        case 0:
            
            powerUp.position.x = frame.size.width
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            powerUp.position.y = CGFloat(positionY)
            self.addChild(powerUp)

            
            break

        */
        default:
            
            break
            
        }
        
        powerUp.runAction(SKAction.moveTo(player.position, duration: 3))
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
