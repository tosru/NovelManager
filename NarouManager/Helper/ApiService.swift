//
//  ApiService.swift
//  NarouManager
//
//  Created by tosru on 2020/04/11
//  ©︎ 2020 tosru
//

import Foundation

class ApiService {
  
  static let shared = ApiService()
  private let baseURL = "https://api.syosetu.com/novelapi/api/?out=json"
  
  func fetchNovelInfo(fromNcode ncode: String, completion: @escaping ([NovelInfo]) -> Void) {
//    fetchJson(from: baseURL + "&ncode=" + ncode, completion: completion)
    fetchJson(from: "\(baseURL)&of=t-n-ga-e&ncode=\(ncode)") { novelInfo in
      DispatchQueue.main.async {
        completion(novelInfo)
      }
    }
  }
  
  func fetchNovelsInfo(fromNcodes ncodes: [String], completion: @escaping ([NovelInfo]) -> Void) {
    if ncodes.isEmpty { return }
    let ncodes = ncodes.joined(separator: "-")
//    fetchJson(from: baseURL + "&ncode=" + ncodes, completion: completion)
    fetchJson(from: "\(baseURL)&of=t-n-ga-e&ncode=\(ncodes)") { novelInfo in
      DispatchQueue.main.async {
        completion(novelInfo)
      }
    }
  }
  
  func fetchRankingNovelInfo(type: RankingType, genres: [NovelGenre]? = nil, completion: @escaping ([NovelInfo]) -> Void) {
    
    let rankingBaseURL = "\(baseURL)&lim=3"
    switch type {
    case .genre:
      guard let genres = genres else {
        print("Error", "should select genre")
        return
      }
      var rankingOfGenreNovelsInfo: [NovelInfo] = []
      let urlString = { (genreId: Int) -> String in
        return "\(rankingBaseURL)&order=hyoka&genre=\(genreId)&of=t-n-ga-e-g"
      }
     
      // ランキングの情報を非同期で取得する
      // ランキング順にはなっているが、ジャンルが引数で与えた順ではなくなるので
      // RankingViewControllerでgenreIDを用いてソートさせる
      let start = Date()
      let dispatchGroup = DispatchGroup()
      let dispatchQueue = DispatchQueue(label: "genrequeue")
      for genre in genres {
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
          self.fetchJson(from: urlString(genre.rawValue)) { novelsInfo in
            // 同じ変数を参照しているので直列処理にする
            rankingOfGenreNovelsInfo.append(contentsOf: novelsInfo)
            dispatchGroup.leave()
          }
        }
      }
      dispatchGroup.notify(queue: .main) {
        completion(rankingOfGenreNovelsInfo)
        let finish = Date().timeIntervalSince(start)
        print(finish)
      }
      
    case .period:
      let periods = ["daily", "weekly", "monthly", "quarter", "yearly"]
      var rankingOfPeriodNovelsInfo: [NovelInfo] = []
      let urlString = { (period: String) -> String in
        return rankingBaseURL + "&order=" + period + "point&of=t-n-ga-e"
      }
      // 配列にdaily,weekly,monthly,quarter,yearlyの順に入れるために以下のような方法を取っている
      fetchJson(from: urlString(periods[0])) { novelsInfo in
        // daily
        rankingOfPeriodNovelsInfo.append(contentsOf: novelsInfo)
        self.fetchJson(from: urlString(periods[1])) { novelsInfo in
          // weekly
          rankingOfPeriodNovelsInfo.append(contentsOf: novelsInfo)
          self.fetchJson(from: urlString(periods[2])) { novelsInfo in
            // monthly
            rankingOfPeriodNovelsInfo.append(contentsOf: novelsInfo)
            self.fetchJson(from: urlString(periods[3])) { novelsInfo in
              // quarter
              rankingOfPeriodNovelsInfo.append(contentsOf: novelsInfo)
              self.fetchJson(from: urlString(periods[4])) { novelsInfo in
                // yearly
                rankingOfPeriodNovelsInfo.append(contentsOf: novelsInfo)
                DispatchQueue.main.async {
                  completion(rankingOfPeriodNovelsInfo)
                }
              }
            }
          }
        }
      }
    }
  }
  
  private func fetchJson(from urlString: String, completion: @escaping ([NovelInfo]) -> Void) {
    guard let url = URL(string: urlString) else { return }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        print(error ?? "Response error")
        return
      }
      do {
        var novelsInfo = try JSONDecoder().decode([NovelInfo].self, from: data)
        //allcount情報のオブジェクトが配列の最初に入るため削除
        novelsInfo.remove(at: 0)
        let formattedNovelsInfo = novelsInfo.map { nI -> NovelInfo in
          let temp = nI.ncode?.lowercased()
          nI.ncode = temp
          return nI
        }
        // 全てがUIの処理を含むわけではないのでmain.asyncを外す
        completion(formattedNovelsInfo)
      } catch let parseError {
        print("Error", parseError)
      }
    }
    task.resume()
  }
}
