//
//  NoteEditorViewController.swift
//  TextKitNotepad
//
//  Created by huoshuguang on 2016/11/20.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

class NoteEditorViewControllerOSX: NSViewController,NSTextViewDelegate {

    @IBOutlet weak var ibTextView:NSTextView!
    var textView:NSTextView!
    var textStorage:SyntaxHighlightTextStorage! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        ibTextView.isHidden = true
        // Do view setup here.
        let str = "Shopping List\r\r1. Cheese\r2. Biscuits\r3. Sausages\r4. IMPORTANT Cash for going out!\r5. -potatoes-\r6. A copy of iOS6 by tutorials\r7. A new iPhone\r8. A present for mum"
        let attrString = NSAttributedString(string: str,
                                        attributes: [NSFontAttributeName:NSFont(name: "Zapfino", size: 14.0)])
        textStorage = SyntaxHighlightTextStorage()
        textStorage.append(attrString)
        //成功运行，但是在TextView上不显示文本内容，
        // textStorage.addLayoutManager(ibTextView.layoutManager!)
        
        /* ----- 根据以上原因：只能代码声明textView来实现   -------
            2. Create the layout manager
            3. Create a text container
            4. Create a UITextView
            5. 添加约束
         */
        let newTextViewRect = ibTextView.bounds
        //文本容器的宽度会自动匹配视图的宽度，但是它的高度是无限高的——或者说无限接近于CGFloat.max，它的值可以是无限大。
        let container = NSTextContainer(size:CGSize.init(width: newTextViewRect.size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)    //布局管理器添加文本容器
        textStorage.addLayoutManager(layoutManager)  //样式存储器添加布局管理器
        textView = NSTextView.init(frame: newTextViewRect, textContainer: container)
        textView.delegate = self
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        // Add constraints.
        view.addConstraints([
            //顶
            NSLayoutConstraint(item: textView,
                          attribute: .top,
                          relatedBy: .equal,
                             toItem: view,
                          attribute: .top,
                         multiplier: 1,
                           constant: 0),
            //右
            NSLayoutConstraint(item: textView,
                          attribute: .right,
                          relatedBy: .equal,
                             toItem: view,
                          attribute: .right,
                         multiplier: 1,
                           constant: 0),
            //底
            NSLayoutConstraint(item: textView,
                          attribute: .bottom,
                          relatedBy: .equal,
                             toItem: view,
                          attribute: .bottom,
                         multiplier: 1,
                           constant: 0),
            //左
            NSLayoutConstraint(item: textView,
                          attribute: .left,
                          relatedBy: .equal,
                             toItem: view,
                          attribute: .left,
                         multiplier: 1,
                           constant: 0)
            ])
    }
    
    override func viewDidLayout()
    {
        //viewDidLayoutSubviews
//        textStorage.update()
    }
}
