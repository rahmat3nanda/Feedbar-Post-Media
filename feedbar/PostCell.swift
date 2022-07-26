//
//  PostCell.swift
//  feedbar
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/07/22.
//

import Foundation
import UIKit

class PostCell: UICollectionViewCell{
    @IBOutlet var mediaCollection: UICollectionView!
    @IBOutlet var feedBarContainerView: UIView!
    
    private var feedbarController: FeedbarController!
    private var post: PostModel!
    var currentIndex: Int!
    
    static var name = "PostCell"
    static var id = "postCell"
    
    func setupPost(post: PostModel){
        mediaCollection.register(UINib(nibName: MediaCell.name, bundle: nil), forCellWithReuseIdentifier: MediaCell.id)
        mediaCollection.delegate = self
        mediaCollection.dataSource = self
        currentIndex = 0
        
        self.post = post
        if let cell = mediaCollection.visibleCells.first as? MediaCell {
            cell.setupMedia(media: post.medias[currentIndex])
        }
        var durations: [TimeInterval] = []
        for i in 0..<post.medias.count {
            durations.append(post.medias[i].duration)
        }
        feedbarController = FeedbarController(delegate: self, container: feedBarContainerView, durations: durations)
        feedbarController.animate()
        
        mediaCollection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePause)))
    }
    
    @objc
    func handlePause() {
        switch(feedbarController.state){
        case .paused:
            feedbarController.play()
        case .played:
            feedbarController.pause()
        default:
            break
        }
        updateCellStatus()
    }
    
    private func updateCellStatus() {
        var status = ""
        switch(feedbarController.state){
        case .paused:
            status = "Paused"
            break
        case .played:
            status = "Played"
            break
        default:
            break
        }
        if let cell = mediaCollection.visibleCells.first as? MediaCell {
            cell.updateStatus(to: status)
        }
    }
}

extension PostCell: FeedbarDelegate{
    func hasReachStart() {
        scrollPost(to: 0)
        feedbarController.animate()
    }
    
    func hasChanged(to index: Int) {
        scrollPost(to: index, animated: true)
    }
    
    func hasReachEnd() {
        scrollPost(to: 0, animated: true)
        feedbarController.animate()
    }
}

extension PostCell: UICollectionViewDelegate{
    
}

extension PostCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.frame.size
    }
}

extension PostCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mediaCollection.dequeueReusableCell(withReuseIdentifier: MediaCell.id, for: indexPath) as! MediaCell
        cell.setupMedia(media: post.medias[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MediaCell
        cell.setupMedia(media: post.medias[indexPath.row])
    }
}

extension PostCell: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if feedbarController.state == .played{
            feedbarController.pause()
            updateCellStatus()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: mediaCollection.contentOffset, size: mediaCollection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = mediaCollection.indexPathForItem(at: visiblePoint)!
        
        let cell = mediaCollection.cellForItem(at: index) as! MediaCell
        cell.setupMedia(media: post.medias[index.row])
        feedbarController.play()
        updateCellStatus()
        if currentIndex != index.row {
            currentIndex = index.row
            feedbarController.animate(to: currentIndex)
        }
    }
}


// MARK: Helper
extension PostCell {
    func scrollPost(to index: Int, animated: Bool = false){
        currentIndex = index
        mediaCollection.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
}
