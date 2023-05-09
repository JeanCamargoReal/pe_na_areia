//
//  CacheClient.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 09/05/23.
//

import Foundation

public enum LoadResultState {
	case empty
	case success(items: [RestaurantItem], timestamp: Date)
	case failure(Error)
}
public protocol CacheClient {
	typealias SaveResult = (Error?) -> Void
	typealias DeleteResult = (Error?) -> Void
	typealias LoadResult = (LoadResultState) -> Void

	func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
	func delete(completion: @escaping DeleteResult)
	func load(completion: @escaping LoadResult)
}
