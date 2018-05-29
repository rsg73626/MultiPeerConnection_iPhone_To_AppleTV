//
//  MultipeerConnectionManager.swift
//  MultiPeerConnection_AppleTV
//
//  Created by Renan Germano on 29/05/2018.
//  Copyright © 2018 Renan Germano. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// MARK: - Advertiser Delegate
protocol MCAdvertiserManagerDelegate {
    func advertiserManager(didConnectWith peerID: MCPeerID)
    func advertiserManager(didDisconnectWith peerID: MCPeerID)
    func advertiserManager(didReceive data: Data, from peerID: MCPeerID)
    func advertiserManager(didReceive error: Error)
}

class MultipeerConnectionAdvertiserManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    // MARK: - Properties
    var serviceType: String!
    var peerId: MCPeerID!
    var session: MCSession!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var delegate: MCAdvertiserManagerDelegate?
    
    // MARK: - Initializers
    init(serviceType: String) {
        super.init()
        self.serviceType = serviceType
        self.peerId = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .none)
        self.session?.delegate = self
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceAdvertiser.delegate = self
    }
    
    // MARK: - Util functions
    func startAdvertesing() {
        print(" *** startAdvertising *** ")
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        print(" *** stopAdvertising *** ")
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func send(data: Data, dataMode: MCSessionSendDataMode) {
        print(" *** sendData *** ")
        guard let session = self.session else { return }
        do {
            try self.session.send(data, toPeers: self.session.connectedPeers, with: dataMode)
        } catch let error {
            DispatchQueue.main.async {
                self.delegate?.advertiserManager(didReceive: error)
            }
        }
    }
    
    // MARK: - Advertiser delegate functions
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            self.delegate?.advertiserManager(didReceive: error)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(" *** didReceiveInviteFrom: \(peerID.displayName) *** ")
        invitationHandler(true, session)
        self.stopAdvertising()
    }
    
    // MARK: - Session delegate functions
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print(" *** peerConnected: \(peerID.displayName) *** ")
            DispatchQueue.main.async {
                self.delegate?.advertiserManager(didConnectWith: peerID)
            }
            
        } else if state == .notConnected {
            print(" *** peerDisconnected: \(peerID.displayName) *** ")
            DispatchQueue.main.async {
                self.delegate?.advertiserManager(didDisconnectWith: peerID)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(" *** didReceiveData: \(peerID.displayName) *** ")
        DispatchQueue.main.async {
            self.delegate?.advertiserManager(didReceive: data, from: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
}
