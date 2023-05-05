//
//  RestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 05/05/23.
//

import Foundation

public enum RestaurantResultError: Error {
	case connectivity
	case invalidData
}

public protocol RestaurantLoader {
	typealias RestaurantResult = Result<[RestaurantItem], RestaurantResultError>

	func load(completion: @escaping (RestaurantLoader.RestaurantResult) -> Void)
}
