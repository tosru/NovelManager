//
//  FavoriteViewController.swift
//  NarouManager
//
//  Created by tosru on 2020/04/10
//  ©︎ 2020 tosru
//

import UIKit

class FavoriteViewController: UIViewController {
  
  private let cellId = "fVCcellId"
  private var favoriteNovelsLatestInfo: [NovelInfo] = []
  private var favoriteNovelsNcode: [String] = []
  private lazy var addNovelView: AddNovelView = {
    let aNV = AddNovelView()
    aNV.backgroundColor = .narouBlue
    aNV.delegate = self
    aNV.translatesAutoresizingMaskIntoConstraints = false
    return aNV
  }()
  private lazy var tableView: UITableView = {
    let tV = UITableView()
    tV.delegate = self
    tV.dataSource = self
    tV.translatesAutoresizingMaskIntoConstraints = false
    return tV
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.setNavigationBarHidden(true, animated: false)
    tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: cellId)
    setupAddNovelView()
    setupTableView()
    
    hideKeyboardWhenTappedAround()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //Realmに保存しているncodeを取り出す
    favoriteNovelsNcode = NarouDataManager().loadFavoriteNovelsNcode().sorted()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    ApiService.shared.fetchNovelsInfo(fromNcodes: favoriteNovelsNcode) { novelsInfo in
      //全ての話数を読みきっているか 話数が逆順になっているかを確認する
      for novelInfo in novelsInfo {
        guard
          let ncode = novelInfo.ncode,
          let result = NarouDataManager().loadFavoriteNovel(ncode: ncode)
          else {
            return
        }
        guard let allStoryNumber = novelInfo.allStoryNumber else { return }
        novelInfo.isExistUnreadStory = (result.readStoryNumber < allStoryNumber)
        novelInfo.readStoryNumber = result.readStoryNumber
        novelInfo.isReverseOrder = result.isReverseOrder
      }
      // お気に入りの作品の最新情報を入れる
      if novelsInfo.count >= 2 {
        self.favoriteNovelsLatestInfo = novelsInfo.sorted { $0.ncode! < $1.ncode! }
      } else {
        self.favoriteNovelsLatestInfo = novelsInfo
      }
      self.tableView.reloadData()
    }
  }
  
  private func setupAddNovelView() {
    view.addSubview(addNovelView)
    NSLayoutConstraint.activate(
      [
        addNovelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        addNovelView.widthAnchor.constraint(equalToConstant: view.frame.width),
        addNovelView.heightAnchor.constraint(equalToConstant: 50)
      ]
    )
  }
  
  private func setupTableView() {
    view.addSubview(tableView)
    NSLayoutConstraint.activate(
      [
        tableView.topAnchor.constraint(equalTo: addNovelView.bottomAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ]
    )
  }
  
}

extension FavoriteViewController: SendNcodeDelegate {
  func sendNcode(_ ncode: String) {
    if !isNcode(ncode) {
      print("Nコードではありません")
      return
    }
    if favoriteNovelsNcode.contains(ncode) { return }
    favoriteNovelsNcode.append(ncode)
    // favoriteNovelsNcodeから要素を削除する時にindexPathを使用する
    // indexPathはfavoriteNovelsLatestInfoのデータに基づいているため
    // favoriteNovelsNcodeとfavoriteNovelsLatestInfoのindexを揃える必要がある
    favoriteNovelsNcode.sort()
    ApiService.shared.fetchNovelInfo(fromNcode: ncode) { novelsInfo in
      guard let novelInfo = novelsInfo.first else { return }
      self.favoriteNovelsLatestInfo.append(novelInfo)
      if self.favoriteNovelsLatestInfo.count >= 2 {
        self.favoriteNovelsLatestInfo.sort { $0.ncode! < $1.ncode! }
      }
      self.tableView.reloadData()
      //FavoriteNovelとして保存する
      let favoriteNovel = FavoriteNovel()
      favoriteNovel.ncode = ncode
      NarouDataManager().saveFavoriteNovel(favoriteNovel)
    }
  }
  
  private func isNcode(_ ncode: String) -> Bool {
    let pattern = "^n[0-9]{4}[a-z][a-z]?$"
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
    let range = NSRange(location: 0, length: ncode.utf16.count)
    return regex.firstMatch(in: ncode, range: range) != nil
  }
  
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favoriteNovelsLatestInfo.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let emptyCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    guard let cell = emptyCell as? FavoriteTableViewCell else { return emptyCell }
    cell.titleLabel.text = favoriteNovelsLatestInfo[indexPath.row].title
    cell.unreadIcon.isHidden = !favoriteNovelsLatestInfo[indexPath.row].isExistUnreadStory
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let ncode = favoriteNovelsLatestInfo[indexPath.row].ncode else { return }
      NarouDataManager().deleteFavoriteNovel(ncode: ncode)
      favoriteNovelsNcode.remove(at: indexPath.row)
      favoriteNovelsLatestInfo.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let vc = FavoriteStorySelectViewController()
    let novelInfo = favoriteNovelsLatestInfo[indexPath.row]
    novelInfo.isFavorite = true
    vc.novelInfo = novelInfo
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
