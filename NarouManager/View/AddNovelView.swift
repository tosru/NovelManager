//
//  SerchView.swift
//  NarouManager
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import UIKit

protocol SendNcodeDelegate: AnyObject {
  func sendNcode(_ ncode: String)
}

class AddNovelTextField: UITextField {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    tintColor = .narouBlue
    layer.cornerRadius = 3
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 5, dy: 0)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 5, dy: 0)
  }
  
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 5, dy: 0)
  }
  
}

class AddNovelView: UIView {
  
  weak var delegate: SendNcodeDelegate?
  private lazy var textField: AddNovelTextField = {
    let tF = AddNovelTextField()
    tF.placeholder = "Nコードで追加"
    tF.returnKeyType = .done
    tF.delegate = self
    tF.translatesAutoresizingMaskIntoConstraints = false
    return tF
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupTextField()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupTextField() {
    addSubview(textField)
    NSLayoutConstraint.activate(
      [
        textField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
        textField.heightAnchor.constraint(equalToConstant: 30),
        textField.centerXAnchor.constraint(equalTo: centerXAnchor),
        textField.centerYAnchor.constraint(equalTo: centerYAnchor)
      ]
    )
  }
  
}

extension AddNovelView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    //主キーとして一意にするために小文字にする
    guard let ncode = textField.text?.lowercased() else { return true }
    delegate?.sendNcode(ncode)
    return true
  }
  
}
