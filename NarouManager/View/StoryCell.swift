//
//  StoryCell.swift
//  NarouManager
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import UIKit

class StoryCell: UICollectionViewCell {
  
  let storyNumberLabel: UILabel = {
    let sI = UILabel()
    sI.textColor = .white
    sI.font = UIFont.systemFont(ofSize: 22)
    sI.translatesAutoresizingMaskIntoConstraints = false
    return sI
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .lightGray
    setupStoryIndexLabel()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStoryIndexLabel() {
    addSubview(storyNumberLabel)
    NSLayoutConstraint.activate(
      [
        storyNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        storyNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
      ]
    )
  }
  
}
