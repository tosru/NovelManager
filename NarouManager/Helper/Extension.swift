//
//  Extension.swift
//  NarouManager
//
//  Created by tosru on 2020/04/12
//  ©︎ 2020 tosru
//

import UIKit

extension UIColor {
  ///小説家になろうのホームページで使われていた青っぽい色
  static let narouBlue = UIColor(red: 0, green: 189 / 255, blue: 209 / 255, alpha: 1)
  
}

extension UIViewController {
  /// キーボード以外をタップした時にキーボードを閉じるジェスチャーを追加する
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
}

extension Array {
  
  /// 配列をn個ずつに分ける
  /// - Parameter chunkSize: 何個ずつ分けるか
  func chunked(by chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
  
}
