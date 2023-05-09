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

public final class LocalRestaurantLoader {

	private let cache: CacheClient
	private let cachePolicy: CachePolicy
	private let currentDate: () -> Date

		public init(
			cache: CacheClient,
			cachePolicy: CachePolicy = RestaurantLoaderCachePolicy(),
			currentDate: @escaping () -> Date) {
				self.cache = cache
				self.cachePolicy = cachePolicy
				self.currentDate = currentDate
			}

		public func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
			cache.delete { [weak self] error in
				guard let self else { return }
				guard let error else {
					return self.saveOnCache(items, completion: completion)
				}
				completion(error)
			}
		}

		public func validateCache() {
			cache.load { [weak self] state in
				guard let self else { return }
				switch state {
					case let .success(_, timestamp) where !self.cachePolicy.validate(timestamp, with: self.currentDate()):
						self.cache.delete { _ in }
					case .failure:
						self.cache.delete { _ in }
					default: break
				}
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
			cache.load { [weak self] state in
				guard let self else { return }
				switch state {
					case let .success(items, timestamp) where self.cachePolicy.validate(timestamp, with: self.currentDate()):
						completion(.success(items))
					case .success, .empty:
						completion(.success([]))
					case .failure:
						completion(.failure(.invalidData))
				}
			}
		}
	}
