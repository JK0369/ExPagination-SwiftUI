//
//  Photo.swift
//  ExPagination
//
//  Created by 김종권 on 2022/09/17.
//

import Foundation
import SwiftUI

protocol ModelType: Codable, Equatable, Identifiable { }

struct Photo: ModelType {
  struct URLs: ModelType {
    let regular: String
    var id: String { self.regular }
  }
  
  let id: String
  let urls: URLs
  let width: CGFloat
  let height: CGFloat
}
