//
//  FirebaseStorageManager.swift
//  BoxOffice
//
//  Created by 엄철찬 on 2022/10/22.
//

import UIKit
import FirebaseStorage
import Firebase

class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    
    let storage = Storage.storage()
    
    lazy var storageRef = storage.reference()
    
    func uploadImage(image:UIImage,filePath:String){
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        let filePath = filePath + "Image"
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storage.reference().child(filePath).putData(data,metadata: metaData) { metaData, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("이미지업로드성공")
            }
        }
    }
    
    func uploadData(_ review:ReviewModel,filePath:String){
        do{
            let data = try JSONEncoder().encode(review)
         //   let filePath = UUID().uuidString
            storage.reference().child(filePath).putData(data)
            print("데이터업로드성공")
        }catch{
            print(error.localizedDescription)
        }
    }
    func downloadImage(urlString: String) async -> UIImage?{
        let storageReference = storage.reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        var image: UIImage?
        storageReference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else { return }
            //imageView.image = UIImage(data: imageData)
            image = UIImage(data: imageData)
            print("이미지다운로드성공")
        }
        return image
    }

//    func download(urlString:String) async throws -> ReviewModel?{
//        let storageReference = storage.reference(forURL: urlString)
//        var review : ReviewModel?
//        let megaByte = Int64(1 * 1024 * 1024)
//        storageReference.getData(maxSize: megaByte) { data, error in
//            guard let data = data, error == nil else {
//                return }
//                let reviewData = try JSONDecoder().decode(ReviewModel.self, from: data)
//                review = reviewData
//                print("리뷰다운로드성공")
//        }
//        print("review is \(review)")
//        return review
//    }
    
    func delete(){
        let deleteRef = storageRef.child("password")
        deleteRef.delete { error in
            if let error = error{
                print(error.localizedDescription)
            }else{
                print("삭제성공")
            }
        }
    }


}
