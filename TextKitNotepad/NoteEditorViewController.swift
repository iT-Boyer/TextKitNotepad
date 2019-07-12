//
//  ViewController.swift
//  TextKitNotepad
//
//  Created by pengyucheng on 16/5/4.
//  Copyright © 2016年 recomend. All rights reserved.
//

//==================================================================
//TextKit

//四大控件：
/**
 *  @author shuguang, 16-05-08 17:05:47
 *
 *
 1. NSTextStorage: 以attributedString的方式存储所要处理的文本并且将文本内容的任何变化都通知给布局管理器。可以自定义NSTextStorage的子类，当文本发生变化时，动态地对文本属性做出相应改变。
 
 2. NSLayoutManager: 获取存储的文本并经过修饰处理再显示在屏幕上；在App中扮演着布局“引擎”的角色。
 
 3. NSTextContainer: 描述了所要处理的文本在屏幕上的位置信息。每一个文本容器都有一个关联的UITextView. 可以创建 NSTextContainer的子类来定义一个复杂的形状，然后在这个形状内处理文本。
 
 */
import UIKit

class NoteEditorViewController: UIViewController,UITextViewDelegate {
    //
    var timeIndicatorView:TimeIndicatorView!
    var textStorage:SyntaxHighlightTextStorage! = nil
    var textView:UITextView! = nil
    
    @IBOutlet weak var ibTextView: UITextView!
    
    
    var keyboardSize:CGSize!
    
    var note:NoteModel!
    
    override func viewDidLoad() {
        //
        //字体变化通知:调用preferredContentSizeChanged:方法
        NotificationCenter.default.addObserver(self, selector: #selector(NoteEditorViewController.preferredContentSizeChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        //编辑长文本的时候键盘挡住了下半部分文本的问题
        NotificationCenter.default.addObserver(self, selector: #selector(NoteEditorViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NoteEditorViewController.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        createTextView()
        //时间戳
        timeIndicatorView = TimeIndicatorView.init(time: note.timetamp)
        view.addSubview(timeIndicatorView)
    }
    
    //创建文本区域
    func createTextView()
    {
        // 1. Create the text storage that backs the editor
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        let attrs = [NSAttributedString.Key.font:bodyFont]
        let attrString = NSAttributedString(string: note.contents,attributes: attrs)
        textStorage = SyntaxHighlightTextStorage()
        textStorage.append(attrString)
    
        // --------使用Storyboard声明TextView时,只需一行----------
        textStorage.addLayoutManager(ibTextView.layoutManager)
    
        /**--------使用代码声明TextView时，4步骤----------
        let newTextViewRect = view.bounds
        
        // 2. Create the layout manager
        let layoutManager = NSLayoutManager()
        
        // 3. Create a text container
        //文本容器的宽度会自动匹配视图的宽度，但是它的高度是无限高的——或者说无限接近于CGFloat.max，它的值可以是无限大。
        let containerSize = CGSize.init(width: newTextViewRect.size.width,
                                        height: CGFloat.greatestFiniteMagnitude)
        
        let container = NSTextContainer.init(size: containerSize)
        //A Boolean that controls whether the receiver adjusts the width of its bounding rectangle when its text view is resized.
        container.widthTracksTextView = true
        //
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        // 4. Create a UITextView
        textView = UITextView()//.init(frame: newTextViewRect, textContainer: container)
        textView.isScrollEnabled = true
        textView.delegate = self
        view.addSubview(textView)
         */
    }
    
    //字体变化通知时调用
    @objc func preferredContentSizeChanged(_ notification:NSNotification)
    {
        //收到用于指定本类接收字体设定变化的通知后
        textStorage.update()
        timeIndicatorView.updateSize()
    }
    
    //视图的控件调用viewDidLayoutSubviews对子视图进行布局时，TimeIndicatorView作为子控件也需要有相应的变化。
    override func viewDidLayoutSubviews() {
        //
        updateTimeIndicatorFrame()
    }
    
    func updateTimeIndicatorFrame() {
        //第一调用updateSize来设定_timeView的尺寸。
        timeIndicatorView.updateSize()
        //通过偏移frame参数，将timeIndicatorView放在右上角。
        timeIndicatorView.frame = timeIndicatorView.frame.offsetBy(dx:ibTextView.frame.width - timeIndicatorView.frame.width, dy: 0.0)
        
        let exclusionPath = timeIndicatorView.curvePathWithOrigin(origin: timeIndicatorView.center)
        ibTextView.textContainer.exclusionPaths = [exclusionPath]
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        note.contents = ibTextView.text
    }
}

//键盘遮挡问题
extension NoteEditorViewController
{
    @objc func keyboardDidShow(_ notification:NSNotification) {
        //
        let userInfo = notification.userInfo
        keyboardSize = (userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        updateTextViewSize()
    }
    
    @objc func keyboardDidHide(_ notification:NSNotification) {
        //
        keyboardSize = CGSize(width: 0,height: 0)
        updateTextViewSize()
    }
    
    //键盘显示或隐藏时,缩小文本视图的高度以适应键盘的显示状态
    func updateTextViewSize() {
        //计算文本视图尺寸的时候你要考虑到屏幕的方向
        let orientation = UIApplication.shared.statusBarOrientation
        //因为屏幕方向变化后,UIView的宽高属性会对换,但是键盘的宽高属性却不会
        let keyboardHeight = orientation.isLandscape ? keyboardSize.width:keyboardSize.height
        
        ibTextView.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - keyboardHeight)
    }
}



