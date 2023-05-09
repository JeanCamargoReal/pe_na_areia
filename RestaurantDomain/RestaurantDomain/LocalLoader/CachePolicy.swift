//
//  CachePolicy.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 09/05/23.
//

import Foundation

public protocol CachePolicy {
	func validate(_ timestamp: Date, with currentData: Date) -> Bool
}

public final class RestaurantLoaderCachePolicy: CachePolicy {

	public init() {}

	private let maxAge: Int = 1

	public func validate(_ timestamp: Date, with currentData: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)
		guard let maxAge = calendar.date(byAdding: .day, value: maxAge, to: timestamp) else {
			return false
		}

		return currentData < maxAge
	}
}
