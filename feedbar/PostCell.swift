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
    
    private var post: PostModel!
    private var message: String!
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: mediaCollection.contentOffset, size: mediaCollection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = mediaCollection.indexPathForItem(at: visiblePoint)!
        
        let cell = mediaCollection.cellForItem(at: index) as! MediaCell
        cell.setupMedia(media: post.medias[index.row])
        currentIndex = index.row
    }
}
