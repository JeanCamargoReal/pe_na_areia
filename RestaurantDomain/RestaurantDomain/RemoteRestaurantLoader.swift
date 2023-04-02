//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 02/04/23.
//

import Foundation

// Singleton
final class NetworkClient {
	static let shared: NetworkClient = NetworkClient()

	private(set) var urlRequest: URL?

	private init() {}

	func request(from url: URL) {
		urlRequest = url
	}
}


final class RemoteRestaurantLoader {

	let url: URL

	init(url: URL) {
		self.url = url
	}

	func load() {
		NetworkClient.shared.request(from: url)
	}
}
