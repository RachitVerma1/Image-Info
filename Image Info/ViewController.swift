//
//  ViewController.swift
//  Image Info
//
//  Created by Rohit Kumar on 12/01/18.
//  Copyright © 2018 Rachit Development. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
   let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let userShotImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        itemImageView.image = userShotImage
        
        guard let ciImage = CIImage(image: userShotImage!) else { fatalError("Error converting image")}
        detect(image: ciImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error loading model")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError()
            }
            let str1 = classification.identifier
            let index = str1.index(of: ",") ?? str1.endIndex
            let str2 = str1[..<index]
            let newStr = String(str2)
            self.navigationItem.title = newStr
            self.requestInfo(flowerName: newStr)

        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    func requestInfo(flowerName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            
        ]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseData { (response) in
            if response.result.isSuccess {
                print("Got data from Wiki")
                //              print(response)


            }
            let flowerJSON = JSON(response.result.value!)
            let pageid = flowerJSON["query"]["pageids"][0].stringValue
            let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
            let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
            self.descriptionLabel.text = flowerDescription
          

        
            
            
        }


    }
}


