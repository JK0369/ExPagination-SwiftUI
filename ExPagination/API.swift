//
//  API.swift
//  ExPagination
//
//  Created by 김종권 on 2022/09/17.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
  case unknown
  case some(reason: String)
  
  var errorDescription: String? {
    switch self {
    case .unknown:
      return "Unknown"
    case let .some(reason):
      return reason
    }
  }
}

enum API {
  private static let token = "your_client_key"
  private static let photoURL = "https://api.unsplash.com/photos"
  
  static func fetchPhotos(page: Int) -> AnyPublisher<Data, Error> {
    var urlComponents = URLComponents(string: photoURL)!
    urlComponents.queryItems = [
      .init(name: "page", value: "\(page)"),
      .init(name: "per_page", value: "\(10)"),
      .init(name: "order_by", value: "latest")
    ]
    var request = URLRequest(url: urlComponents.url!)
    
    request.allHTTPHeaderFields = ["Authorization": "Client-ID \(token)"]
    
    return URLSession.DataTaskPublisher(request: request, session: .shared)
      .tryMap { data, response in
        guard
          let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else { throw APIError.some(reason: "Invalid httpResponse") }
        return data
      }
      .mapError { error in
        if let error = error as? APIError {
          return error
        } else {
          return APIError.some(reason: error.localizedDescription)
        }
      }
      .eraseToAnyPublisher()
  }
}
