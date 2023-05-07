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

public final class LocalRestaurantLoader {
	private let cache: CacheClient
	private let currentDate: () -> Date

	public init(cache: CacheClient, currentDate: @escaping () -> Date) {
		self.cache = cache
		self.currentDate = currentDate
	}

	public func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
		cache.delete { [weak self] error in
			guard let self else { return }
			guard let error else {
				return saveOnCache(items, completion: completion)
			}
			completion(error)
		}
	}

	private func saveOnCache(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
		cache.save(items, timestamp: currentDate()) { [weak self] error in
			guard self != nil else { return }

			completion(error)
		}
	}
}

extension LocalRestaurantLoader: RestaurantLoader {

	public func load(completion: @escaping (Result<[RestaurantItem], RestaurantResultError>) -> Void) {

		cache.load { state in
			switch state {
				case .empty: completion(.success([]))
				case let .success(items, _): completion(.success(items))
				case .failure: completion(.failure(.invalidData))
			}
		}
	}
}
