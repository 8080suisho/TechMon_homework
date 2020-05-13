//
//  BattleViewController.swift
//  TechMon
//
//  Created by 諸星水晶 on 2020/05/12.
//  Copyright © 2020 諸星水晶. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView:UIImageView!
    @IBOutlet var enemyHPLabel:UILabel!
    @IBOutlet var enemyMPLabel:UILabel!
    
    let techMonManeger = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManeger.player
        enemy = techMonManeger.enemy
        
        player.resetStatus()
        enemy.resetStatus()
        
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManeger.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManeger.stopBGM()
    }
    
    @objc func updateGame(){
        player.currentMP += 1
        if player.currentMP >= 20 {
            isPlayerAttackAvailable = true
            player.currentMP = 20
        }else{
            isPlayerAttackAvailable = false
        }
        
        enemy.currentMP += 1
        if enemy.currentMP >= 35{
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
        
    }
    
    
    func enemyAttack(){
        techMonManeger.damageAnimation(imageView: playerImageView)
        techMonManeger.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        judgeBattle()
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        techMonManeger.vanishAnimation(imageView: vanishImageView)
        techMonManeger.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManeger.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        }else{
            techMonManeger.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func attackAction(){
        if isPlayerAttackAvailable {
            
            techMonManeger.damageAnimation(imageView: enemyImageView)
            techMonManeger.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            
            if player.currentTP >= player.maxTP{
                player.currentTP = player.maxTP
            }
            updateUI()
            player.currentMP = 0
            judgeBattle()
        }
    }
    
    @IBAction func tameruAction(){
        
        if isPlayerAttackAvailable{
            
            techMonManeger.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP{
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
        
    }
    
    @IBAction func fireAction(){
        if isPlayerAttackAvailable && player.currentTP >= 40{
            techMonManeger.damageAnimation(imageView: enemyImageView)
            techMonManeger.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            
            if player.currentTP <= 0{
                player.currentTP = 0
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
    
    
    func updateUI(){
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"

        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"

    }
    
    func judgeBattle(){
        if player.currentHP <= 0 {
            
            player.currentHP = 0
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
            
            
        }else if enemy.currentHP <= 0 {
            
            enemy.currentHP = 0
            
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
            
            
        }
    }
    
    

    

}

