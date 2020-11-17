//
//  DDPlainFlowLayout.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/17.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

enum CollectionHeaderStyle {
    case plain
    case grouped
}

class DDPlainFlowLayout: UICollectionViewFlowLayout {
    var c_navHeight: CGFloat = 64
    var c_headStyle: CollectionHeaderStyle = .grouped
    var c_columnMargin:CGFloat = 10
    var c_rowMargin:CGFloat = 10
    var c_cusSectionInset  = UIEdgeInsets.zero
    var c_headerInset = UIEdgeInsets.zero
    var c_footerInset = UIEdgeInsets.zero
    var c_columnCount:Int = 2
    var c_headerHeight:CGFloat = 0
    var c_footerHeight:CGFloat = 0
    var c_allAttrsArr = Array<UICollectionViewLayoutAttributes>()
    var c_itemAttrsArr = Array<UICollectionViewLayoutAttributes>()
    var c_supplementAttrsArr = Array<Dictionary<String,UICollectionViewLayoutAttributes>>()
    var c_contentHeight:CGFloat = 0
    weak var c_flowLayoutDelegate: DDFlowLayoutProtocol?
    
    override func prepare() {
        super.prepare()
        
        // 每次刷新前先清除数据
        c_contentHeight = 0
        c_allAttrsArr.removeAll()
        c_itemAttrsArr.removeAll()
        c_supplementAttrsArr.removeAll()
        
        if self.collectionView == nil {
            return
        }
        
        let sessionCount = self.collectionView?.numberOfSections ?? 0
        if sessionCount == 0 {
            return
        }
        
        for session in 0..<sessionCount {
            let headerHeight = self.getHeaderHeight(Section: session)
            let footerHeight = self.getFooterHeight(Section: session)
            let columnCount = self.getColumnNum(Section: session)
            let rowMargin = self.getRowMargin(Section: session)
            let columnMargin = self.getColumnMargin(Section: session)
            let sectionInset = self.getCellSectionInset(Section: session)
            let headerInset = self.getHeaderInset(Section: session)
            let fooderInset = self.getFooterInset(Section: session)
            
            // header布局
            var supplementaryDic = Dictionary<String,UICollectionViewLayoutAttributes>.init()
            
            if headerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with:IndexPath.init(item: 0, section: session))
                attributes.frame = CGRect(x: headerInset.left, y: self.c_contentHeight + headerInset.top, width: self.collectionView?.frame.size.width ?? 0 - headerInset.left - headerInset.right, height: headerHeight)
                
                self.c_allAttrsArr.append(attributes)
                supplementaryDic[UICollectionView.elementKindSectionHeader] = attributes
                
                self.c_contentHeight = attributes.frame.maxY + headerInset.bottom + sectionInset.top
                
            } else {
                self.c_contentHeight += sectionInset.top
            }
        
            // cell布局
            var maxDic:[String:CGFloat] = NSMutableDictionary.init() as! [String : CGFloat]
            for i in 0..<columnCount {
                let column = String(i)
                maxDic[column] = self.c_contentHeight
            }
            
            let itemCount = self.collectionView?.numberOfItems(inSection: session) ?? 0
            for item in 0..<itemCount {
                let indexPath = NSIndexPath.init(item: item, section: session)
                // 假设当前y轴最小的那一列是第零列
                var minColumn = String(0);
                // 遍历字典取最小y轴
                for i in 0..<columnCount {
                    let column = String(i)
                    let valueFloat = maxDic[column] ?? 0
                    let minValue = maxDic[minColumn] ?? 0
                    if valueFloat <  minValue {
                        minColumn = column
                    }
                }
        
                // 计算每个item的布局属性
                let contentWidth = self.collectionView!.frame.size.width - sectionInset.left - sectionInset.right - columnMargin * CGFloat(columnCount - 1)
                let width = contentWidth / CGFloat(columnCount)
                var height = width
                if self.c_flowLayoutDelegate != nil {
                    height = self.c_flowLayoutDelegate!.dd_collectionCellHeight(collectionView: self.collectionView, layout: self, width: width, indexPath: indexPath)
                }
                let minValue = CGFloat(Int(minColumn) ?? 0)
                let x = sectionInset.left + (width +  columnMargin) * minValue
                let y = maxDic[minColumn] ?? 0
                
                // 1 更新这一列最大的y值
                maxDic[minColumn] = y + height + rowMargin
                
                let attr = UICollectionViewLayoutAttributes.init(forCellWith: indexPath as IndexPath)
                attr.frame = CGRect(x: x, y: y, width: width, height: height)
                
                // 2 把每一个item的布局属性添加到数据中
                self.c_itemAttrsArr.append(attr)
                self.c_allAttrsArr.append(attr)
            }
            // 取最大y值
            var maxColumn = "0"
            for (key,value) in maxDic {
                let maxValue = maxDic[maxColumn] ?? 0
                if value > maxValue {
                    maxColumn = key
                }
            }
            
            self.c_contentHeight = maxDic[maxColumn] ?? 0
            self.c_contentHeight += sectionInset.bottom - rowMargin
            
            
            // 尾部布局
            if (footerHeight > 0) {
                let attributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath.init(item: 0, section: session))
                attributes.frame = CGRect(x: fooderInset.left, y: self.c_contentHeight + fooderInset.top, width: self.collectionView!.frame.size.width - fooderInset.left - fooderInset.right, height: footerHeight)
                self.c_allAttrsArr.append(attributes)
                supplementaryDic[UICollectionView.elementKindSectionFooter] = attributes
                
                self.c_contentHeight = attributes.frame.maxY - fooderInset.bottom
            }
            self.c_supplementAttrsArr.append(supplementaryDic)
        }
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.collectionView == nil {
            return super.layoutAttributesForItem(at: indexPath)
        }
        var index = indexPath.item
        for i in 0..<indexPath.section {
            index += self.collectionView!.numberOfItems(inSection: i)
        }
        if self.c_itemAttrsArr.count > index {
            return self.c_itemAttrsArr[index]
        }
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.c_supplementAttrsArr.count > indexPath.section {
            return self.c_supplementAttrsArr[indexPath.section][elementKind]
        }
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if c_headStyle == CollectionHeaderStyle.plain {
            return self.collectionHeaderPlain(in: rect)
        } else {
            let attrs = self.c_allAttrsArr.filter {
                rect.intersects($0.frame)
            }
            return attrs
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            if self.collectionView == nil {
                return CGSize.zero
            }
            return CGSize(width: self.collectionView!.frame.size.width, height: self.c_contentHeight)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if c_headStyle == CollectionHeaderStyle.plain {
            return true
        }
        let oldBounds = self.collectionView?.bounds ?? CGRect.zero
        if newBounds.width != oldBounds.width {
            return true
        }
        return false
    }
    
    
    
//    private func column
    
    
    private func collectionHeaderPlain(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // UICollectionViewLayoutAttributes：称它为collectionView中的item（包括cell和header、footer这些）的《结构信息》
        
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        if let superAttributesArray = super.layoutAttributesForElements(in: rect) {
            attributesArray = superAttributesArray
        }
        // 创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
        let noneHeaderSections = NSMutableIndexSet()
        // 遍历superArray，得到一个当前屏幕中所有的section数组
        for attributes in attributesArray {
            // 如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
            if attributes.representedElementCategory == .cell {
                noneHeaderSections.add(attributes.indexPath.section)
            }
        }
        
        // 遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
        // 正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
        for attributes in attributesArray {
            if let kind = attributes.representedElementKind {
                //如果当前的元素是一个header，将header所在的section从数组中移除
                if kind == UICollectionView.elementKindSectionHeader {
                    noneHeaderSections.remove(attributes.indexPath.section)
                }
            }
        }
        
        // 遍历当前屏幕中没有header的section数组
        noneHeaderSections.enumerate { (index, stop) in
            // 取到当前section中第一个item的indexPath
            let indexPath = IndexPath.init(item: 0, section: index)
            // 获取当前section在正常情况下已经离开屏幕的header结构信息
            if let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                // 如果当前分区确实有因为离开屏幕而被系统回收的header，将该header结构信息重新加入到superArray中去
                attributesArray.append(attributes)
            }
        }
        // 遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
        for attributes in attributesArray {
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                let session = attributes.indexPath.section
                let firstItemIndexPath = IndexPath.init(item: 0, section: session)
                var numberOfItemsInSection = 0
                // 得到当前header所在分区的cell的数量
                if let number = self.collectionView?.numberOfItems(inSection: session) {
                    numberOfItemsInSection = number
                }
                // 得到最后一个item的indexPath
                let lastItemIndexPath = IndexPath.init(item: max(0, numberOfItemsInSection - 1), section: session)
                // 得到第一个item和最后一个item的结构信息
                let firstItemAttributes: UICollectionViewLayoutAttributes!
                let lastItemAttributes: UICollectionViewLayoutAttributes!
                if numberOfItemsInSection > 0 {
                    // cell有值，则获取第一个cell和最后一个cell的结构信息
                    firstItemAttributes = self.layoutAttributesForItem(at: firstItemIndexPath)
                    lastItemAttributes = self.layoutAttributesForItem(at: lastItemIndexPath)
                } else {
                    // cell没值,就新建一个UICollectionViewLayoutAttributes
                    firstItemAttributes = UICollectionViewLayoutAttributes()
                    // 然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                    let itemY = attributes.frame.maxY + self.sectionInset.top
                    firstItemAttributes.frame = CGRect(x: 0, y: itemY, width: 0, height: 0)
                    // 因为只有一个cell，所以最后一个cell等于第一个cell
                    lastItemAttributes = firstItemAttributes
                }
                
                // 获取当前header的frame
                var rect = attributes.frame
                // 当前的滑动距离 + 因为导航栏产生的偏移量，默认为64（如果app需求不同，需自己设置）
                var offset_Y: CGFloat = 0
                if let y = self.collectionView?.contentOffset.y {
                    offset_Y = y
                }
                offset_Y += c_navHeight
                
                // 第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
                let headerY = firstItemAttributes.frame.origin.y - rect.size.height - self.sectionInset.top
                // 哪个大取哪个，保证header悬停
                // 针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
                let maxY = max(offset_Y, headerY)
                
                // 最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
                // 当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
                let headerMissingY = lastItemAttributes.frame.maxY + self.sectionInset.bottom - rect.size.height
                // 给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
                rect.origin.y = min(maxY, headerMissingY)
                // 给header的结构信息的frame重新赋值
                attributes.frame = rect
                // 如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
                // 通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大
                attributes.zIndex = 1
                
                
            }
        }
        
        return attributesArray
    }
    
    
    
}

extension DDPlainFlowLayout {
    
    private func getColumnNum(Section section:Int) -> Int {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionColumnNum(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_columnCount
    }
    
    private func getHeaderHeight(Section section:Int) -> CGFloat {
        if (self.c_flowLayoutDelegate != nil) {
            return self.c_flowLayoutDelegate!.dd_collectionHeaderHeight(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_headerHeight
    }
    
    private func getFooterHeight(Section section:Int) -> CGFloat {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionfooterHeight(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_footerHeight
    }
    
    private func getColumnMargin(Section section:Int) -> CGFloat {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionColumnMargin(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_columnMargin
    }
    
    private func getRowMargin(Section section:Int) -> CGFloat {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionRowMargin(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_rowMargin
    }
    
    private func getCellSectionInset(Section section:Int) -> UIEdgeInsets {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionCellEdgeInsets(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_cusSectionInset
    }
    
    private func getHeaderInset(Section section:Int) -> UIEdgeInsets {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionHeaderEdgeInsets(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_headerInset
    }
    
    private func getFooterInset(Section section:Int) -> UIEdgeInsets {
        if self.c_flowLayoutDelegate != nil {
            return self.c_flowLayoutDelegate!.dd_collectionFooterEdgeInsets(collectionView: self.collectionView, layout: self, section: section)
        }
        return c_footerInset
    }
    
}
