//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 02/04/23.
//

import Foundation

enum NetworkState {
	case success
	case error(Error)
}

protocol NetworkClient {
	func request(from url: URL, completion: @escaping (NetworkState) -> Void)
}

final class RemoteRestaurantLoader {

	let url: URL
	let networkClient: NetworkClient

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.networkClient = networkClient
	}

	func load(completion: @escaping (RemoteRestaurantLoader.Error) -> Void) {
		networkClient.request(from: url) { state in
			switch state {
				case .success: completion(.invalidData)
				case .error: completion(.connectivity)
			}
		}
	}
}
