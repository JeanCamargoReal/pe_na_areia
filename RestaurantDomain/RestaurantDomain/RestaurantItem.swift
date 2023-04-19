//
//  RestaurantItem.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 19/04/23.
//

import Foundation

public struct RestaurantItem: Decodable, Equatable {
	public let id: UUID
	public let name: String
	public let location: String
	public let distance: Float
	public let ratings: Int
	public let parasols: Int

	public init(id: UUID, name: String, location: String, distance: Float, ratings: Int, parasols: Int) {
		self.id = id
		self.name = name
		self.location = location
		self.distance = distance
		self.ratings = ratings
		self.parasols = parasols
	}
}
