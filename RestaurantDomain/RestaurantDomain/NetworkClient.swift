//
//  NetworkClient.swift
//  RestaurantDomain
//
//  Created by Jean Camargo on 19/04/23.
//

import Foundation

public protocol NetworkClient {
	typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}
