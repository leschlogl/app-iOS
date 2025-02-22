//
//  WatchSessionManager.swift
//  MacMagazine
//
//  Created by Cassio Rossi on 08/04/2019.
//  Copyright © 2019 MacMagazine. All rights reserved.
//

import Foundation
import Kingfisher
import WatchConnectivity

class WatchSessionManager: NSObject {

	// MARK: - Properties -

	static let shared = WatchSessionManager()

	// MARK: - Init -

	func startSession() {
		if WCSession.isSupported() {
			WCSession.default.delegate = self
			WCSession.default.activate()
		}
	}

}

extension WatchSessionManager: WCSessionDelegate {

	func sessionDidBecomeInactive(_ session: WCSession) {}

	func sessionDidDeactivate(_ session: WCSession) {
		WCSession.default.activate()
	}

	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		if message["request"] as? String == "posts" {
			retrieve(replyHandler: replyHandler)
		}
	}

}

extension WatchSessionManager {
	func retrieve(replyHandler: @escaping ([String: Any]) -> Void) {
		CoreDataStack.shared.getPostsForWatch { [weak self] watchPosts in
			do {
				let jsonData = try JSONEncoder().encode(watchPosts)
				replyHandler(["posts": jsonData])
			} catch {
				logE(error.localizedDescription)
				self?.load(replyHandler: replyHandler)
			}
		}
	}

	func load(replyHandler: @escaping ([String: Any]) -> Void) {
		var images: [String] = []

		API().getWatchPosts { [weak self] post in
			DispatchQueue.main.async {
				guard let post = post else {
					// Prefetch images to be able to sent to Apple Watch
					let urls = images.compactMap { URL(string: $0) }
					let prefetcher = ImagePrefetcher(urls: urls)
					prefetcher.start()

					self?.retrieve(replyHandler: replyHandler)
					return
				}
				images.append(post.artworkURL)
				CoreDataStack.shared.save(post: post)
			}
		}
	}
}
