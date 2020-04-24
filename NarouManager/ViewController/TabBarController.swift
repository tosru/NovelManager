//
//  ViewController.swift
//  
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import UIKit

class TabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewControllers()
  }
  
  private func setupViewControllers() {
    let favoriteVC = FavoriteViewController()
    let favoriteNC = UINavigationController(rootViewController: favoriteVC)
    favoriteNC.view.backgroundColor = .white
    favoriteNC.view.frame = view.frame
    let starImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
    favoriteNC.tabBarItem = UITabBarItem(title: "お気に入り", image: starImage, tag: 0)
    
    // 完成するまで、実機でビルドするときはランキングを消しておく
    #if targetEnvironment(simulator)
      let rankingVC = RankingViewController()
      let rankingNC = UINavigationController(rootViewController: rankingVC)
      rankingNC.view.backgroundColor = .white
      rankingNC.view.frame = view.frame
      let rankingImage = UIImage(named: "ranking")?.withRenderingMode(.alwaysTemplate)
      
      rankingNC.tabBarItem = UITabBarItem(title: "ランキング", image: rankingImage, tag: 1)
      
      viewControllers = [favoriteNC, rankingNC]
    #else
      viewControllers = [favoriteNC]
    #endif
    
  }

}
