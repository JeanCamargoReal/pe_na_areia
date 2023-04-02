//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 02/04/23.
//

import Foundation

// Singleton
protocol NetworkClient {
	func request(from url: URL)
}


final class RemoteRestaurantLoader {

	let url: URL
	let networkClient: NetworkClient

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.networkClient = networkClient
	}

	func load() {
		networkClient.request(from: url)
	}
}
