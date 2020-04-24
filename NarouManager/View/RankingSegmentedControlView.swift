//
//  RankingSegmentedControllView.swift
//  NarouManager
//
//  Created by tosru on 2020/04/19
//  ©︎ 2020 tosru
//

import UIKit

class RankingSegmentedControlView: UIView {
  
  let segmentedControl: UISegmentedControl = {
    let sC = UISegmentedControl(items: ["期間", "ジャンル"])
    sC.selectedSegmentIndex = 0
    sC.backgroundColor = .white
    sC.translatesAutoresizingMaskIntoConstraints = false
    return sC
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupSegmentedControl()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupSegmentedControl() {
    addSubview(segmentedControl)
    NSLayoutConstraint.activate(
      [
        segmentedControl.widthAnchor.constraint(equalToConstant: 200),
        segmentedControl.heightAnchor.constraint(equalToConstant: 30),
        segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
        segmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor)
      ]
    )
  }
  
}
