//
//  TrailerPlayerViewController.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 03/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import AVFoundation
import AVKit

class TrailerPlayerViewController: AVPlayerViewController {
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        self.player = AVPlayer(url: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.player?.play()
    }
}
