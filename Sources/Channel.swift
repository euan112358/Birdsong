//
//  Channel.swift
//  Pods
//
//  Created by Simon Manning on 24/06/2016.
//
//

import Foundation

class PresenceEventsListener: ChannelListener {
	let events = ["presence_state", "presence_diff"]
	var callbacks: [String : (Response) -> Void] = [:]
}

open class Channel {
	// MARK: - Properties

	open let topic: String
	open let params: Socket.Payload
	fileprivate weak var socket: Socket?
	fileprivate(set) open var state: State

	fileprivate(set) open var presence: Presence

//	fileprivate var callbacks: [String: (Response) -> ()] = [:]
//	fileprivate var presenceStateCallback: ((Presence) -> ())?

	let presenceEventsListener = PresenceEventsListener()
	var channelListeners: [ChannelListener] = []
	var presenceListeners: [PresenceListener] = []

	init(socket: Socket, topic: String, params: Socket.Payload = [:]) {
		self.socket = socket
		self.topic = topic
		self.params = params
		self.state = .Closed
		self.presence = Presence()


		self.presenceEventsListener.callbacks["presence_state"] = {
			[weak self] response in
			self?.presence.sync(response)
			guard let presence = self?.presence else {
				return
			}
			self?.presenceListeners.forEach{ $0.presenceCallbacks.forEach{ $0(presence) } }
		}

		self.presenceEventsListener.callbacks["presence_diff"] = {
			[weak self] response in
			self?.presence.sync(response)
		}

//		// Register presence handling.
//		on("presence_state") { [weak self] (response) in
//			self?.presence.sync(response)
//			guard let presence = self?.presence else {return}
//			self?.channelListeners.forEach { $0.presenceStateCallback?(presence) }
//			self?.presenceStateCallback?(presence)
//		}
//		on("presence_diff") { [weak self] (response) in
//			self?.presence.sync(response)
//		}
	}

	// MARK: - Control

	@discardableResult
	open func join() -> Push? {
		state = .Joining

		return send(Socket.Event.Join, payload: params)?.receive("ok", callback: { response in
			self.state = .Joined
		})
	}

	@discardableResult
	open func leave() -> Push? {
		state = .Leaving

		return send(Socket.Event.Leave, payload: [:])?.receive("ok", callback: { response in
//			self.callbacks.removeAll()
			self.presence.onJoin = nil
			self.presence.onLeave = nil
			self.presence.onStateChange = nil
			self.state = .Closed
		})
	}

	@discardableResult
	open func send(_ event: String,
				   payload: Socket.Payload) -> Push? {
		let message = Push(event, topic: topic, payload: payload)
		return socket?.send(message)
	}

	// MARK: - Raw events

	func received(_ response: Response) {
		if self.presenceEventsListener.events.contains(response.event) {

		}

		channelListeners.forEach { (listener) in
			if let callback = listener.callbacks[response.event] {
				callback(response)
			}
		}
	}

	// MARK: - States

	public enum State: String {
		case Closed = "closed"
		case Errored = "errored"
		case Joined = "joined"
		case Joining = "joining"
		case Leaving = "leaving"
	}
}

