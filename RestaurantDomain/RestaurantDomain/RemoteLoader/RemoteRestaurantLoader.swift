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

public final class RemoteRestaurantLoader {

	let url: URL
	let networkClient: NetworkClient
	private let okResponse: Int = 200

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.networkClient = networkClient
	}

	private func successfullyValidation(_ data: Data, response: HTTPURLResponse) -> RemoteRestaurantResult {
		guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data), response.statusCode == okResponse else {

			return .failure(.invalidData)
		}

		return .success(json.items)
	}

	public typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>

	public func load(completion: @escaping (RemoteRestaurantLoader.RemoteRestaurantResult) -> Void) {
//		let okResponse = okResponse

		networkClient.request(from: url) { [weak self] result in
			guard let self = self else { return }

			switch result {
				case let .success((data, response)):
					completion(self.successfullyValidation(data, response: response))

				case .failure: completion(.failure(.connectivity))
			}
		}
	}
}
