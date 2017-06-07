//
//  CastCell.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 06/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit

class CastCell: UITableViewCell {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var label4: UILabel!
    
    func configureCast(_ cast: Cast, index: Int) {
        
        var imageView = UIImageView()
        var label = UILabel()
        
        if index == 0 {
            imageView = imageView1
            label = label1
        }
        else if index == 1 {
            imageView = imageView2
            label = label2
        }
        else if index == 2 {
            imageView = imageView3
            label = label3
        }
        else if index == 3 {
            imageView = imageView4
            label = label4
        }
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        if let path = cast.imagePath, let url = URL(string: "https://image.tmdb.org/t/p/w185" + path) {
            imageView.setImage(withURL: url, placeholderImage: UIImage(named: "cast-placeholder")!, squareCrop: true, completion: nil)
        }
        
        label.text = cast.name
    }
}
