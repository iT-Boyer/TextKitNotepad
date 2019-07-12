//
//  SyntaxHighlightTextStorage.swift
//  TextKitNotepad
//
//  Created by huoshuguang on 2016/11/20.
//  Copyright © 2016年 recomend. All rights reserved.
//
import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class SyntaxHighlightTextStorage: NSTextStorage
{
    //文本存储器子类必须提供它自己的“数据持久化层”。
    var backingStore = NSMutableAttributedString()
    var replacements = [String:Any]()
    
    override init() {
        super.init()
        createHighlightPatterns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    override var string: String
    {
        return backingStore.string
    }
}

//把任务代理给后台存储,调用beginEditing / edited / endEditing这些方法来完成一些编辑任务.
//这样做是为了在编辑发生后让文本存储器的类通知相关的布局管理器。
extension SyntaxHighlightTextStorage{
    
    //Sends out -textStorage:willProcessEditing, fixes the attributes, sends out -textStorage:didProcessEditing, and notifies the layout managers of change with the -processEditingForTextStorage:edited:range:changeInLength:invalidatedRange: method.  Invoked from -edited:range:changeInLength: or -endEditing.
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        if range == nil {
            return [:]
        }
        print("backingStore:location:\(location),effectiveRange:\(range!)")
        return backingStore.attributes(at: location, effectiveRange: range!)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String)
    {
        //
        print("replaceCharactersInRange:\(NSStringFromRange(range)) withString:\(str)")
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited([.editedAttributes,.editedCharacters],
               range: range,
               changeInLength: str.utf16.count - range.length)
        
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        //Sets the attributes for the characters in the specified range to the specified attributes.
        print("setAttributes:\(attrs!) range:\(NSStringFromRange(range))")
        beginEditing()
        backingStore.setAttributes(attrs!, range: range)
        edited(.editedAttributes,
               range: range,
               changeInLength: 0)
        
        endEditing()
    }
    
}

//动态格式（Dynamic formatting）:
//更新文本存储器的存储的文本样式，并通知布局管理器更新视图中的文本显示
extension SyntaxHighlightTextStorage{
    
    //将文本的变化通知给布局管理器。
    override func processEditing() {
        //更新文本存储器的存储的文本样式，editedRange：The range for pending changes
        performReplacementsForRange(editedRange)
        print("processEditing 通知布局管理器\(editedRange)")
        //通知布局管理器 notifies the layout managers of change
        super.processEditing()
    }
    
    //在指定的区域中进行替换
    func performReplacementsForRange(_ changedRange:NSRange){
        let locationRange = NSMakeRange(changedRange.location, 0)
        let range1 = (backingStore.string as NSString).lineRange(for: locationRange)
        //扩展范围
        var extendedRange = NSUnionRange(changedRange, range1)
        let maxRange = NSMakeRange(NSMaxRange(changedRange), 0)
        let range2 = (backingStore.string as NSString).lineRange(for: maxRange)
        extendedRange = NSUnionRange(changedRange, range2)
        print("在指定的区域中进行替换:\(extendedRange)")
        applyStylesToRange(searchRange: extendedRange)
    }
    
    func applyStylesToRange(searchRange:NSRange) {
        
        // 1. create some fonts
        #if os(iOS)
        let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        #elseif os(OSX)
        let font = NSFont.systemFont(ofSize:12.0)
        #endif
        
        let normalAttrs = [NSAttributedString.Key.font:font]
        // iterate over each replacement
        for regexStr in replacements.keys
        {
            // 2. match items surrounded by asterisks
            let regex:NSRegularExpression!
            do {
                //print("正则：\(regexStr)")
                regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            }
            catch
            {
                print("----")
                continue
            }
            
            //获取对应正则的字体样式
            let textAttributes:[NSAttributedString.Key:Any] = replacements[regexStr] as! [NSAttributedString.Key : Any]
            // 3. iterate over each match, making the text bold
            //使匹配到的所有字体样式生效
            regex!.enumerateMatches(in: backingStore.string, options: .init(rawValue: 0), range: searchRange)
            { (match, flags, stop) in
                // apply the style
                let matchRange = match?.range(at: 1)
                let replaceText = (backingStore.string as NSString).substring(with: matchRange!)
                print("更新样式的内容：\(replaceText)")
                //重载的方法
                self.addAttributes(textAttributes, range: matchRange!)
                // 4. reset the style to the original
                //将未匹配到的文本重置为“常规”样式。
                if (NSMaxRange(matchRange!)+1 < self.length)
                {
                    self.addAttributes(normalAttrs, range: NSMakeRange(NSMaxRange(matchRange!)+1, 1))
                }
            }
            
        }
    }
}

//为限定文本添加风格的基本原则很简单：
//使用正则表达式来寻找和替换限定字符，然后用applyStylesToRange来设置想要的文本样式即可。
extension SyntaxHighlightTextStorage{
    
    func createHighlightPatterns()  {
         //----字体描述器（Font descriptors）为每种匹配的字体添加新样式====
        //1. preferredFontDescriptor: 先获取文本原有样式
        //2. UIFont(descriptor:size:): 在文本原有样式基础上添加新样式，即不会影响字体大小等其他样式
        //3. [NSFontAttributeName:scriptFont]: create the attributes
        #if os(iOS)
            //
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body)
            
            //script风格的Zapfino字体
        let scriptFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family:"Zapfino"])
        let bodyFontSize = bodyFontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size]
        let scriptFont = UIFont(descriptor: scriptFontDescriptor,
                                          size: CGFloat(((bodyFontSize as AnyObject).floatValue)!))
        let scriptAttributes = [NSAttributedString.Key.font:scriptFont]
            
            //加粗
        let descriptorWithTraintBold = bodyFontDescriptor.withSymbolicTraits(.traitBold)
        //size值为0，会迫使UIFont返回用户设置的字体大小。
        let fontBold = UIFont.init(descriptor: descriptorWithTraintBold!, size: 0.0)
        let boldAttributes = [NSAttributedString.Key.font:fontBold]
            
        //斜体
        let descriptorWithTraintItalic = bodyFontDescriptor.withSymbolicTraits(.traitItalic)
        let fontItalic = UIFont.init(descriptor: descriptorWithTraintItalic!, size: 0.0)
        let italicAttributes = [NSAttributedString.Key.font:fontItalic]
            
        //删除线：NSStrikethroughStyleAttributeName
        let strikeThroughAttributes = [NSAttributedString.Key.strikethroughStyle:NSNumber.init(value: 1)]
        //字体颜色：NSForegroundColorAttributeName
        let redTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.red]
        #elseif os(OSX)
            //script风格的Zapfino字体
            let font = NSFont.init(name: "Zapfino", size: 14.0)
            let attrsDictionary = [NSFontAttributeName:font]
            let scriptFontDescriptor = NSFontDescriptor.init(fontAttributes: attrsDictionary)
            let scriptFont = NSFont.init(descriptor: scriptFontDescriptor,
                                         size: 0.0)
            let scriptAttributes = [NSFontAttributeName:scriptFont!]
            //粗体
            let descriptorWithTraintBold = scriptFontDescriptor.withSymbolicTraits(NSFontSymbolicTraits(NSFontBoldTrait))
            let fontBold = NSFont.init(descriptor: descriptorWithTraintBold, size: 0.0)
            let boldAttributes = [NSFontAttributeName:fontBold!]
            
            //斜体
            let descriptorWithTraintItalic = scriptFontDescriptor.withSymbolicTraits(NSFontSymbolicTraits(NSFontItalicTrait))
            let fontItalic = NSFont(descriptor: descriptorWithTraintItalic, size: 0.0)
            let italicAttributes = [NSFontAttributeName:fontItalic!]
            
            //删除线：NSStrikethroughStyleAttributeName
            let strikeThroughAttributes = [NSStrikethroughStyleAttributeName:NSNumber.init(value: 1)]
            //字体颜色：NSForegroundColorAttributeName
            let redTextAttributes = [NSForegroundColorAttributeName:NSColor.red]
            
        #endif
        //---- ------------
        // construct a dictionary of replacements based on regexes
        //创建一个NSDictionary并将正则表达式映射到上面声明的属性上
        replacements = [
            "(\\*\\w+(\\s\\w+)*\\*)\\s" : boldAttributes,
            "(_\\w+(\\s\\w+)*_)\\s" : italicAttributes,          //下划线(_)之间的文本变为斜体
            "([0-9]+.)\\s" : boldAttributes,
            "(-\\w+(\\s\\w+)*-)\\s" : strikeThroughAttributes,  //破折号(-)之间的文本添加删除线
            "(~\\w+(sw+)*~)\\s" : scriptAttributes,         //波浪线(~)之间的文本变为艺术字体
            "\\s([A-Z]{2,})\\s" : redTextAttributes]        //字母全部大写的单词变为红色
    }
}

//重做动态样式
//更新和各种正则表达式相匹配的字体,为整个文本字符串添加正文的字体样式,然后重新添加高亮样式。
extension SyntaxHighlightTextStorage{
    
    // update the highlight patterns
    func update() {
        // update the highlight patterns
        createHighlightPatterns()
        
        // change the 'global' font
        #if os(iOS)
        let bodyAttr = [NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        #elseif os(OSX)
            let bodyAttr = [NSFontAttributeName:NSFont(name: "Zapfino", size: 14.0)]
        #endif
        
        addAttributes(bodyAttr, range: NSMakeRange(0, length))
        // re-apply the regex matches
        applyStylesToRange(searchRange: NSMakeRange(0,length))
    }
}
