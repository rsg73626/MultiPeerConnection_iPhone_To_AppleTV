//
//  ViewController.swift
//  MultiPeerConnection_AppleTV
//
//  Created by Renan Germano on 28/05/2018.
//  Copyright © 2018 Renan Germano. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var player1Label: UILabel?
    @IBOutlet weak var sendMessageToPlayer1Button: UIButton?
    
    @IBOutlet weak var player2Label: UILabel?
    @IBOutlet weak var sendMessageToPlayer2Button: UIButton?
    
    @IBOutlet weak var player3Label: UILabel?
    @IBOutlet weak var sendMessageToPlayer3Button: UIButton?
    
    @IBOutlet weak var messageLabel: UILabel?
    
    // MARK: - Properties
    private var player1: MCPeerID?
    private var player2: MCPeerID?
    private var player3: MCPeerID?
    private var browserManager: MultipeerConnectionBrowserManager = MultipeerConnectionBrowserManager(serviceType: "MultiPeerTest")
    
    // MARK: - Life cicle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.browserManager.delegate = self
        self.browserManager.startBrowsing()
    }
    
    // MARK: - SetUp functions
    private func setUp(player: MCPeerID?, to enabled: Bool) {
        guard let playerLabel = player === self.player1 ? self.player1Label : player === self.player2 ? self.player2Label : self.player3Label else { return }
        guard let playerButton = player === self.player1 ? self.sendMessageToPlayer1Button : player === self.player2 ? self.sendMessageToPlayer2Button : self.sendMessageToPlayer3Button else { return }
        playerLabel.text = !enabled ? "Esperando jogador" : player!.displayName
        playerLabel.isEnabled = enabled
        playerButton.isEnabled = enabled
    }
    
    // MARK: - Browser Delegate functions
    func browserManager(deviceDidConnectedWith peerID: MCPeerID) {
        if self.browserManager.session.connectedPeers.count < 3 {
            if self.player1 == nil {
                player1 = peerID
                self.setUp(player: self.player1, to: true)
                return
            }
            if self.player2 == nil {
                player2 = peerID
                self.setUp(player: self.player2, to: true)
                return
            }
            if self.player3 == nil {
                player3 = peerID
                self.setUp(player: self.player3, to: true)
                return
            }
        } else {
            self.browserManager.stopBrowsing()
        }
    }
    
    func browserManager(deviceDidDisconnectWith peerID: MCPeerID) {
        if self.player1?.displayName == peerID.displayName {
            self.setUp(player: self.player1, to: false)
            self.player1 = nil
            return
        }
        if self.player2?.displayName == peerID.displayName {
            self.setUp(player: self.player2, to: false)
            self.player2 = nil
            return
        }
        if self.player3?.displayName == peerID.displayName {
            self.setUp(player: self.player3, to: false)
            self.player3 = nil
            return
        }
    }
    
    func browserManager(didReceive data: Data, from peerID: MCPeerID) {
        print("did receive data view controller")
        guard let message = String(data: data, encoding: .utf8) else { print(" *** Data error! *** ");return }
        self.messageLabel?.text = "\(peerID.displayName): \(message)"
    }
    
    func browserManager(didReceive error: Error) {
        print(" *** Did receive error: \(error) *** ")
    }
    
    // MARK: - Actions
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        if sender === self.sendMessageToPlayer1Button {
            guard let player = self.player1 else { return }
            self.browserManager.send(data: "Apple TV Message!".data(using: .utf8)!, dataMode: .reliable, to: [player])
            return
        }
        
        if sender === self.sendMessageToPlayer2Button {
            guard let player = self.player2 else { return }
            self.browserManager.send(data: "Apple TV Message!".data(using: .utf8)!, dataMode: .reliable, to: [player])
            return
        }
        
        if sender === self.sendMessageToPlayer3Button {
            guard let player = self.player3 else { return }
            self.browserManager.send(data: "Apple TV Message!".data(using: .utf8)!, dataMode: .reliable, to: [player])
            return
        }
    }
    
}

