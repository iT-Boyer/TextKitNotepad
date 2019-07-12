//
//  DownloadFont.swift
//  TextKitNotepad
//
//  Created by huoshuguang on 2016/11/20.
//  Copyright © 2016年 recomend. All rights reserved.
//

import UIKit
import CoreText

class DownloadFontViewController:UIViewController
{
    
    let fontNames = ["AdobeSongStd-Light",
                     "DFKaiShu-SB-Estd-BF",
                     "FZLTXHK--GBK1-0",
                     "STLibian-SC-Regular",
                     "LiHeiPro",
                     "HiraginoSansGB-W3"]
    
    let fontSamples = ["汉体书写信息技术标准相",
                       "容档案下载使用界面简单",
                       "支援服务升级资讯专业制",
                       "作创意空间快速无线上网",
                       "兙兛兞兝兡兣嗧瓩糎",
                       "㈠㈡㈢㈣㈤㈥㈦㈧㈨㈩"]
    
    @IBOutlet weak var fActivityIndicatorView:UIActivityIndicatorView!
    @IBOutlet weak var fProgressView:UIProgressView!
    @IBOutlet weak var fTextView:UITextView!
    var errorDuringDownload:Bool = false
    var errorMessage = ""
    
    override func viewDidLoad() {
        //
        
    }
    @IBAction func ibaFontOne(_ sender: Any)
    {
        asynchronouslySetFontName(fontName: fontNames[1])
    }
    
    @IBAction func ibaFontTwo(_ sender: Any) {
        asynchronouslySetFontName(fontName: fontNames[4])
    }
    
    @IBAction func ibaFontThree(_ sender: Any) {
        asynchronouslySetFontName(fontName: fontNames[5])
    }
    
    
    func asynchronouslySetFontName(fontName:String)
    {
        //
        let aFont = UIFont.init(name: fontName, size: 12.0)
        
        // If the font is already downloaded
        if aFont != nil
            &&
            aFont?.familyName.compare(fontName) == .orderedSame
            ||
            aFont?.fontName.compare(fontName) == .orderedSame
        {
            // Go ahead and display the sample text.
            let sampleIndex = fontNames.index(of: fontName)
            self.fTextView.text = fontSamples[sampleIndex!]
            self.fTextView.font = UIFont.init(name: fontName, size: 24.0)
            return;
        }

        print("attempting to download font")
        let desc = UIFontDescriptor(name: fontName, size: 24.0)
        
        
        // Start processing the font descriptor..
        // This function returns immediately, but can potentially take long time to process.
        // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
        // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler([desc]as CFArray, nil){
             (state:CTFontDescriptorMatchingState, progressParameter:CFDictionary!) -> Bool in
            //NSLog( @"state %d - %@", state, progressParameter);
            var progressValue:NSNumber = 0.0
            let d = progressParameter as NSDictionary
            let key = kCTFontDescriptorMatchingPercentage
            let cur : Any? = d.object(forKey: key as NSString)
            if let cur = cur as? NSNumber {
                progressValue = cur
            }
            
            if (state == .didBegin)
            {
                DispatchQueue.main.async {
                    // Show an activity indicator
                    self.fActivityIndicatorView.startAnimating()
                    self.fActivityIndicatorView.isHidden = false
                    
                    // Show something in the text view to indicate that we are downloading
                    self.fTextView.text = "Downloading:\(fontName)"
                    self.fTextView.font = UIFont.systemFont(ofSize: 14.0)
                    NSLog("Begin Matching")
                }
            }
            else if (state == .didFinish)
            {
                DispatchQueue.main.async {
                    // Remove the activity indicator
                    self.fActivityIndicatorView.stopAnimating()
                    self.fActivityIndicatorView.isHidden = true
                    
                    // Display the sample text for the newly downloaded font
                    let sampleIndex = self.fontNames.index(of: fontName)
                    self.fTextView.text = self.fontSamples[sampleIndex!]
                    self.fTextView.font = UIFont.init(name: fontName, size: 24.0)
                    
                    // Log the font URL in the console
                    let fontRef = CTFontCreateWithName(fontName as CFString, 0.0, nil)
                    let fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute)
                    NSLog("字体路径：\n\((fontURL as! NSURL))");
                    
                    if (!self.errorDuringDownload)
                    {
                        NSLog("\(fontName) downloaded")
                    }
                }
            }
            else if (state == .willBeginDownloading)
            {
                DispatchQueue.main.async{
                    // Show a progress bar
                    self.fProgressView.progress = 0.0
                    self.fProgressView.isHidden = false
                    NSLog("Begin Downloading")
                    }
            }
            else if (state == .didFinishDownloading)
            {
                DispatchQueue.main.async{
                    // Remove the progress bar
                    self.fProgressView.isHidden = true
                    NSLog("Finish downloading")
                }

            }
            else if (state == .downloading)
            {
                DispatchQueue.main.async{
                    // Use the progress bar to indicate the progress of the downloading
                    self.fProgressView.setProgress(progressValue.floatValue/100.0, animated: true)
                    NSLog("Downloading \(progressValue) complete")
                }
//                dispatch_async( dispatch_get_main_queue(), ^ {});
            }
            else if (state == .didFailWithError)
            {
                // An error has occurred.
                // Get the error message
                let error:NSError = (progressParameter as NSDictionary).object(forKey: kCTFontDescriptorMatchingError) as! NSError
                
                if (error != nil) {
                    self.errorMessage = error.description
                } else {
                    self.errorMessage = "ERROR MESSAGE IS NOT AVAILABLE!"
                }
                // Set our flag
                self.errorDuringDownload = true
                DispatchQueue.main.async{
                    self.fProgressView.isHidden = true
                    NSLog("Download error: \(self.errorMessage)")
                }
            }
            return true
        }
        
    }
}
