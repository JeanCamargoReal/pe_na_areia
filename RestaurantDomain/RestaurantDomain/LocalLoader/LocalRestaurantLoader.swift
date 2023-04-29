//
//  LocalRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 22/04/23.
//

/*
	#### Curso primário (caminho feliz):
	1. Execute o comando "Salvar listagem de restaurantes" com os dados acima.
	2. O sistema deleta o cache antigo.
	3. O sistema codifica a lista de restaurantes.
	4. O sistema marca a hora do novo cache.
	5. O sistema salva o cache com novos dados.
	6. O sistema envia uma mensagem de sucesso.

	#### Caso de erro (caminho triste):
	1. O sistema envia uma mensagem de erro.

	#### Caso de erro ao salvar (caminho triste):
	1. O sistema envia uma mensagem de erro.
*/

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
