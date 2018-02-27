//
//  ViewController.swift
//  Example
//
//  Created by Robin Malhotra on 26/02/18.
//  Copyright © 2018 Birdsong. All rights reserved.
//

import UIKit
import Birdsong

class ViewController: UIViewController {

	let socket = Socket(url: URL(string: "http://localhost:4000/socket/websocket")!)

	override func viewDidLoad() {
		super.viewDidLoad()
		let room = "rooms:lobby"
		socket.onConnect = {
			let channel = self.socket.channel(room)

			channel.join()?.receive("ok", callback: { (payload) in
				print(payload)
			})

			channel.presence.onStateChange = {
				presence in
				print(presence)
			}


			channel.send("new:msg", payload: ["body": "Hello!"])?
				.receive("ok", callback: { (payload) in
					print("sent message")
				})
				.receive("error", callback: { (reason) in
					print("Message didn't send: \(reason)")
				})
		}
		socket.connect()
		// Do any additional setup after loading the view, typically from a nib.

		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
			print(self.socket.isConnected)
			let channel2 = self.socket.channel(room)
			channel2.join()?.receive("ok", callback: { (payload) in
				print(payload)
			})

			channel2.presence.onStateChange = {
				presence in
				print(presence)
			}

			channel2.send("new:msg", payload: ["body": "Hello2!"])?
				.receive("ok", callback: { (payload) in
					print("sent message2")
				})
				.receive("error", callback: { (reason) in
					print("Message2 didn't send: \(reason)")
				})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}
