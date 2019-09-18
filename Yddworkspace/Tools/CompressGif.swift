//
//  CompressGif.swift
//  Yddworkspace
//
//  Created by ydd on 2019/8/8.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation
import CoreGraphics
import MobileCoreServices

extension UIImage {
    
    static func scalGIFWithData(gitData data:Data, scalSize size:CGSize) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        let fileProperties = filePropertieFor(loopCount: 0)
        let tmpFile = tmpPath()
        let fileUrl = URL.init(fileURLWithPath: tmpFile) as CFURL
        guard let destination = CGImageDestinationCreateWithURL(fileUrl, kUTTypeGIF, count, nil) else { return nil }
        var duration:TimeInterval = 0.0
        for i in 0..<count {
            let imageRef = CGImageSourceCreateImageAtIndex(source, i, nil)
            if imageRef == nil {
                continue
            }
            let image = UIImage(cgImage: imageRef!)
            let scallImage = image.scaleImageToSize(size)
            let delayTime = frameDurationAt(index: i, source: source)
            duration += delayTime
            let framePropert = frameProperties(delayTime: delayTime)
            let scallRef = scallImage.cgImage
            if scallRef == nil {
                continue
            }
            CGImageDestinationAddImage(destination, scallRef!, framePropert as CFDictionary)
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        if !CGImageDestinationFinalize(destination) {
            
            return nil
        }
        do {
            let result = try Data(contentsOf: URL.init(fileURLWithPath: tmpFile))
             return result
        } catch  {
            return nil
        }
    }
    
    static fileprivate func tmpPath() -> String {
        var file = NSTemporaryDirectory()
        file.append("source.gif")
        if FileManager.default.fileExists(atPath: file) {
            do {
                try? FileManager.default.removeItem(atPath: file)
            }
        }
        return file
    }
    
    static fileprivate func filePropertieFor(loopCount count:Int) -> Dictionary<String,Any> {
        return [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount: (count)]]
    }
    
    static fileprivate func frameProperties(delayTime: TimeInterval) -> Dictionary<String,Any> {
        return [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime : delayTime,
                                                          kCGImagePropertyColorModel:kCGImagePropertyColorModelRGB]]
    }
    
    fileprivate func scallImage(scallSize:CGSize) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        
        var scaleFactor = 0.0
        var scaledWidth = scallSize.width
        var scaledHeight = scallSize.height
        var thumbnailPoint = CGPoint.zero
        
        if (!self.size.equalTo(scallSize))
        {
            let widthFactor = scaledWidth / width
            let heightFactor = scaledHeight / height
            
            scaleFactor = Double(max(widthFactor, heightFactor));
            scaledWidth = width * CGFloat(scaleFactor);
            scaledHeight = height * CGFloat(scaleFactor);
            
            // center the image
            if (widthFactor > heightFactor)
            {
                thumbnailPoint.y = (scallSize.height - scaledHeight) * 0.5
            }
            else if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (scallSize.width - scaledWidth) * 0.5
            }
        }
        var rect = CGRect.zero
        rect.origin = thumbnailPoint
        rect.size = CGSize.init(width: scaledWidth, height: scaledWidth)
        UIGraphicsBeginImageContext(rect.size);
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return  image;
    }
    
    static fileprivate func frameDurationAt(index: Int, source: CGImageSource) -> TimeInterval {
        var frameDuration: TimeInterval = 0.1
        let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        var frameProperties = cfFrameProperties as? Dictionary<String,Any>
        
        var gifProperties = frameProperties?[kCGImagePropertyGIFDelayTime as String] as? Dictionary<String, Any>
        guard gifProperties != nil else {
            return frameDuration
        }
        let delayTimeUnclampedProp = gifProperties?[kCGImagePropertyGIFDelayTime as String]
        if delayTimeUnclampedProp != nil {
            frameDuration = delayTimeUnclampedProp as? TimeInterval ?? frameDuration
        } else {
            let delayTimeProp = gifProperties![kCGImagePropertyGIFDelayTime as String]
            if delayTimeProp != nil {
                frameDuration = delayTimeProp as? TimeInterval ?? frameDuration
            }
        }
        
        if (frameDuration < 0.011) {
            frameDuration = 0.1;
        }
        
        frameDuration += 0.1
        return frameDuration
    }
}

