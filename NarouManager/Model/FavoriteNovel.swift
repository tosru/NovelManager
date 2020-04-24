//
//  FavoriteNovel.swift
//  NarouManager
//
//  Created by tosru on 2020/04/11
//  ©︎ 2020 tosru
//

import RealmSwift

class FavoriteNovel: Object {
  @objc dynamic var ncode: String?
  @objc dynamic var readStoryNumber: Int = 0
  @objc dynamic var isReverseOrder: Bool = false
  
  override static func primaryKey() -> String? {
    return "ncode"
  }
  
}
