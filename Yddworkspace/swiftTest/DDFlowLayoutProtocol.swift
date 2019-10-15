//
//  DDFlowLayoutProtocol.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/10.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

protocol DDFlowLayoutProtocol : NSObjectProtocol {
    
    /** 返回列数 */
    func dd_collectionColumnNum(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> NSInteger
    /** 返回cell高 */
    func dd_collectionCellHeight(collectionView:UICollectionView?, layout:DDPlainFlowLayout, width:CGFloat, indexPath:NSIndexPath) -> CGFloat
    /** 返回header高 */
    func dd_collectionHeaderHeight(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat
    /** 返回footer高 */
    func dd_collectionfooterHeight(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat
    /** 返回行间距 */
    func dd_collectionRowMargin(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat
    /** 返回列间距 */
    func dd_collectionColumnMargin(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat
    
    /** 返回每个分区cell内容的边距 */
    func dd_collectionCellEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets
    
    /** 返回每个分区header内容的边距 */
    func dd_collectionHeaderEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets
    
    /** 返回每个分区footer内容的边距 */
    func dd_collectionFooterEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets
    
}

extension DDFlowLayoutProtocol {
    func dd_collectionHeaderHeight(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat {
        return 0
    }
    
    func dd_collectionfooterHeight(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat {
        return 0
    }
    
    func dd_collectionRowMargin(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat {
        return 0
    }
    
    func dd_collectionColumnMargin(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> CGFloat {
        return 0
    }
    
    /** 返回每个分区cell内容的边距 */
    func dd_collectionCellEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
       
    /** 返回每个分区header内容的边距 */
    func dd_collectionHeaderEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
       
    /** 返回每个分区footer内容的边距 */
    func dd_collectionFooterEdgeInsets(collectionView:UICollectionView?, layout:DDPlainFlowLayout, section:NSInteger) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}
