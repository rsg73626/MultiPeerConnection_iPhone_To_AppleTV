//
//  MultipeerConnectionBrowserManager.swift
//  MultiPeerConnection_AppleTV
//
//  Created by Renan Germano on 29/05/2018.
//  Copyright © 2018 Renan Germano. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// MARK: - Browser Delegate
protocol MCBrowserManagerDelegate {
    func browserManager(deviceDidConnectedWith peerID: MCPeerID)
    func browserManager(deviceDidDisconnectWith peerID: MCPeerID)
    func browserManager(didReceive data: Data, from peerID: MCPeerID)
    func browserManager(didReceive error: Error)
}

class MultipeerConnectionBrowserManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    // MARK: - Properties
    var serviceType: String!
    var peerId: MCPeerID!
    var session: MCSession!
    var serviceBrowser: MCNearbyServiceBrowser!
    var delegate: MCBrowserManagerDelegate?
    
    // MARK: - Initializers
    init(serviceType: String) {
        super.init()
        self.serviceType = serviceType
        self.peerId = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .none)
        self.session?.delegate = self
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        self.serviceBrowser.delegate = self
    }
    
    // MARK: - Util functions
    func startBrowsing(){
        print(" *** startBrowsing *** ")
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing(){
        print(" *** stopBrowsing *** ")
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(data: Data, dataMode: MCSessionSendDataMode, to peers: [MCPeerID]? ) {
        print(" *** sendData *** ")
        let destinationPeers = peers != nil ? peers! : self.session.connectedPeers
        guard let session = self.session else{return}
        do {
            try session.send(data, toPeers: destinationPeers, with: dataMode)
        } catch let error {
            DispatchQueue.main.async {
                self.delegate?.browserManager(didReceive: error)
            }
        }
    }
    
    // MARK: - Browser delegate functions
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            self.delegate?.browserManager(didReceive: error)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(" *** foundPeer: \(peerID.displayName) *** ")
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 180)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print(" *** lostPeer: \(peerID.displayName) *** ")
    }
    
    // MARK: - Session delegate functions
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print(" *** peerConnected: \(peerID.displayName) *** ")
            DispatchQueue.main.async {
                self.delegate?.browserManager(deviceDidConnectedWith: peerID)
            }
        } else if state == .notConnected {
            print(" *** peerDisconnected: \(peerID.displayName) *** ")
            DispatchQueue.main.async {
                self.delegate?.browserManager(deviceDidDisconnectWith: peerID)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(" *** didReceiveDataFrom: \(peerID.displayName) *** ")
        DispatchQueue.main.async {
            self.delegate?.browserManager(didReceive: data, from: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
}
