//
//  NovelInfo.swift
//  NarouManager
//
//  Created by tosru on 2020/04/11
//  ©︎ 2020 tosru
//

class NovelInfo: Decodable {
  // swiftlint:disable type_contents_order
  // documentに載っていたスタイルだったのでlinterを無視する
  // 小説の情報
  var title: String?
  var ncode: String?
  var genre: Int?
  var end: Int?
  var allStoryNumber: Int?
  
  // Decodableとは関係がない 自分が読んでいる状態の情報
  var isExistUnreadStory = true
  var readStoryNumber = -1
  var isFavorite = false
  var isReverseOrder = false
  
  // このenumに含まないことでプロパティをDecodableの対象外にする
  enum CodingKeys: String, CodingKey {
    case title
    case ncode
    case genre
    case end
    case allStoryNumber = "general_all_no"
  }
  // swiftlint:enable type_contents_order
}
