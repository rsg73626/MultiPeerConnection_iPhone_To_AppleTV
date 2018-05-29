//
//  ViewController.swift
//  MultiPeerConnection_iPhone
//
//  Created by Renan Germano on 28/05/2018.
//  Copyright © 2018 Renan Germano. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCAdvertiserManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var sendMessage: UIButton!
    
    // MARK: - Properties
    private var advertiserManager: MultipeerConnectionAdvertiserManager = MultipeerConnectionAdvertiserManager(serviceType: "MultiPeerTest")
    
    // MARK: - Life cicle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.advertiserManager.delegate = self
        self.advertiserManager.startAdvertesing()
    }
    
    // MARK: - Actions
    @IBAction func sendHelloButtonTapped(_ sender: Any) {
        self.advertiserManager.send(data: "iPhone message!".data(using: .utf8)!, dataMode: .reliable)
    }
    
    // MARK: - Advertiser Manager Delegate
    func advertiserManager(didConnectWith peerID: MCPeerID) {
        print(" *** Apple TV connected! *** ")
        self.status.text = "Connected to: \(peerID.displayName)"
        self.message.isEnabled = true
        self.sendMessage.isEnabled = true
    }
    
    func advertiserManager(didDisconnectWith peerID: MCPeerID) {
        print(" *** Apple TV disconnected! *** ")
        self.status.text = "Waiting connection..."
        self.message.isEnabled = false
        self.sendMessage.isEnabled = false
    }
    
    func advertiserManager(didReceive data: Data, from peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            self.message.text = message
        }
    }
    
    func advertiserManager(didReceive error: Error) {
        print(" *** Did receive error: \(error) *** ")
    }
    

}

