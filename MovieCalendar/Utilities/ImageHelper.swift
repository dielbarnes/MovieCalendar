//
//  ImageHelper.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 04/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit
import Alamofire

extension UIImageView {
    
    func setImage(withURL url: URL, placeholderImage: UIImage?, squareCrop: Bool, completion: ((UIImage?) -> Void)? ) {
        
        self.image = placeholderImage
        
        Alamofire.request(url).validate().responseData { response in
            
            if let data = response.result.value {
                
                self.image = UIImage(data: data)
                
                if squareCrop, let image = self.image {
                    
                    let y = (image.size.height - image.size.width) / 2
                    let rect = CGRect(x: 0, y: y, width: image.size.width, height: image.size.width)
                    
                    if let cgImage = image.cgImage?.cropping(to: rect) {
                        self.image = UIImage(cgImage: cgImage)
                    }
                }
                
                completion?(self.image)
            }
            else {
                completion?(nil)
            }
        }
    }
}
