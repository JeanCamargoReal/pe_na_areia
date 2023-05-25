//
//  RestaurantViewModel.swift
//  Prototipo
//
//  Created by Jean Camargo on 25/05/23.
//

import Foundation


struct FakeRestaurantViewModel {
	let title: String
	let location: String
	let distance: String
	let parasols: String
	let rating: Int
}

extension FakeRestaurantViewModel {

	static var dataModel = [
		FakeRestaurantViewModel(title: "Tenda do quartel", location: "Canto do Forte - Praia Grande", distance: "Distância: 50m", parasols: "Guarda sol (#1)", rating: 4),
		FakeRestaurantViewModel(title: "Barraquinha do seu Zé", location: "Canto do Forte - Praia Grande", distance: "Distância: 100m", parasols: "Guarda sol (#2)", rating: 2),
		FakeRestaurantViewModel(title: "Barraquinha do coronel", location: "Canto do Forte - Praia Grande", distance: "Distância: 150m", parasols: "Guarda sol (#3)", rating: 3),
		FakeRestaurantViewModel(title: "Tenda dos soldados", location: "Canto do Forte - Praia Grande", distance: "Distância: 200m", parasols: "Guarda sol (#4)", rating: 4),
	]

}
