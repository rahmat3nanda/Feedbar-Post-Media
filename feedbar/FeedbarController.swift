//
//  FeedbarController.swift
//  feedbar
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/07/22.
//

import UIKit

protocol FeedbarDelegate{
    func hasReachStart()
    func hasChanged(to index:Int)
    func hasReachEnd()
}

enum FeedbarState{
    case stoped, paused, played
}

class FeedbarController: UIViewController {
    private var currentIndex: Int!
    private var barViews: [FeedbarModel]!
    private var animator: UIViewPropertyAnimator?
    private var delegate: FeedbarDelegate!
    
    private var containerView: UIView!
    private var spacing: Double!
    private var horizontalPadding: Double!
    private var barCount: Int!
    private var completionInited: Bool!
    
    var state: FeedbarState!
    
    init(delegate: FeedbarDelegate, container: UIView, durations: [TimeInterval], spacing: Double = 2.0, horizontalPadding: Double = 32.0) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        containerView = container
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        barCount = durations.count
        currentIndex = 0
        barViews = []
        cleanContainerView()
        generateFeedbar(for: barCount, durations: durations)
        state = .stoped
        completionInited = false
        view.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stop()
    }
}

// MARK: Private Zone
private extension FeedbarController{
    private func cleanContainerView(){
        if containerView.subviews.count > 0{
            containerView.subviews.forEach({ $0.removeFromSuperview()})
        }
    }
    
    private func widthPerBar() -> CGFloat{
        let widthContainer = UIScreen.main.bounds.width - horizontalPadding
        let widthSpacing = spacing * Double(barCount - 1)
        return (widthContainer - widthSpacing) / CGFloat(barCount)
    }
    
    private func originX(for index: Int) -> CGFloat {
        let position = widthPerBar() + CGFloat(spacing)
        return CGFloat(index) * position
    }
    
    private func generateFeedbar(for count: Int, durations: [TimeInterval]){
        for i in 0..<count {
            let view = FeedbarView()
            view.frame.size.width = widthPerBar()
            view.frame.size.height = 2
            view.frame.origin.x = originX(for: i)
            let bar = FeedbarModel(view: view, duration: durations[i])
            barViews.append(bar)
            containerView.addSubview(barViews[i].view)
        }
    }
    
    private func configureProgressBar(for index: Int){
        stop()
        if currentIndex < index {
            for i in 0..<index {
                barViews[i].view.progressView.frame.size.width = barViews[i].view.frame.size.width
            }
        }else{
            for i in index...currentIndex {
                barViews[i].view.progressView.frame.size.width = 0
            }
        }
    }
}

extension FeedbarController {
    func next(){
        let newIndex = currentIndex + 1
        if newIndex < barCount {
            animate(to: newIndex)
        }else{
            delegate.hasReachEnd()
        }
    }
    
    func previous(){
        let newIndex = currentIndex - 1
        if newIndex < 0 {
            delegate.hasReachStart()
        }else{
            animate(to: newIndex)
        }
    }
    
    func pause(){
        if let animator = animator {
            if animator.isRunning {
                animator.pauseAnimation()
                state = .paused
            }
        }
    }
    
    func play(){
        if let animator = animator {
            if !animator.isRunning {
                animator.startAnimation()
                state = .played
            }
        }
    }
    
    
    func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
            if animator.state == .stopped {
                animator.finishAnimation(at: .current)
                state = .stoped
            }
        }
    }
    
    func resetFeedbar(){
        currentIndex = 0
        for i in 0..<barViews.count{
            barViews[i].view.progressView.frame.size.width = 0
        }
    }
    
    
    func animate(to index: Int = 0){
        let currentBar = barViews[index]
    
        configureProgressBar(for: index)
        currentIndex = index
        delegate.hasChanged(to: index)
        
        if let _ = animator {
            animator = nil
        }
        
        animator = UIViewPropertyAnimator(duration: currentBar.duration, curve: .linear) {
            currentBar.view.progressView.frame.size.width = currentBar.view.frame.size.width
        }
        
        animator?.addCompletion { [weak self] (position) in
            if position == .end  {
                self?.next()
            }
        }
        
        animator?.isUserInteractionEnabled = false
        animator?.startAnimation()
        state = .played
        
    }
}
