import Foundation

import UIKit



public class TimeIndicatorView: UIView {
    
    //Label
    private var timeLabel = UILabel()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public init(time:NSDate){

        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        clipsToBounds = false
        
        timeLabel.textAlignment = .center
        
        timeLabel.textColor = UIColor.white
        // format and style the date
        timeLabel.text = time.timeFormatBy(format: "dd\rMMMM\ryyyy")
        timeLabel.numberOfLines = 0
        timeLabel.sizeToFit()
        
        addSubview(timeLabel)
    }

    public func updateSize() {
        //
        // size the label based on the font
        timeLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        timeLabel.frame = CGRect.init(x: 0,
                                      y: 0,
                                  width: CGFloat.greatestFiniteMagnitude,
                                 height: CGFloat.greatestFiniteMagnitude)
        //Make(0, 0, CGFloat.max, CGFloat.greatestFiniteMagnitude)
        timeLabel.sizeToFit()
        
        // set the frame to be large enough to accomodate circle that surrounds the text
        let radius = radiusToSurroundFrame(frame: timeLabel.frame)
        frame = CGRect.init(x: 0,
                            y: 0,
                        width: radius * 2,
                       height: radius * 2)
        
        // center the label within this circle
        timeLabel.center = center

        //右上角半遮掩5.0效果
        //目前view坐标系统统已经包含状态栏的高度，所以 center.y + 80
         let padding : CGFloat = 5.0
        center = CGPoint.init(x: center.x + timeLabel.frame.origin.x - padding,
                              y: (center.y + 80) - timeLabel.frame.origin.y + padding)
    }
    
    // calculates the radius of the circle that surrounds the label
    func radiusToSurroundFrame(frame:CGRect) -> CGFloat {
        //半径
        return max(frame.size.width, frame.size.height) * 0.5 + 25.0
    }
    
    func curvePathWithOrigin(origin:CGPoint)->UIBezierPath{
    
        //画弧形
        let path = UIBezierPath.init(arcCenter: origin,
                                     radius: radiusToSurroundFrame(frame: timeLabel.frame),
                                     startAngle: -180,                 //-180.0
                                     endAngle: 180.0,//CGFloat(M_PI * 2),   //180.0
                                     clockwise: true)
//        UIColor.blueColor().set()
//        path.fill()
//        UIColor.blueColor().set()
        return path
    }

    
    public override func draw(_ rect: CGRect) {
        
        //Returns the current graphics context.
        let ctx = UIGraphicsGetCurrentContext()
////        Sets anti-aliasing on or off for a graphics context.
////        Anti-aliasing is a graphics state parameter.
        ctx!.setShouldAntialias(true)
        let path = curvePathWithOrigin(origin: timeLabel.center)
        //填充色
        UIColor.init(red: 0.329, green: 0.584, blue: 0.88, alpha: 1.0).setFill()
        path.fill()
        
        //画笔色
//        path.lineWidth = 1.5
//        UIColor.redColor().set()
//        path.stroke()
    }
}

extension NSDate{

    func timeFormatBy(format:String) -> String {
        //
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = format
        let formattedDate = timeFormat.string(from: self as Date)
        return formattedDate.uppercased()
    }
}
