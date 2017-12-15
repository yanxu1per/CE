//
//  ViewController.swift
//  CE
//
//  Created by Xu Yan on 12/2/17.
//  Copyright © 2017 Xu Yan. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import Firebase

class ViewController: UIViewController {
    
        var tap = false
        var audioRecorder:AVAudioRecorder!
        var audioPlayer:AVAudioPlayer!
        
       
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44.0)),//声音采样率
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),//编码格式
            AVNumberOfChannelsKey : NSNumber(value: 1),//采集音轨
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//音频质量
        
    override func viewDidLoad() {
            super.viewDidLoad()
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioRecorder = AVAudioRecorder(url: self.directoryURL()! as URL,
                                                    settings: recordSettings)//初始化实例
                audioRecorder.prepareToRecord()//准备录音
            } catch {
            }
        }
        
        func directoryURL() -> NSURL? {
            //定义并构建一个url来保存音频，音频文件名为ddMMyyyyHHmmss.caf
            //根据时间来设置存储文件名
            let currentDateTime = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyyHHmmss"
            let recordingName = formatter.string(from: currentDateTime as Date)+".caf"
            print(recordingName)
            
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = urls[0] as NSURL
            let soundURL = documentDirectory.appendingPathComponent(recordingName)
            return soundURL as? NSURL
        }
    func process(voice: ArraySlice<Float>) -> Float{
        var energy=0.0
        for item in voice{
            energy += item*item
        }
        energy /= Double(voice.count)
        return Float(energy)
    }
    
    @IBOutlet weak var Button1: UIBarButtonItem!
   
    @IBOutlet weak var Word: UILabel!
    //@IBOutlet weak var l1: UILabel!
   
   
    @IBOutlet weak var w3: UIImageView!
    
    @IBOutlet weak var w1: UIImageView!
    
    @IBOutlet weak var w2: UIImageView!
    
    @IBAction func startRecord(sender: AnyObject) {
            //开始录音
        if Button1.title=="RECORD"{
            if !audioRecorder.isRecording {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    Button1.title="STOP"
                    try audioSession.setActive(true)
                    audioRecorder.record()
                    print("record!")
                   
                } catch {
                }
            }
        }
        else{
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            
            //l1.text="The wave above is standard and yours is below, you should stress the second syllable"
            do {
                
                w1.image=UIImage(named:"w1")
                w2.image=UIImage(named:"w2")
                w3.image=UIImage(named:"w3")
                Button1.title="RECORD"
                try audioSession.setActive(false)
                print("stop!!")
                do {
                    let audioFile = try AKAudioFile(forReading: audioRecorder.url)
                   
                    let path = "/Users/yan/Documents/test.txt"
                    
                    // Set the contents
                    
                    //print(audioFile.floatChannelData)
                    var count1=0
                    var count2=0
                    var voice=[Float]()
                    for item in audioFile.floatChannelData![0]{
                        if abs(item) > Float(0.03){
                            count1+=1
                        }
                        
                        if count1>=100{
                            voice.append(item)
                            if abs(item) < Float(0.03){
                                count2+=1
                            }
                            if abs(item) > Float(0.03){
                                count2=0
                            }
                            if count2>60{
                                break
                            }
                            
                            
                        }
                    }
                    let contents = String(describing: voice)
                    
                    do {
                        // Write contents to file
                        try contents.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
                    }
                    catch let error as NSError {
                        print("Ooops! Something went wrong: \(error)")
                    }
                    let c=voice.count
                    let A=voice[0...Int(c/2)]
                    let B=voice[Int(c/2)+1...c-1]
                    let ea=process(voice: A)
                    let eb=process(voice: B)
                    if ea>eb{
                        print("success")
                    }
                } catch {
                   
                }
                
            } catch {
            }
        }
        }
    /*
        @IBAction func stopRecord(sender: AnyObject) {
            //停止录音
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
                print("stop!!")
            } catch {
            }
        }
 */
        
        // Do any additional setup after loading the view, typically from a nib.
    }






