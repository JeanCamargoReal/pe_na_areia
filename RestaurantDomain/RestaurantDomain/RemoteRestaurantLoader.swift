//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 02/04/23.
//

import Foundation

struct RestaurantRoot: Decodable {
	let items: [RestaurantItem]
}

struct RestaurantItem: Decodable, Equatable {
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
	private let okResponse: Int = 200

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.networkClient = networkClient
	}

	typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>

	func load(completion: @escaping (RemoteRestaurantLoader.RemoteRestaurantResult) -> Void) {
		let okResponse = okResponse

		networkClient.request(from: url) { [weak self] result in
			guard let _ = self else { return } 

			switch result {
				case let .success((data, response)):

					guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data), response.statusCode == okResponse else {
						return completion(.failure(.invalidData))
					}

					completion(.success(json.items))

				case .failure: completion(.failure(.connectivity))
			}
		}
	}
}
