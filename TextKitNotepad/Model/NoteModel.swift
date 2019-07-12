//
//  NoteModel.swift
//  TextKitNotepad
//
//  Created by pengyucheng on 16/5/4.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation

class NoteModel{

    var contents:String
    var timetamp:NSDate
    
    init(_ newText:String)
    {
        contents = newText
        timetamp = NSDate()
    }
    //在get时，返回第一行内容
    var title:String
    {
        let lines = contents.components(separatedBy: NSCharacterSet.newlines)
        return lines[0]
    }
}
