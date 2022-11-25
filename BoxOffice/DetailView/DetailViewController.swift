//
//  DetailViewController.swift
//  BoxOffice
//
//  Created by 엄철찬 on 2022/10/18.
//

import UIKit
import FirebaseStorage
import Firebase

class DetailViewController : UIViewController{
    
    let detailView = DetailView()
            
    var movie : Movie?
    
    var contents : [String] = []
    
    let storage = Storage.storage()
    
    lazy var storageRef = storage.reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
        let documentPath : URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath: URL = documentPath.appendingPathComponent(movie?.detailInfo.movieNmEn.makeItFitToURL() ?? "movie")
        do{
            try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false)
        }catch{
            print(error.localizedDescription)
        }
        do{
            contents = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
        }catch{
            print(error.localizedDescription)
        }
        setInfo()
        detailView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReviews()
        print("detailView loaded")
    }

    func loadReviews(){
        detailView.reviews.removeAll()
        for content in contents{
            let url = "gs://boxoffice-18825.appspot.com/" + content
            let ref = storageRef.storage.reference(forURL: url)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error{
                    print("error \(error.localizedDescription)")
                }else{
                    print("success")
                    if let data = data{
                        do{
                            let reviewData = try JSONDecoder().decode(ReviewModel.self, from: data)
                            self.detailView.reviews.append(reviewData)
                            print(reviewData)
                            self.detailView.tableView.reloadData()
                        }catch{
                            print("decodeError")
                        }
                    }
                }
            }
        }
    }

    
    func setInfo(){
        detailView.setInfo(movie: movie!)
    }
    
    override func loadView() {
        self.view = detailView
    }

}

extension DetailViewController : DetailViewProtocol{
    func presentReviewWriteView() {
        let vc = ReviewWriteViewController()
        vc.movieTitle = movie?.detailInfo.movieNmEn
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
