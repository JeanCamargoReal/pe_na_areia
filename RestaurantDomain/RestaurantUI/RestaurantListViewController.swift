//
//  RestaurantListViewController.swift
//  RestaurantUI
//
//  Created by Jean Camargo on 04/06/23.
//

/*

 Lista de restaurantes UI

- [ ] Carregamento automático da lista de restaurantes, quando a tela for exibida
- [ ] Habilitar recurso para atualização manual (pull to refresh)
- [ ] Exibir um loading indicativo, durante processo de carregamento
- [ ] Renderizar todas as informações disponíveis de restaurantes

 */

import UIKit
import RestaurantDomain

final class RestaurantListViewController: UIViewController {
	private(set) var restaurantCollection: [RestaurantItem] = []
	private var service: RestaurantLoader? = nil

	convenience init(service: RestaurantLoader) {
		self.init()
		self.service = service
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		service?.load { result in
			switch result {
				case let .success(items):
					self.restaurantCollection = items
				default: break
			}
		}
	}
}
