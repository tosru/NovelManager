//
//  RankingCollectionViewCell.swift
//  NarouManager
//
//  Created by tosru on 2020/04/15
//  ©︎ 2020 tosru
//

import UIKit

class BaseButton: UIButton {
  
  var cellIndex = -1
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setTitleColor(.black, for: .normal)
    titleLabel?.lineBreakMode = .byTruncatingTail
    contentHorizontalAlignment = .left
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startLoading() {
    setTitle("", for: .normal)
    layer.cornerRadius = 15
    backgroundColor = UIColor(red: 213 / 255, green: 213 / 255, blue: 213 / 255, alpha: 1)
  }
  
  func stopLoading() {
    layer.cornerRadius = 0
    backgroundColor = .clear
  }
  
}

class RankingCollectionViewCell: UICollectionViewCell {
  
  let title: UILabel = {
    let title = UILabel()
    title.font = UIFont.systemFont(ofSize: 30)
    title.textAlignment = .left
    title.translatesAutoresizingMaskIntoConstraints = false
    return title
  }()
  private let firstPlaceLabel: UILabel = {
    let pL = UILabel()
    pL.text = "1"
    pL.font = UIFont.systemFont(ofSize: 20)
    pL.translatesAutoresizingMaskIntoConstraints = false
    return pL
  }()
  private let secondPlaceLabel: UILabel = {
    let pL = UILabel()
    pL.text = "2"
    pL.font = UIFont.systemFont(ofSize: 20)
    pL.translatesAutoresizingMaskIntoConstraints = false
    return pL
  }()
  private let thirdPlaceLabel: UILabel = {
    let pL = UILabel()
    pL.text = "3"
    pL.font = UIFont.systemFont(ofSize: 20)
    pL.translatesAutoresizingMaskIntoConstraints = false
    return pL
  }()
  let firstPlaceButton: BaseButton = {
    let fPSB = BaseButton()
    fPSB.tag = 0
    return fPSB
  }()
  let secondPlaceButton: BaseButton = {
    let sPSB = BaseButton()
    sPSB.tag = 1
    return sPSB
  }()
  let thirdPlaceButton: BaseButton = {
    let tPSB = BaseButton()
    tPSB.tag = 2
    return tPSB
  }()
  private let separatorView: UIView = {
    let sV = UIView()
    sV.backgroundColor = .lightGray
    sV.translatesAutoresizingMaskIntoConstraints = false
    return sV
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupTitle()
    setupPlaceLabels()
    setupButtons()
    setupSeparatorView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupTitle() {
    addSubview(title)
    NSLayoutConstraint.activate(
      [
        title.topAnchor.constraint(equalTo: topAnchor, constant: 15),
        title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
      ]
    )
  }
  
  private func setupPlaceLabels() {
    addSubview(firstPlaceLabel)
    addSubview(secondPlaceLabel)
    addSubview(thirdPlaceLabel)
    NSLayoutConstraint.activate(
      [
        firstPlaceLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
        firstPlaceLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: 5),
        firstPlaceLabel.widthAnchor.constraint(equalToConstant: 30),
        firstPlaceLabel.heightAnchor.constraint(equalToConstant: 30),
        
        secondPlaceLabel.topAnchor.constraint(equalTo: firstPlaceLabel.bottomAnchor, constant: 7),
        secondPlaceLabel.leadingAnchor.constraint(equalTo: firstPlaceLabel.leadingAnchor),
        secondPlaceLabel.widthAnchor.constraint(equalTo: firstPlaceLabel.widthAnchor),
        secondPlaceLabel.heightAnchor.constraint(equalTo: firstPlaceLabel.heightAnchor),
        
        thirdPlaceLabel.topAnchor.constraint(equalTo: secondPlaceLabel.bottomAnchor, constant: 7),
        thirdPlaceLabel.leadingAnchor.constraint(equalTo: firstPlaceLabel.leadingAnchor),
        thirdPlaceLabel.widthAnchor.constraint(equalTo: firstPlaceLabel.widthAnchor),
        thirdPlaceLabel.heightAnchor.constraint(equalTo: firstPlaceLabel.heightAnchor)
      ]
    )
  }
  
  private func setupButtons() {
    addSubview(firstPlaceButton)
    addSubview(secondPlaceButton)
    addSubview(thirdPlaceButton)
    NSLayoutConstraint.activate(
      [
        firstPlaceButton.topAnchor.constraint(equalTo: firstPlaceLabel.topAnchor),
        firstPlaceButton.trailingAnchor.constraint(equalTo: title.trailingAnchor),
        firstPlaceButton.leadingAnchor.constraint(equalTo: firstPlaceLabel.trailingAnchor, constant: 2),
        firstPlaceButton.heightAnchor.constraint(equalToConstant: 30),

        secondPlaceButton.topAnchor.constraint(equalTo: secondPlaceLabel.topAnchor),
        secondPlaceButton.trailingAnchor.constraint(equalTo: title.trailingAnchor),
        secondPlaceButton.leadingAnchor.constraint(equalTo: firstPlaceButton.leadingAnchor),
        secondPlaceButton.heightAnchor.constraint(equalTo: firstPlaceButton.heightAnchor),

        thirdPlaceButton.topAnchor.constraint(equalTo: thirdPlaceLabel.topAnchor),
        thirdPlaceButton.trailingAnchor.constraint(equalTo: title.trailingAnchor),
        thirdPlaceButton.leadingAnchor.constraint(equalTo: firstPlaceButton.leadingAnchor),
        thirdPlaceButton.heightAnchor.constraint(equalTo: firstPlaceButton.heightAnchor)
      ]
    )
  }
  
  private func setupSeparatorView() {
    addSubview(separatorView)
    NSLayoutConstraint.activate(
      [
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
        separatorView.widthAnchor.constraint(equalTo: widthAnchor),
        separatorView.heightAnchor.constraint(equalToConstant: 1)
      ]
    )
  }
  
}
