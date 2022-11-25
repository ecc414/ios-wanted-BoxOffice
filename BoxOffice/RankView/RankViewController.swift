//
//  ViewController.swift
//  BoxOffice
//
//  Created by kjs on 2022/10/14.
//

import UIKit

class RankViewController: UIViewController {
 
    let rankView = RankView()
    
    var detailInfo : [MovieInfo] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        makeNavigationBarClear()
        rankView.delegate = self
    }
    
    override func loadView() {
        self.view = rankView
    }
    
    func makeNavigationBarClear(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func fetch(){
        Task{
            do{
                let response = try await MovieService().getMovieInfo()
                rankView.range = response.boxOfficeResult.showRange
                rankView.tableView.reloadData()
                let boxOfficeInfoArr = response.boxOfficeResult.dailyBoxOfficeList
                if rankView.movie.count == 10{
                    return
                }
                for boxOfficeInfo in boxOfficeInfoArr{
                    let detailInfo = try await MovieService().getDetailMovieInfo(movieCd: boxOfficeInfo.movieCd).movieInfoResult.movieInfo
                    let englishTitle = detailInfo.movieNmEn
                    let releaseYear = boxOfficeInfo.openDt.extractYear()
                    var poster : UIImage?
                    var ratings : [Rating] = []
                    do{
                        (poster,ratings) = try await MovieService().getMoviePoster(englishTitle: englishTitle, releaseYear: releaseYear)
                    }catch{
                        print(error.localizedDescription)
                    }
                    let movie = Movie(boxOfficeInfo: boxOfficeInfo, detailInfo: detailInfo, poster: poster ?? UIImage(named: "NoImage")!, rating: ratings)
                    if rankView.movie.contains(where: {$0.boxOfficeInfo.movieNm == movie.boxOfficeInfo.movieNm}) {
                        continue
                    }
                    rankView.movie.append(movie)
                    rankView.tableView.beginUpdates()
                    rankView.tableView.insertRows(at: [IndexPath(row: rankView.movie.count - 1, section: 0)], with: .automatic)
                    rankView.tableView.endUpdates()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }

}

extension RankViewController : RankViewProtocol{
    func presentDetailView(movie:Movie) {
        let vc = DetailViewController()
        vc.movie = movie
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func refresh(){
        print("refresh")
        fetch()
    }
}
