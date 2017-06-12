//
//  ZoomTransition.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 12/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit

enum ZoomAnimation: Int {
    
    case zoomIn
    case zoomOut
}

class ZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animation: ZoomAnimation?
    var imageView: UIImageView?
    
    init(animation: ZoomAnimation, imageView: UIImageView) {
        self.animation = animation
        self.imageView = imageView
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning Methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.8
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard animation != nil, imageView != nil else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if animation == .zoomIn { //Present animation
            
            //Add views in transition container
            
            containerView.addSubview(imageView!)
            
            let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            destinationViewController.view.alpha = 0
            
            let colorTransitionView = UIView(frame: transitionContext.finalFrame(for: destinationViewController))
            colorTransitionView.backgroundColor = destinationViewController.view.backgroundColor
            colorTransitionView.alpha = 0
            containerView.addSubview(colorTransitionView)
            
            containerView.addSubview(destinationViewController.view)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                //Zoom in source image view
                
                let width = self.imageView!.frame.size.width * 3.37
                let height = self.imageView!.frame.size.height * 3.37
                
                self.imageView!.frame = CGRect(x: 0, y: 20.0, width: width, height: height)
                self.imageView!.transform = CGAffineTransform(scaleX: 3.37, y: 3.37)
                
                //Hide source image view
                
                self.imageView!.alpha = 0
                colorTransitionView.alpha = 1.0
                
            }, completion: { finished in
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    //Show destination view
                    
                    destinationViewController.view.alpha = 1.0
                    
                }, completion: { finished in
                    
                    //Finish transition
                    
                    transitionContext.completeTransition(finished)
                    
                    colorTransitionView.removeFromSuperview()
                    self.imageView!.removeFromSuperview()
                    
                    let sourceViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
                    sourceViewController.endAppearanceTransition()
                })
            })
        }
        else { //Dismiss animation
            
            //Add views in transition container
            
            let destinationFrame = imageView!.frame
            
            let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            containerView.addSubview(destinationViewController.view)
            
            let sourceViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
            
            imageView!.frame = sourceViewController.view.frame
            containerView.addSubview(imageView!)
            
            let colorTransitionView = UIView(frame: sourceViewController.view.frame)
            colorTransitionView.backgroundColor = sourceViewController.view.backgroundColor
            containerView.addSubview(colorTransitionView)
            
            containerView.addSubview(sourceViewController.view)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                //Hide source view
                
                sourceViewController.view.alpha = 0
                
            }, completion: { finished in
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    //Zoom out destination image view
                    
                    colorTransitionView.frame = destinationFrame
                    colorTransitionView.alpha = 0
                    
                    self.imageView!.frame = destinationFrame
                    self.imageView!.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    self.imageView!.alpha = 0
                    
                }, completion: { finished in
                    
                    //Finish transition
                    
                    transitionContext.completeTransition(finished)
                    
                    colorTransitionView.removeFromSuperview()
                    self.imageView!.removeFromSuperview()
                    
                    sourceViewController.endAppearanceTransition()
                })
            })
        }
    }
}
