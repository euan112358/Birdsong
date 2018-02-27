//
//  ChannelListener.swift
//  Birdsong
//
//  Created by Robin Malhotra on 27/02/18.
//  Copyright © 2018 Birdsong. All rights reserved.
//

import Foundation

protocol ChannelListener: class {
	var callbacks: [String: (Response) -> Void] { get set }
}

protocol PresenceListener: class {
	var presenceCallbacks: [(Presence) -> Void] {get set}
}
