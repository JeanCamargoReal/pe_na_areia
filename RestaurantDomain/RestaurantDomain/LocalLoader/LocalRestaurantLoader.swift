//
//  LocalRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 22/04/23.
//

import Foundation

protocol CacheClient {
	func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void)
	func delete(completion: @escaping (Error?) -> Void)
}

final class LocalRestaurantLoader {
	let cache: CacheClient
	let currentDate: () -> Date

	init(cache: CacheClient, currentDate: @escaping () -> Date) {
		self.cache = cache
		self.currentDate = currentDate
	}

	func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
		cache.delete { [unowned self] error in
			if error == nil {
				self.cache.save(items, timestamp: self.currentDate(), completion: completion)
			} else {
				completion(error)
			}
		}
	}
}
