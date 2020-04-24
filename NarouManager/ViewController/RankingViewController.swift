//
//  RankingViewController.swift
//  NarouManager
//
//  Created by tosru on 2020/04/14
//  ©︎ 2020 tosru
//

import UIKit

enum RankingType: Int {
  case period
  case genre
}

enum NovelGenre: Int {
  case isekaiRennai = 101
  case gennjituSekaiRennai = 102
  case hiFantasy = 201
  case lowFantasy = 202
  
  func toJapanese() -> String {
    switch self {
    case .isekaiRennai:
      return "異世界恋愛"
    case .gennjituSekaiRennai:
      return "現実世界恋愛"
    case .hiFantasy:
      return "ハイファンタジー"
    case .lowFantasy:
      return "ローファンタジー"
    }
  }
  
}

class RankingViewController: UIViewController {
  
  private var periodNovelsInfo: [[NovelInfo]] = []
  private var genreNovelsInfo: [[NovelInfo]] = []
  private let periods = ["日間", "週間", "月間", "四半期", "年間"]
  private let genres: [NovelGenre] = [.isekaiRennai, .gennjituSekaiRennai, .hiFantasy, .lowFantasy]
  private let cellId = "rVCcellId"
  private var isDisplayingPeriodRanking = true
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.itemSize = CGSize(width: view.frame.width, height: 180)
    let cV = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cV.backgroundColor = .white
    cV.dataSource = self
    cV.delegate = self
    cV.translatesAutoresizingMaskIntoConstraints = false
    return cV
  }()
  private lazy var segmentedControlView: RankingSegmentedControlView = {
    let sCV = RankingSegmentedControlView()
    sCV.backgroundColor = .narouBlue
    sCV.segmentedControl.addTarget(self, action: #selector(handleSegmentedControl), for: .valueChanged)
    sCV.translatesAutoresizingMaskIntoConstraints = false
    return sCV
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    setupSegmentedControlView()
    setupCollectionView()
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if isDisplayingPeriodRanking {
      if periodNovelsInfo.isEmpty {
        ApiService.shared.fetchRankingNovelInfo(type: .period) { novelsInfo in
          self.periodNovelsInfo = novelsInfo.chunked(by: 3)
          self.collectionView.reloadData()
        }
      }
    } else {
      if genreNovelsInfo.isEmpty {
        ApiService.shared.fetchRankingNovelInfo(type: .genre, genres: genres) { novelsInfo in
          self.genreNovelsInfo = novelsInfo.chunked(by: 3)
          self.collectionView.reloadData()
        }
      }
    }
  }
  
  private func setupSegmentedControlView() {
    view.addSubview(segmentedControlView)
    NSLayoutConstraint.activate(
      [
        segmentedControlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        segmentedControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        segmentedControlView.heightAnchor.constraint(equalToConstant: 50)
      ]
    )
  }
  
  private func setupCollectionView() {
    collectionView.register(RankingCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    view.addSubview(collectionView)
    collectionView.refreshControl = UIRefreshControl()
    collectionView.refreshControl?.tintColor = .narouBlue
    collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    NSLayoutConstraint.activate(
      [
        collectionView.topAnchor.constraint(equalTo: segmentedControlView.bottomAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ]
    )
  }
  
  // FIXME: なぜか初回のみ期間からジャンル表記へ切り替えた時にcellに何も表示されなくなる
  @objc private func handleSegmentedControl() {
    isDisplayingPeriodRanking.toggle()
    collectionView.reloadData()
    if isDisplayingPeriodRanking && periodNovelsInfo.isEmpty {
      // デフォルトで期間が選択されているのでここに入ることはないと思う
    } else if !isDisplayingPeriodRanking && genreNovelsInfo.isEmpty {
      ApiService.shared.fetchRankingNovelInfo(type: .genre, genres: genres) { novelsInfo in
        self.genreNovelsInfo = novelsInfo.chunked(by: 3)
        self.collectionView.reloadData()
      }
    }
  }
  
  @objc private func handleRefreshControl() {
    if isDisplayingPeriodRanking {
      ApiService.shared.fetchRankingNovelInfo(type: .period) { novelsInfo in
        self.periodNovelsInfo = novelsInfo.chunked(by: 3)
        self.collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
        print("updated period")
      }
    } else {
      ApiService.shared.fetchRankingNovelInfo(type: .genre, genres: genres) { novelsInfo in
        self.genreNovelsInfo = novelsInfo.chunked(by: 3)
        self.collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
        print("updated genre")
      }
    }
    
  }
  
  @objc private func handleButton(sender: UIButton) {
    guard let sender = sender as? BaseButton else { return }
    var novelInfo: NovelInfo
    var vc: StorySelectViewController
    if isDisplayingPeriodRanking {
      novelInfo = periodNovelsInfo[sender.cellIndex][sender.tag]
    } else {
      novelInfo = genreNovelsInfo[sender.cellIndex][sender.tag]
    }
    guard let ncode = novelInfo.ncode else { return }
    // ランキングに載っている作品が既にお気に入りかどうか判定
    if NarouDataManager().loadFavoriteNovel(ncode: ncode) != nil {
      novelInfo.isFavorite = true
      vc = FavoriteStorySelectViewController()
    } else {
      novelInfo.isFavorite = false
      vc = RankingStorySelectViewController()
    }
    vc.novelInfo = novelInfo
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

extension RankingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if periodNovelsInfo.isEmpty && genreNovelsInfo.isEmpty {
      return 5
    }
    return isDisplayingPeriodRanking ? periodNovelsInfo.count : genreNovelsInfo.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    guard let cell = emptyCell as? RankingCollectionViewCell else { return emptyCell }
    cell.firstPlaceButton.startLoading()
    cell.secondPlaceButton.startLoading()
    cell.thirdPlaceButton.startLoading()
    var displayingNovelsInfo: [NovelInfo] = []
    if isDisplayingPeriodRanking {
      cell.title.text = periods[indexPath.item]
      if !periodNovelsInfo.isEmpty {
        displayingNovelsInfo = periodNovelsInfo[indexPath.item]
      } else {
        // タイトルと順位だけ入ったcellを返す
        return cell
      }
    } else {
      cell.title.text = genres[indexPath.item].toJapanese()
      if !genreNovelsInfo.isEmpty {
        displayingNovelsInfo = genreNovelsInfo[indexPath.item]
      } else {
        // タイトルと順位だけ入ったcellを返す
        return cell
      }
    }
    cell.firstPlaceButton.stopLoading()
    cell.firstPlaceButton.cellIndex = indexPath.item
    cell.firstPlaceButton.setTitle(displayingNovelsInfo[0].title, for: .normal)
    cell.firstPlaceButton.addTarget(self, action: #selector(handleButton(sender:)), for: .touchUpInside)
    cell.secondPlaceButton.stopLoading()
    cell.secondPlaceButton.cellIndex = indexPath.item
    cell.secondPlaceButton.setTitle(displayingNovelsInfo[1].title, for: .normal)
    cell.secondPlaceButton.addTarget(self, action: #selector(handleButton(sender:)), for: .touchUpInside)
    cell.thirdPlaceButton.stopLoading()
    cell.thirdPlaceButton.cellIndex = indexPath.item
    cell.thirdPlaceButton.setTitle(displayingNovelsInfo[2].title, for: .normal)
    cell.thirdPlaceButton.addTarget(self, action: #selector(handleButton(sender:)), for: .touchUpInside)
    
    return cell
  }

}
