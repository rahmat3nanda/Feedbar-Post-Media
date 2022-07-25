//
//  ViewController.swift
//  feedbar
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/07/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var postCollection: UICollectionView!
    var data: [PostModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = []
        for i in 0...10{
            var medias: [MediaModel] = []
            let n = Int.random(in: 1...5)
            for j in 0...n{
                let duration = Double.random(in: 5...10)
                medias.append(MediaModel(duration: duration, message: "Post \(i) Media \(j) duration \(duration.rounded())"))
            }
            data.append(PostModel(medias: medias))
        }
        postCollection.register(UINib(nibName: PostCell.name, bundle: nil), forCellWithReuseIdentifier: PostCell.id)
        postCollection.delegate = self
        postCollection.dataSource = self
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postCollection.dequeueReusableCell(withReuseIdentifier: PostCell.id, for: indexPath) as! PostCell
        cell.setupPost(post: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! PostCell
        cell.setupPost(post: data[indexPath.row])
    }
}

extension ViewController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: postCollection.contentOffset, size: postCollection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = postCollection.indexPathForItem(at: visiblePoint)!
        
        let cell = postCollection.cellForItem(at: index) as! PostCell
        cell.setupPost(post: data[index.row])
    }
}
