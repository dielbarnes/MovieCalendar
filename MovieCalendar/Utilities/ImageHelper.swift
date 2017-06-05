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
    
    func setImage(withURL url: URL, placeholderImage: UIImage?, completion: ((UIImage?) -> Void)? ) {
        
        self.image = placeholderImage
        
        Alamofire.request(url).validate().responseData { response in
            
            if let data = response.result.value {
                self.image = UIImage(data: data)
                completion?(self.image)
            }
            else {
                completion?(nil)
            }
        }
    }
}
