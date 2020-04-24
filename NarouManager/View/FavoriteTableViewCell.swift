//
//  FavoriteTableViewCell.swift
//  NarouManager
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
  
  let titleLabel: UILabel = {
    let tL = UILabel()
    tL.translatesAutoresizingMaskIntoConstraints = false
    return tL
  }()
  let unreadIcon: UIView = {
    let uI = UIView()
    uI.backgroundColor = .narouBlue
    uI.layer.cornerRadius = 2.5
    uI.translatesAutoresizingMaskIntoConstraints = false
    return uI
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupUnreadIcon()
    setupTitleLabel()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUnreadIcon() {
    addSubview(unreadIcon)
    NSLayoutConstraint.activate(
      [
        unreadIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        unreadIcon.widthAnchor.constraint(equalToConstant: 5),
        unreadIcon.heightAnchor.constraint(equalToConstant: 5),
        unreadIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
      ]
    )
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    NSLayoutConstraint.activate(
      [
        titleLabel.leadingAnchor.constraint(equalTo: unreadIcon.trailingAnchor, constant: 15),
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -35),
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
      ]
    )
  }
  
}
