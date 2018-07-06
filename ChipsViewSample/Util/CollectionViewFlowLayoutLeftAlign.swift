//
//  CollectionViewFlowLayoutLeftAlign.swift
//  ChipsViewSample
//
//  Created by Masakazu Sano on 2018/07/06.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit

class CollectionViewFlowLayoutLeftAlign: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // あらかじめ決定されている表示領域内のレイアウト属性を取得
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // layoutAttributesForItemAtIndexPath(_:)で各レイアウト属性を書き換える
        var attributesToReturn = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        for (index, attr) in attributes.enumerated() where attr.representedElementCategory == .cell {
            attributesToReturn[index] = layoutAttributesForItem(at: attr.indexPath) ?? UICollectionViewLayoutAttributes()
        }
        return attributesToReturn
    }
    
    //layoutAttributesForItemAtIndexPath
    // 各セルのレイアウト属性の補正
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let currentAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
            let viewWidth = collectionView?.frame.width else {
                return nil
        }
        
        // TODO: horizontalの場合は崩れるので、他の対応が必要
//        switch self.scrollDirection {
//        case .horizontal:
//            // WIP
//        case .vertical:
//            // WIP
//        }
        
        print("=========================================================")
        print("row: \(indexPath.row)")
        print("🐱 viewWidth: \(viewWidth)")
        
        // sectionInsetの左端の値
        let sectionInsetsLeft = sectionInsets(at: indexPath.section).left
        
        // 先頭セルの場合はx座標を左端にして返す
        guard indexPath.item > 0 else {
            currentAttributes.frame.origin.x = sectionInsetsLeft
            return currentAttributes
        }
        print("💜 currentAttributes.frame.origin.x (1回目): \(currentAttributes.frame.origin.x)")
        
        // ひとつ前のセルを取得
        let prevIndexPath = IndexPath(row: indexPath.item - 1, section: indexPath.section)
        guard let prevFrame = layoutAttributesForItem(at: prevIndexPath)?.frame else {
            return nil
        }
        print("💛 prevFrame: \(prevFrame)")
        
        // 現在のセルの行内にひとつ前のセルが収まっているか比較
        let validWidth = viewWidth - sectionInset.left - sectionInset.right
        print("💛 validWidth: \(validWidth)")
        let currentColumnRect = CGRect(x: sectionInsetsLeft, y: currentAttributes.frame.origin.y, width: validWidth, height: currentAttributes.frame.height)
        guard prevFrame.intersects(currentColumnRect) else { // 収まっていない場合
            currentAttributes.frame.origin.x = sectionInsetsLeft // x座標を左端にして返す
            return currentAttributes
        }
        
        let prevItemTailX = prevFrame.origin.x + prevFrame.width
        currentAttributes.frame.origin.x = prevItemTailX + minimumInteritemSpacing(at: indexPath.section)
        print("💜💜 currentAttributes.frame.origin.x (2回目): \(currentAttributes.frame.origin.x)")
        print("\n")
        return currentAttributes
    }
}


//collectionViewのsectionInsetとminimumInteritemSpacingを必要とするので、
// VC内でUICollectionViewDelegateFlowLayout経由で取得
extension CollectionViewFlowLayoutLeftAlign {
    fileprivate func sectionInsets(at index: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return self.sectionInset
        }
        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: index) ?? self.sectionInset
    }
    
    fileprivate func minimumInteritemSpacing(at index: Int) -> CGFloat {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return self.minimumInteritemSpacing
        }
        return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: index) ?? self.minimumInteritemSpacing
    }
}
