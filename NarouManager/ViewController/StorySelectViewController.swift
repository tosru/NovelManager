//
//  StorySelectViewController.swift
//  NarouManager
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import SafariServices
import UIKit

class StorySelectViewController: UIViewController {
  
  var novelInfo: NovelInfo?
  private var isFavorite = false
  fileprivate var isReverseOrder = false
  fileprivate let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
    layout.itemSize = CGSize(width: 50, height: 50)
    let cV = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cV.backgroundColor = .white
    cV.translatesAutoresizingMaskIntoConstraints = false
    return cV
  }()
  private lazy var favoriteStarIcon: UIBarButtonItem = {
    let image = UIImage(named: "line-star")?.withRenderingMode(.alwaysTemplate)
    let fSI = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleFavorite))
    return fSI
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if novelInfo?.isFavorite != nil {
      isFavorite = novelInfo!.isFavorite
    }
    if novelInfo?.isReverseOrder != nil {
      isReverseOrder = novelInfo!.isReverseOrder
    }
    setupNavBarButtons()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.title = novelInfo?.title ?? "hoge"
    //navigationBarが隠れているときは処理できない？viewDidLoadではstoryTitleがnilになった
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  private func setupNavBarButtons() {
    let starIcon = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
    if isFavorite {
      favoriteStarIcon.image = starIcon
    }
    let sortImage = UIImage(named: "sort")?.withRenderingMode(.alwaysTemplate)
    let sortIcon = UIBarButtonItem(image: sortImage, style: .plain, target: self, action: #selector(handleSort))
    
    // お気に入りの作品だけsortボタンが出るようにする
    if isFavorite {
      navigationItem.rightBarButtonItems = [sortIcon, favoriteStarIcon]
    } else {
      navigationItem.rightBarButtonItems = [favoriteStarIcon]
    }
  }
  
  @objc private func handleFavorite() {
    guard let ncode = novelInfo?.ncode else { return }
    if isFavorite {
      let image = UIImage(named: "line-star")?.withRenderingMode(.alwaysTemplate)
      favoriteStarIcon.image = image
      NarouDataManager().deleteFavoriteNovel(ncode: ncode)
    } else {
      let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
      favoriteStarIcon.image = image
      let favoriteNovel = FavoriteNovel()
      favoriteNovel.ncode = ncode
      favoriteNovel.readStoryNumber = 0
      favoriteNovel.isReverseOrder = isReverseOrder
      NarouDataManager().saveFavoriteNovel(favoriteNovel)
    }
    isFavorite.toggle()
  }
  
  @objc private func handleSort() {
    guard let ncode = novelInfo?.ncode else { return }
    isReverseOrder.toggle()
    NarouDataManager().toggleReverseOrder(ncode: ncode)
    collectionView.reloadData()
  }
  
  /// SafariでStoryを開く
  /// - Parameters:
  ///   - selectedStoryNum: タップした話数
  fileprivate func openStoryInSafariView(selectedStoryNum: Int) {
    guard
      let ncode = novelInfo?.ncode,
      let aSN = novelInfo?.allStoryNumber,
      let end = novelInfo?.end
      else {
        return
    }
    let isTanpen = (aSN == 1 && end == 0)
    var urlString = "https://ncode.syosetu.com/\(ncode)/"
    if !isTanpen {
      urlString += "\(selectedStoryNum)/"
    }
    guard let url = URL(string: urlString) else { return }
    let vc = SFSafariViewController(url: url)
    present(vc, animated: true, completion: nil)
  }
  
}

final class FavoriteStorySelectViewController: StorySelectViewController {
  
  /// 読んだところまで色を変えるために使用する。
  /// 読んだところの色を変えるために使用されるreadStoryNumberはFavoriteViewControllerから
  /// 渡されるnovelInfoに入っている。これでは、StorySelectViewControllerで最新の状態に更新で
  /// できないのでselectedStoryNumを独自に持っておく
  private var selectedStoryNumber = -1
  private let cellId = "fSSVCcellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 既に読んだ話の色を変えるためリロード
    collectionView.reloadData()
  }
  
  private func setupCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(StoryCell.self, forCellWithReuseIdentifier: cellId)
    view.addSubview(collectionView)
    NSLayoutConstraint.activate(
      [
        collectionView.topAnchor.constraint(equalTo: view.topAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ]
    )
  }
  
}

extension FavoriteStorySelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return novelInfo?.allStoryNumber ?? 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    guard let cell = emptyCell as? StoryCell else { return emptyCell }
    guard let rSN = novelInfo?.readStoryNumber else { return emptyCell }
    if isReverseOrder {
      guard let aSN = novelInfo?.allStoryNumber else { return emptyCell }
      cell.storyNumberLabel.text = "\(aSN - indexPath.item)"
      let unreadStoryNumber = aSN - selectedStoryNumber
      cell.backgroundColor = indexPath.item < min(unreadStoryNumber, aSN - rSN ) ? UIColor.narouBlue : UIColor.lightGray
    } else {
      cell.storyNumberLabel.text = "\(indexPath.item + 1)"
      cell.backgroundColor = indexPath.item < max(selectedStoryNumber, rSN) ? UIColor.lightGray : UIColor.narouBlue
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let aSC = novelInfo?.allStoryNumber else { return }
    let selectedStoryNum = isReverseOrder ? aSC - indexPath.item : indexPath.item + 1
    // タップした話数の中で最も大きいものをRealmへ保存する
    guard let ncode = novelInfo?.ncode else { return }
    NarouDataManager().updateAlreadyStoryNum(ncode: ncode, selectedStoryNum: selectedStoryNum)
    // このViewControllerを開いている間は、selectedStoryNumによってcellの色が変わる
    // (一度、FavoriteVCに戻った場合は、Realmに保存している最大話数を取得できる)
    // そのため、10話を選択したあと、8話を選択すると8話までしか色が変わらなくなるといった問題
    // が起こる。よってmaxを取り一番大きい話数まで色が変わるようにする。
    selectedStoryNumber = max(selectedStoryNum, selectedStoryNumber)
    openStoryInSafariView(selectedStoryNum: selectedStoryNum)
  }
  
}

final class RankingStorySelectViewController: StorySelectViewController {
  
  private let cellId = "rSSVCcellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
  }
    
  private func setupCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(StoryCell.self, forCellWithReuseIdentifier: cellId)
    view.addSubview(collectionView)
    NSLayoutConstraint.activate(
      [
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ]
    )
  }
  
}

extension RankingStorySelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return novelInfo?.allStoryNumber ?? 100
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let templateCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    guard let cell = templateCell as? StoryCell else { return templateCell }
    cell.storyNumberLabel.text = (indexPath.item + 1).description
    cell.backgroundColor = .narouBlue
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // そもそもsortボタンがないので、これで良い
    let selectedStoryNum = indexPath.item + 1
    openStoryInSafariView(selectedStoryNum: selectedStoryNum)
  }
  
}
