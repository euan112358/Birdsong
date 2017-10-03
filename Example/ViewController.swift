//
//  ViewController.swift
//  Example
//
//  Created by Robin Malhotra on 29/08/17.
//  Copyright © 2017 Birdsong. All rights reserved.
//

import Birdsong
import UIKit

class ViewController: UIViewController {

	
	var socket: Socket?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let instance = URLQueryItem(name: "instance", value: "kayako-mobile-testing.kayako.com")
		let session = URLQueryItem(name: "session_id", value: "2iKf8v8iZWC9i4Ql0deb0c3f299dbea29ef018a5163429969803538ajNJOUIpiwr")
		let userAgent = URLQueryItem(name: "user_agent", value: "Marathon")
		let vsn = URLQueryItem(name: "vsn", value: "1.0.0")
		
		var components = URLComponents(string: "wss://kre.kayako.net/socket/websocket")
		components?.queryItems = {
			return [session, userAgent, vsn, instance]
		}()
		guard let url = components?.url else {
			return
		}
		
		socket = Socket(url: url)
		
		socket?.onConnect = {
			let channel = self.socket?.channel("user_presence-61485139915436ab6fc57ca6b1e0bc87f58649bc427077133b6e71a278c3e8a2@fd8ccb1f90684010b781754e1def7d144e5f1b5c", payload: [:])
			channel?.on("new:msg", callback: { message in
				print("new message")
			})
			
			channel?.join()?.receive("ok", callback: { payload in
				print("Successfully joined: \(channel?.topic)")
			})
			
			channel?.send("new:msg", payload: ["body": "Hello!"])?
				.receive("ok", callback: { response in
					print("Sent a message!")
				})
				.receive("error", callback: { reason in
					print("Message didn't send: \(reason)")
				})
			
			// Presence support.
			channel?.presence.onStateChange = { newState in
				// newState = dict where key = unique ID, value = array of metas.
				print("New presence state: \(newState)")
			}
			
			channel?.presence.onJoin = { id, meta in
				print("Join: user with id \(id) with meta entry: \(meta)")
			}
			
			channel?.presence.onLeave = { id, meta in
				print("Leave: user with id \(id) with meta entry: \(meta)")
			}
		}
		
		socket?.onDisconnect = {
			error in
			print(error)
		}
		
		socket?.connect()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

