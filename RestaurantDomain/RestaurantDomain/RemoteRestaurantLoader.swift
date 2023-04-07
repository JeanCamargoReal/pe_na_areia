//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 02/04/23.
//

import Foundation

struct RestaurantItem {
	let id: UUID
	let name: String
	let location: String
	let distance: Float
	let ratings: Int
	let parasols: Int
}

protocol NetworkClient {
	typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
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
		networkClient.request(from: url) { result in
			switch result {
				case .success: completion(.invalidData)
				case .failure: completion(.connectivity)
			}
		}
	}
}
