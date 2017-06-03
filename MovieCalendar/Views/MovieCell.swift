//
//  MovieCell.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 04/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Top right corner banner
        
        //Triangle mask
        
        let maskPath = UIBezierPath()
        maskPath.move(to: CGPoint(x: 0, y: 0))
        maskPath.addLine(to: CGPoint(x: 50.0, y: 0))
        maskPath.addLine(to: CGPoint(x: 50.0, y: 50.0))
        maskPath.addLine(to: CGPoint(x: 0, y: 0))
        
        let mask = CAShapeLayer()
        mask.frame = bannerView.bounds
        mask.path = maskPath.cgPath
        bannerView.layer.mask = mask
        
        //Corner highlight
        
        let highlightPath = UIBezierPath()
        highlightPath.move(to: CGPoint(x: 3.0, y: 2.0))
        highlightPath.addLine(to: CGPoint(x: 48.0, y: 2.0))
        highlightPath.addLine(to: CGPoint(x: 48.0, y: 48.0))
        highlightPath.addLine(to: CGPoint(x: 45.0, y: 48.0))
        highlightPath.addLine(to: CGPoint(x: 45.0, y: 5.0))
        highlightPath.addLine(to: CGPoint(x: 3.0, y: 5.0))
        highlightPath.addLine(to: CGPoint(x: 3.0, y: 2.0))
        
        let highlight = CAShapeLayer()
        highlight.shadowOffset = CGSize.zero
        highlight.shadowColor = UIColor.white.cgColor
        highlight.shadowRadius = 2.0
        highlight.shadowOpacity = 0.5
        highlight.shadowPath = highlightPath.cgPath
        bannerView.layer.addSublayer(highlight)
        
        //Edge shadow
        
        let x = bannerView.frame.origin.x + 10.0
        let y = bannerView.frame.origin.y - 5.0
        
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: x, y: y))
        shadowPath.addLine(to: CGPoint(x: x + bannerView.frame.size.width, y: bannerView.frame.size.height - 10.0))
        shadowPath.addLine(to: CGPoint(x: x + bannerView.frame.size.width, y: bannerView.frame.size.height + 8.0))
        shadowPath.addLine(to: CGPoint(x: x - 8.0, y: y))
        shadowPath.addLine(to: CGPoint(x: x, y: y))
        
        let shadow = CAShapeLayer()
        shadow.shadowOffset = CGSize.zero
        shadow.shadowColor = UIColor.black.cgColor
        shadow.shadowRadius = 3.0
        shadow.shadowOpacity = 0.5
        shadow.shadowPath = shadowPath.cgPath
        posterView.layer.addSublayer(shadow)
    }
    
    func configureBannerLabel(withDate date: Date) {
        
        let weekdayFont = UIFont(name:"Futura-Medium", size: 10.0)
        let dayFont = UIFont(name:"Futura-Bold", size: 12.0)
        
        let weekdayAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: weekdayFont]
        let dayAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: dayFont]
        
        let attributedText = NSMutableAttributedString(string: "\(date.weekdayString().uppercased())\n", attributes: weekdayAttributes)
        attributedText.append(NSMutableAttributedString(string: "\(date.day())", attributes: dayAttributes))
        bannerLabel.attributedText = attributedText
    }
}
