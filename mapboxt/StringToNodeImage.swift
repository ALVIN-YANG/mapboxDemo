//
//  String+width.swift
//  mjttSwift
//
//  Created by KON on 2017/4/20.
//  Copyright © 2017年 美景听听. All rights reserved.
//

import UIKit

extension String {
    //获取部分字符串，如果不在范围内，返回nil.如果end大于字符串长度，那么截取到最后
    func subString(start: Int, offset: Int) -> String? {
        guard start >= 0, offset < self.count else {
            return nil
        }
        guard start >= 0, start + offset < self.count else {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: offset)
        return String.init(self[startIndex..<endIndex])
    }
    
    //获取某个字符，如果不在范围内，返回nil
    func dropCharacter(index: Int) -> Character? {
        if index > self.count - 1 || index < 0 {
            return nil
        }
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension String {
    func singleLineWidth(fontSize: CGFloat, height: CGFloat = 16) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    func singleLineWidth(font: UIFont, height: CGFloat = 16) -> CGFloat {
        
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    func heightForWidth(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
}


extension String {
    
    
    
    func toMapPinImage(isSelected: Bool, isBlue: Bool) -> UIImage {
        
        var backgroundImage = UIImage(named: "未选中位置蓝")!
        var backgroundSelectImage = UIImage(named: "选中位置蓝")!
        
        var triangleSelectImage = UIImage(named: "Triangleblue选中")!
        var triangleImage = UIImage(named: "Triangle_blue")!
        // 这个注意
        if isBlue {
            backgroundSelectImage = UIImage(named: "选中位置红")!
            triangleSelectImage = UIImage(named: "Triangle选中")!
            
            backgroundImage = UIImage(named: "未选中位置")!
            triangleImage = UIImage(named: "Triangle")!
            
            
        }
        if isSelected {
            return totoMapPinImage(backImage:  backgroundSelectImage, font: 16, letft: 20, top: 15, triangle: triangleSelectImage, isSelect: true)
        }
        return totoMapPinImage(backImage:  backgroundImage, font: 12, letft: 20, top: 15, triangle: triangleImage)
        
    }
    
    
    func totoMapPinImage(backImage: UIImage,
                       font: CGFloat,
                       letft: CGFloat = 15,
                       top: CGFloat = 5,
                       triangle: UIImage = UIImage(named: "triangle")!,
                       isSelect: Bool = false) -> UIImage {
        var result: UIImage = UIImage()
        let backView = UIView()
        backView.isOpaque = false
        //    backView.backgroundColor = [UIColor clearColor];
        let label = UILabel()
        label.text = self
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: font)
        label.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
        
        let unselectedImage = backImage
        let height: CGFloat = unselectedImage.size.height
        let backImageView = UIImageView(image: unselectedImage.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), resizingMode: .stretch))
        backImageView.isUserInteractionEnabled = true
        backImageView.frame = CGRect(x: 0, y: 0, width: label.bounds.size.width + letft, height: height + top)
        label.center = CGPoint(x: backImageView.center.x, y: backImageView.center.y)
        backImageView.addSubview(label)
        
        let triangleImageView = UIImageView(image: triangle)
        backView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(backImageView.bounds.size.width), height: CGFloat(backImageView.bounds.size.height + triangleImageView.bounds.size.height))
        backView.addSubview(backImageView)
        backView.addSubview(triangleImageView)
        triangleImageView.center = backImageView.center
        
        let y = CGFloat(backImageView.frame.origin.y + backImageView.frame.size.height)
        let w = CGFloat(triangleImageView.frame.size.width)
        let h = CGFloat(triangleImageView.frame.size.height)
        if isSelect {
            triangleImageView.frame = CGRect(x: triangleImageView.frame.origin.x, y: y - 4.59, width: w, height: h * 1.3)
        }else {
            triangleImageView.frame = CGRect(x: triangleImageView.frame.origin.x, y: y, width: w, height: h)
        }
        UIGraphicsBeginImageContextWithOptions(backView.bounds.size, backView.isOpaque, 0.0)
        
        backView.layer.render(in: UIGraphicsGetCurrentContext()!)
        // Fetch an UIImage of our "canvas".
        result = UIGraphicsGetImageFromCurrentImageContext()!
        // Stop the "canvas" from accepting any input.
        UIGraphicsEndImageContext()
        return result
    }
    
    func toCenterRoundImage() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let path = UIBezierPath.init(ovalIn: CGRect(x: 0, y: 0, width: 100, height: 100))
        // 超过绘制区域的都裁剪掉
        path.addClip()
        
        //填充背景颜色
        currentContext.setFillColor(UIColor.red.cgColor)
        currentContext.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let label = UILabel()
        label.text = self
        label.frame.size = CGSize(width: 70, height: 70)
        label.center = CGPoint(x: 50, y: 50)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        if #available(iOS 10.0, *) {
            label.font = UIFont.systemFont(ofSize: 20)
            label.adjustsFontForContentSizeCategory = true
        } else {
            label.font = UIFont.systemFont(ofSize: 16)
        }
        label.drawText(in: CGRect(x: 15, y: 15, width: 70, height: 70))
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
