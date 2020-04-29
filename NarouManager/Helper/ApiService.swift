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
  private let baseURL = "https://api.syosetu.com/novelapi/api/?out=json&of=t-n-ga-e"
  
  func fetchNovelInfo(fromNcode ncode: String, completion: @escaping ([NovelInfo]) -> Void) {
    fetchJson(from: baseURL + "&ncode=" + ncode, completion: completion)
  }
  
  func fetchNovelsInfo(fromNcodes ncodes: [String], completion: @escaping ([NovelInfo]) -> Void) {
    if ncodes.isEmpty { return }
    let ncodes = ncodes.joined(separator: "-")
    fetchJson(from: baseURL + "&ncode=" + ncodes, completion: completion)
  }
  
  func fetchRankingNovelInfo(type: RankingType, genres: [NovelGenre]? = nil, completion: @escaping ([NovelInfo]) -> Void) {
    let rankingBaseUrl = baseURL + "&lim=3"
    switch type {
    case .genre:
      guard let genres = genres else {
        print("Error", "should select genre")
        return
      }
      var rankingOfGenreNovelsInfo: [NovelInfo] = []
      let urlString = { (genreId: Int) -> String in
        return rankingBaseUrl + "&order=hyoka&genre=\(genreId)"
      }
      // 指定したジャンルの順に入れるために以下のような方法を取っている
      // FIXME: これだとジャンルを追加するたびに変更する必要がある
      fetchJson(from: urlString(genres[0].rawValue)) { novelsInfo in
        rankingOfGenreNovelsInfo.append(contentsOf: novelsInfo)
        self.fetchJson(from: urlString(genres[1].rawValue)) { novelsInfo in
          rankingOfGenreNovelsInfo.append(contentsOf: novelsInfo)
          self.fetchJson(from: urlString(genres[2].rawValue)) { novelsInfo in
            rankingOfGenreNovelsInfo.append(contentsOf: novelsInfo)
            self.fetchJson(from: urlString(genres[3].rawValue)) { novelsInfo in
              rankingOfGenreNovelsInfo.append(contentsOf: novelsInfo)
              completion(rankingOfGenreNovelsInfo)
            }
          }
        }
      }
            
    case .period:
      let periods = ["daily", "weekly", "monthly", "quarter", "yearly"]
      var rankingOfPeriodNovelsInfo: [NovelInfo] = []
      let urlString = { (period: String) -> String in
        return rankingBaseUrl + "&order=" + period + "point"
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
                completion(rankingOfPeriodNovelsInfo)
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
        DispatchQueue.main.async {
          completion(formattedNovelsInfo)
        }
      } catch let parseError {
        print("Error", parseError)
      }
    }
    task.resume()
  }
}
