//
//  DataManager.swift
//  NarouManager
//
//  Created by tosru on 2020/04/13
//  ©︎ 2020 tosru
//

import RealmSwift

class DataManager {
  
  // 読み込み
  fileprivate func objects<T: Object>(_ type: T.Type, predicateFormat: String? = nil) -> Results<T>? {
    if !isRealmAccessible() { return nil }
    let realm = try! Realm()
    realm.refresh()
    
    return predicateFormat == nil ? realm.objects(type) : realm.objects(type).filter(predicateFormat!)
  }
  
  // 書き込み
  fileprivate func add<T: Object>(_ data: T, update: Realm.UpdatePolicy = .modified) {
    if !isRealmAccessible() { return }
    let realm = try! Realm()
    realm.refresh()
    
    if realm.isInWriteTransaction {
      realm.add(data, update: update)
    } else {
      try? realm.write {
        realm.add(data, update: update)
      }
    }
  }
  
  // 削除
  fileprivate func delete<T: Object>(_ data: T) {
    let realm = try! Realm()
    realm.refresh()
    try? realm.write {
      realm.delete(data)
    }
  }
  
  fileprivate func runTransaction(action: () -> Void) {
    if !isRealmAccessible() { return }
    let realm = try! Realm()
    try? realm.write {
      action()
    }
  }
  
}

extension DataManager {
  fileprivate func isRealmAccessible() -> Bool {
    do {
      _ = try Realm()
    } catch {
      print("Realm can not access.")
      return false
    }
    return true
  }
  
}

class NarouDataManager {
  func loadFavoriteNovelsNcode() -> [String] {
    var favoriteNovelsNcode: [String] = []
    if let favoriteNovels = DataManager().objects(FavoriteNovel.self) {
      favoriteNovelsNcode = favoriteNovels.compactMap { ($0 as FavoriteNovel).ncode }
    }
    
    return favoriteNovelsNcode
  }
  
  func loadFavoriteNovel(ncode: String) -> FavoriteNovel? {
    let favoriteNovel = DataManager().objects(FavoriteNovel.self, predicateFormat: "ncode == '\(ncode)'")?.first
    
    return favoriteNovel
  }
  
  func saveFavoriteNovel(_ favoriteNovel: FavoriteNovel) {
    DataManager().add(favoriteNovel)
  }
  
  func deleteFavoriteNovel(ncode: String) {
    if let favoriteNovel = loadFavoriteNovel(ncode: ncode) {
      DataManager().delete(favoriteNovel)
    } else {
      print("Error", "can not delete of \(ncode)'s novel")
    }
  }
  
  func updateAlreadyStoryNum(ncode: String, selectedStoryNum: Int) {
    DataManager().runTransaction {
      if let favoriteNovel = loadFavoriteNovel(ncode: ncode) {
        if favoriteNovel.readStoryNumber < selectedStoryNum {
          favoriteNovel.readStoryNumber = selectedStoryNum
        }
      } else {
        print("Error", "can not update of \(ncode)'s novel")
      }
    }
  }
  
  func toggleReverseOrder(ncode: String) {
    DataManager().runTransaction {
      if let favoriteNovel = loadFavoriteNovel(ncode: ncode) {
        favoriteNovel.isReverseOrder.toggle()
      } else {
        print("Error", "can not toggle isReverseOrder of \(ncode)'s novel")
      }
    }
  }
  
}
