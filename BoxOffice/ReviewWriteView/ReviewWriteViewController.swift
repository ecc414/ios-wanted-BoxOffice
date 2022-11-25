//
//  ReviewWriteViewController.swift
//  BoxOffice
//
//  Created by 엄철찬 on 2022/10/21.
//

import UIKit
import PhotosUI
import FirebaseStorage

class ReviewWriteViewController: UIViewController {
    
    let storage = Storage.storage()
    
    let reviewWriteView = ReviewWriteView()
    
    var movieTitle : String?
    
    var directoryPath : URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
        let documentPath : URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath: URL = documentPath.appendingPathComponent(movieTitle?.makeItFitToURL() ?? "movie")
        self.directoryPath = directoryPath
        do{
            try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false)
        }catch{
            print(error.localizedDescription)
        }
        self.view.backgroundColor = .systemBackground
        addSubViews()
        setConstraints()
        reviewWriteView.delegate = self
    }

    func addSubViews(){
        view.addSubview(reviewWriteView)
        reviewWriteView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints(){
        NSLayoutConstraint.activate([
            reviewWriteView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            reviewWriteView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            reviewWriteView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            reviewWriteView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    func alert(message:String){
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .cancel){_ in
            if message == "리뷰가 등록되었습니다"{
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true)
        
    }
    
    func check(with pw: String) -> Bool{
        guard 6...20 ~= pw.count else { return false}
        let length = pw.count
        let range = NSRange(location: 0, length: length)
        let smallPattern = "[a-z]"
        let numberPattern = "[\\d]"
        let specialPattern = "[!@#$]"
        do{
            let regexOfSmall = try NSRegularExpression(pattern: smallPattern)
            let resultOfSmall = regexOfSmall.numberOfMatches(in: pw, range: range)

            let regexOfNumber = try NSRegularExpression(pattern: numberPattern)
            let resultOfNumber = regexOfNumber.numberOfMatches(in: pw, range: range)

            let regexOfSpecial = try NSRegularExpression(pattern: specialPattern)
            let resultOfSpecial = regexOfSpecial.numberOfMatches(in: pw, range: range)
            if resultOfSmall < 1 || resultOfNumber < 1 || resultOfSpecial < 1{
                return false
            }
        }catch{
            print(error.localizedDescription)
        }
        return true
    }
}

extension ReviewWriteViewController : ReviewWriteViewProtocol{
    func submit() {
        if let pw = reviewWriteView.passwordTextField.text, check(with: pw){
            let filePath = UUID().uuidString + (movieTitle?.makeItFitToURL() ?? "movie")
            FirebaseStorageManager.shared.uploadImage(image: reviewWriteView.profileView.image!, filePath: filePath)
            let id = reviewWriteView.nickNameTextField.text ?? ""
            let comment = reviewWriteView.reviewTextView.text ?? ""
            let rating = reviewWriteView.numOfStars
            FirebaseStorageManager.shared.uploadData(ReviewModel(id: id, pw: pw, comment: comment, rating: rating, profile: "imageName"), filePath: filePath)
            if let directoryPath = directoryPath{
                let path = directoryPath.appendingPathComponent(filePath)
                if let data : Data = "1".data(using: .utf8){
                    do{
                        try data.write(to: path)
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            alert(message: "리뷰가 등록되었습니다")
        }else{
            alert(message: "비밀번호는 소문자, 대문자, 특수문자(!,@,#,$)를 한 가지씩 포함하는 6~20길이의 문자여야 합니다")
        }
    }
    
    func pickAPicture() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension ReviewWriteViewController : PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.reviewWriteView.profileView.image = image as? UIImage
                    self.reviewWriteView.editLabel.isHidden = true
                }
            }
        }
    }
}
