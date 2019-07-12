//
//  CustomAnimation.swift
//  TextKitNotepad
//
//  Created by huoshuguang on 2016/11/21.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import AppKit

class CustomAnimation:NSViewController,NSAnimationDelegate
{
    //重写init?(coder: NSCoder)会导致IBOutlet属性为空
    @IBOutlet weak var firstView: NSView!
    @IBOutlet weak var secondView: NSView!
    var theViewAnim:NSViewAnimation!
    
    var theAnim:NSAnimation!
    var theOtherAnim:SmoothAnimation!
    
    /*
     想在构造器中使用self指定为其他协议的代理，必须先执行super.init
     注：重写init?(coder: NSCoder)会导致IBOutlet属性为空
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
     */
    override func viewDidLoad()
    {
        print("创建一个动画对象...")
        //NSAnimation:触发播放音乐
        theAnim = NSAnimation.init(duration: 10.0,
                                   animationCurve: .easeInOut)
        theAnim.frameRate = 200.0
        //用blocking模式：nonblockingThreaded 动画在主线程里以循环方式接受用户输入
        theAnim.animationBlockingMode = .nonblockingThreaded
        theAnim.delegate = self
        
        //SmoothAnimation:执行窗口从屏幕左->右平滑飘过的动画效果
        theOtherAnim = SmoothAnimation.init(duration: 20.0,
                                            animationCurve: .easeIn)
        theOtherAnim.delegate = self
        theOtherAnim.animationBlockingMode = .nonblockingThreaded //子线程动画
        
        //添加NSViewAnimation
        addViewAnimation()
    }
    /*
     awakeFromNib两次被调用：
        先执行：从Storyboard加载时被调用
        后执行：在执行重写构造器init?(coder: NSCoder)后被调用
     注：重写init?(coder: NSCoder)会导致IBOutlet属性为空
     */
    override func awakeFromNib() {
        print("---awakeFromNib---")
    }
    
    override func viewDidAppear()
    {
        //
        print("======viewDidAppear======")
        let count = 20
        let progMarks:[NSAnimationProgress] = [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5,0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0]
        for i in 0..<count {
            //
            print("\(progMarks[i])")
            //兵马未动粮草先行，上满堂子弹，在执行动画开始，全部突突突出节奏感
            theAnim.addProgressMark(progMarks[i])
            //重载currentProgress之后的动画进度无效
            theOtherAnim.addProgressMark(progMarks[i])
            //想通过animation(animation:didReachProgressMark:)执行其他相关动画进度的操作，必须确保有该步骤，否则进度代理不会执行
            theViewAnim.addProgressMark(progMarks[i])
        }
    }
    
    @IBAction func ibaStartAnim(_ sender: Any)
    {
        print("启动复合动画：\(theAnim.currentProgress)")
        //
      /*MARK: 创建复合动画组
         注：视图动画无法作为的联动动画中第二动画，即以下代码中视图动画永远无法被执行：
                 theAnim.start()
                 theViewAnim.start(when: theAnim, reachesProgress: 0.3)
         但是，视图动画可以作为联动动画中的导火索动画，触发NSAnimation动画的开始：
                即：只能作为导索动画，来创建复合动画
                 theViewAnim.start()
                 theAnim.start(when: theViewAnim, reachesProgress: 0.5)
         还有，NSAnimation子类重载动画的计算属性currentProgress时：无法作为导索动画，即无法触发第二动画的开始。
                即:只能作为被导索的动画，来创建复合动画
                theOtherAnim.start(when: theViewAnim, reachesProgress: 0.5)
         */
        theViewAnim.start()
        theAnim.start(when: theViewAnim, reachesProgress: 0.5)
        theOtherAnim.start(when: theViewAnim, reachesProgress: 0.5)
    }

    @IBAction func ibaStopAnim(_ sender: Any)
    {
        theAnim.stop()
    }
    /*
        MARK: - NSViewAnimation动画，
      */
    func addViewAnimation()
    {
        let firstViewFrame = firstView.frame
        //动画结束位置
        var newViewFrame = firstViewFrame
        newViewFrame.origin.x = newViewFrame.origin.x + 50
        newViewFrame.origin.y = newViewFrame.origin.y + 50
        //指定要修改的视图
        let firstViewDict = [NSViewAnimationTargetKey:firstView,
                          NSViewAnimationStartFrameKey:NSValue.init(rect: firstViewFrame),
                           NSViewAnimationEndFrameKey:NSValue.init(rect: newViewFrame)
        ]
        
        //
        var viewZeroSize = secondView.frame
        viewZeroSize.size.width = 0.0
        viewZeroSize.size.height = 0.0
        let secondViewDict:[String:Any] = [NSViewAnimationTargetKey:secondView,  //将目标对象设置为第二视图
                                      NSViewAnimationEndFrameKey:NSValue.init(rect: viewZeroSize),  //将视图从当前的大小缩小到没有
                                        NSViewAnimationEffectKey:NSViewAnimationFadeOutEffect  //设置淡出特效
            
        ]
        
        theViewAnim = NSViewAnimation.init(viewAnimations: [firstViewDict,secondViewDict])
        theViewAnim.duration = 10
//        theViewAnim.animationBlockingMode = .nonblockingThreaded
        theViewAnim.animationCurve = .easeIn
        theViewAnim.delegate = self
//                theViewAnim.start()
    }
    
    /*MARK: 动画代理
     addProgressMark(1.0)方法：当mar有变动就会触发通知协议，
     当NSAnimation子类 SmoothAnimation重写了currentProgress计算属性，该协议会失效不被执行
     */
    func animation(_ animation: NSAnimation, didReachProgressMark progress: NSAnimationProgress)
    {
        if animation == theAnim
        {
            //progress是耗损弹药的量，可据此更新UI状态进度等
            print("播放音乐动画：\(progress)")
            NSSound.init(named: "ddd.mp3")?.play()
            
        }
        else if animation == theOtherAnim
        {
            //移动动画
            print("屏幕上移动动画1111：\(progress)")
        }
        else if animation == theViewAnim
        {
            print("视图动画进度：\(progress)")
        }
    }

}

class SmoothAnimation:NSAnimation
{
    override init(duration: TimeInterval, animationCurve: NSAnimationCurve)
    {
        super.init(duration: duration, animationCurve: animationCurve)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var currentProgress: NSAnimationProgress
    {
        set(newValue){
            print("屏幕上移动动画:\(newValue)")
            var theWinFrame = NSApp.mainWindow?.frame
            let theScreenFrame = NSScreen.main()?.visibleFrame
            theWinFrame?.origin.x = CGFloat(newValue * Float(theScreenFrame!.size.width - theWinFrame!.size.width))
            NSApp.mainWindow?.setFrame(theWinFrame!, display: true, animate: true)
        }
        get{
            print("--currentProgress = 永远0.0---")
            //范围在0.0 ~ 1.0(<=1.0时)，以返回值为起始值：0.0
            return 0.0
        }
    }
    
    /*
     在运行动画之前，动画对象会发送给自己一个runloopmodesforanimation消息，来获取当前有效的运行循环模式：
        1. defaultRunLoopMode:
        2. modalPanelRunLoopMode:模态面板循环模式
        3. eventTrackingRunLoopMode:事件跟踪循环模式
     */
    override var runLoopModesForAnimating:[RunLoopMode]?
    {
        return [RunLoopMode.defaultRunLoopMode,RunLoopMode.modalPanelRunLoopMode,RunLoopMode.eventTrackingRunLoopMode]
    }
}
