//
//  ViewController.swift
//  Twittermenti
//
//  Created by Kejvi Peti
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "YOUR_KEY_GOES_HERE", consumerSecret: "YOUR_SECRET_GOES_HERE")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    func fetchTweets(){
        
        if let searchText = textField.text{
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended ) { results, metadata in
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0 ..< self.tweetCount {
                    
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
                
                
            } failure: { error in
                print(error)
            }
            
        }
    }
    
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
        do {
            let sentimentClassifier = try TweetSentimentClassifier(configuration: .init())
            
            let predictions = try sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                
                if pred.label == "Pos"{
                    sentimentScore += 1
                }else if pred.label == "Neg"{
                    sentimentScore -= 1
                }
                updateUI(with: sentimentScore)
            }
            
        }catch{
            print(error)
        }
    }
    
    
    func updateUI(with sentimentScore: Int){
        
        switch sentimentScore{
        case _ where sentimentScore > 20 :
            self.sentimentLabel.text = "😍"
            self.backgroundView.backgroundColor = UIColor.systemGreen
        case  _ where sentimentScore > 10 :
            self.sentimentLabel.text = "😄"
            self.backgroundView.backgroundColor = UIColor.systemGreen
        case  _ where sentimentScore > 0 :
            self.sentimentLabel.text = "🙂"
            self.backgroundView.backgroundColor = UIColor.yellow
        case  _ where sentimentScore == 0 :
            self.sentimentLabel.text = "😐"
            self.backgroundView.backgroundColor = UIColor.lightGray
        case  _ where sentimentScore > -10 :
            self.sentimentLabel.text = "😕"
            self.backgroundView.backgroundColor = UIColor.lightGray
        case  _ where sentimentScore > -20 :
            self.sentimentLabel.text = "😡"
            self.backgroundView.backgroundColor = UIColor.systemPink
        default :
            self.sentimentLabel.text = "🤬"
            self.backgroundView.backgroundColor = UIColor.systemPink
            
        }
        
    }
    
}



