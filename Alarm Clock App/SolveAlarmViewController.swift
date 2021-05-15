//
//  SolveAlarmViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/28/21.
//

import UIKit
import Parse
/*TODO :
    - Make sure PEMDAS is followed when computing equations
    - Make a note that decimal numbers have to be rounded to the second decimal place for "Math Equations" (ex. 85.546 -> 85.55)
    - Apostrophes on sentences are still being weird, fix it
    - Add custom keyboard to allow for +/-, and commas
 */
class SolveAlarmViewController: UIViewController {
    
    
    
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    
    let puzzleType = "Scrambled Word Sentence" // Three options: "Math Equations" ,  "Scrambled Word Sentence", "Scrambled Letter Sentence"
    let difficultyLevel = "Easy" // Three options: "Easy" ,  "Normal", "Hard" ; difficulty level chosen by user ; should always start with capital letter
    var numberOfCorrectAnswers : Int = 0 //User must get 3 if difficulty = Easy ; 2 if difficulty = Normal ; 1 if difficulty = Hard
    var numOfSeconds : Double = 30
    let submitButtonColor = UIColor(rgb: 0x8D733E)
    var submitButtonClicked : Bool = false
    var newButtonClicked : Bool = false
    var successfulSolve : Bool = false
    
    //Math Equations
    var num1 : Int = 0
    var num2 : Int = 0
    var num3 : Int = 0
    var num4 : Int = 0
    var symbol1 : String = ""
    var symbol2 : String = ""
    var symbol3 : String = ""
    var randomOperandIndex : Int = 0
    var randomOperatorIndex : Int = 0
    let easyArithmeticDifficultyId = "8XTOzojIhh"
    let normalArithmeticDifficultyId = "AFBlskbw6f"
    let hardArithmeticDifficultyId = "l7Mz6YPDS0"
    
    //Sentences
    var sentence : String = ""
    var scrambledLetterSentence : String = ""
    var scrambledWordSentence : String = ""
    var numOfWords : Int = 0
    
    let layer0 = CAShapeLayer()
    let layer1 = CAShapeLayer()
    
    
    override func viewWillAppear(_ animated: Bool) {
        restartTimer()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.setTitleColor(submitButtonColor, for: .normal)
        submitButton.setTitle("Submit", for: .normal)
        
        if puzzleType == "Math Equations" {
            self.inputTextField.keyboardType = .decimalPad
        } else {
            //puzzleType == "Scrambled Word Sentence" or "Scrambled Letter Sentence"
            self.inputTextField.keyboardType = .alphabet
        }
        inputTextField.becomeFirstResponder()
        
        //if puzzleType selected is "Math Equations" then call makeMathQuery(), else call makeSentenceQuery()
        puzzleType == "Math Equations" ? makeMathQuery(diff: difficultyLevel) : makeSentenceQuery(diff: difficultyLevel)
    }
    
    @objc func restartTimer() {
        //----view did load
        //Lay down background stroke
        let shapeLayerTop = UIBezierPath()
        shapeLayerTop.move(to: CGPoint(x:(UIScreen.main.bounds.width)-20, y:60))
        shapeLayerTop.addLine(to: CGPoint(x: 10, y: 60))
        layer1.path = shapeLayerTop.cgPath
        let myColor : UIColor = UIColor(rgb: 0x8D733E)
        layer1.strokeColor = myColor.cgColor
        layer1.lineWidth = 8
        layer1.lineCap = CAShapeLayerLineCap.round
        layer1.strokeEnd = (UIScreen.main.bounds.width)-20
        self.view.layer.addSublayer(layer1)
        
        
        //------view will appear
        let shapeLayerBottom = UIBezierPath()
        shapeLayerBottom.move(to: CGPoint(x:(UIScreen.main.bounds.width)-20, y:60))
        shapeLayerBottom.addLine(to: CGPoint(x: 10, y: 60))
        layer0.path = shapeLayerBottom.cgPath
        layer0.strokeColor = UIColor.white.cgColor
        layer0.lineWidth = 8
        layer0.lineCap = CAShapeLayerLineCap.round
        layer0.strokeEnd = 0
        self.view.layer.addSublayer(layer0)
        
        if !successfulSolve {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 1
            basicAnimation.duration = numOfSeconds
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            basicAnimation.delegate = self
            layer0.add(basicAnimation, forKey: "randomString1")
            
            let basicAnimation0 = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation0.toValue = 1
            basicAnimation0.duration = 1
            basicAnimation0.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation0.isRemovedOnCompletion = false
            layer1.add(basicAnimation0, forKey: "randomString2")
        }
        
    }
    
    

    
    //*********************************************************************** Math Equations ************************************************************************
    
    /**
     This function returns a math equation based on the difficulty selected by the user.
      
     - parameter difficulty: difficulty selected by user, options are *Easy*, *Normal*, and *Hard*
     - returns: The math equation to be displayed
     
     # Notes: #
     1. Easy - Returns an equation with 2 operators (choices being +,-) and 1 operand (choices being 1...50)
     2.   Normal - Returns an equation with 3 operators (choices being +,-,*) and 2 operands (choices being 1...75)
     3.   Hard- Returns an equation with 4 operators (choices being +,-,*,/) and 3 operands (choices being 1...100)
    */
    func makeMathQuery(diff difficulty: String) {
        let difficultyId : String

        if difficulty == "Easy" {
            difficultyId = easyArithmeticDifficultyId
        } else if difficulty == "Normal" {
            difficultyId = normalArithmeticDifficultyId
        } else {
            //difficulty == "Hard"
            difficultyId = hardArithmeticDifficultyId
        }

        let query = PFQuery(className:"MathEquations")
        query.getObjectInBackground(withId: difficultyId) { (equation, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                //Success!
                let operands = equation?.object(forKey: "operands") as! [Int]
                let operators = equation?.object(forKey: "operators") as! [String]
                self.randomOperandIndex = Int.random(in: 0..<operands.count)
                self.num1 = operands[self.randomOperandIndex]
                self.randomOperandIndex = Int.random(in: 0..<operands.count)
                self.num2 = operands[self.randomOperandIndex]
                self.randomOperatorIndex = Int.random(in: 0..<operators.count)
                self.symbol1 = operators[self.randomOperatorIndex]

                self.displayLabel.text = "\(self.num1) \(self.symbol1) \(self.num2)"

                if (difficulty == "Normal") || (difficulty == "Hard") {
                    self.randomOperandIndex = Int.random(in: 0..<operands.count)
                    self.num3 = operands[self.randomOperandIndex]
                    self.randomOperatorIndex = Int.random(in: 0..<operators.count)
                    self.symbol2 = operators[self.randomOperatorIndex]

                    self.displayLabel.text = "\(self.num1) \(self.symbol1) \(self.num2) \(self.symbol2) \(self.num3)"
                }
                if difficulty == "Hard" {
                    self.randomOperandIndex = Int.random(in: 0..<operands.count)
                    self.num4 = operands[self.randomOperandIndex]
                    self.randomOperatorIndex = Int.random(in: 0..<operators.count)
                    self.symbol3 = operators[self.randomOperatorIndex]

                    self.displayLabel.text = "\(self.num1) \(self.symbol1) \(self.num2) \(self.symbol2) \(self.num3) \(self.symbol3) \(self.num4)"
                }

            }
        }
    }
    
    func compute(_ op1: Float,_ op2: Float,_ symbol : String) -> Float {
        switch symbol {
        case "+":
            return (op1 + op2)
        case "-":
            return (op1 - op2)
        case "*":
            return (op1 * op2)
        case "/":
            return (op1 / op2)
        default:
            return 1
        }
    }
    
    
    //*************************************************************************** Sentences ***************************************************************************
    
    
    /**
     This function returns a sentence based on the difficulty and puzzle type selected by the user.
      
     - parameter difficulty: difficulty selected by user, options are *Easy*, *Normal*, and *Hard*
     - returns: The sentence to be displayed in the puzzle type selected (Scrambled words or Scrambled letters)
     
     # Notes: #
     - Easy - Scrambled Words : Switches the placement of **2 words** in the sentence with eachother.
     - Easy - Scrambled Letters : Rearranges the letters of **1 word** in the sentence.
     - ---------------------------------------------------------------------------
     - Normal - Scrambled Words : Switches the placement of **4 words** in the sentence with eachother.
     - Normal - Scrambled Letters : Rearranges the letters of **2 words** in the sentence.
     - ----------------------------------------------------------------------------
     - Hard - Scrambled Words : Switches the placement of **6 words** in the sentence with eachother.
     - Hard - Scrambled Letters : Rearranges the letters of **3 words** in the sentence.
    */
    func makeSentenceQuery(diff difficulty: String) {
        let query = PFQuery(className:"Sentences")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                //Success! All sentences are now in the array 'objects'
                let randomSentenceIndex = Int.random(in: 0..<objects.count) //picking random index
                self.sentence = objects[randomSentenceIndex].object(forKey: "sentence") as! String // assigning randomly picked sentence to constant 'sentence'
                if self.puzzleType == "Scrambled Word Sentence" {
                    self.scrambledWordSentence = self.scrambleWords(in: self.sentence, diff: difficulty)
                    self.displayLabel.text = self.scrambledWordSentence
                } else {
                    //puzzleType == "Scrambled letter sentence"
                    self.scrambledLetterSentence = self.scrambleLetters(in: self.sentence, diff: difficulty)
                    self.displayLabel.text = self.scrambledLetterSentence
                }

            }
        }
    }
    
    
    
    //NOTE: Minimum of 6 words is needed if Hard level is chosen
    func scrambleWords(in sentence: String,diff difficulty: String) -> String {
        var characterSet = CharacterSet.init(charactersIn: ",.-!?") //creating a character set of punctuation we *don't* want in our words array
        characterSet = characterSet.union(.whitespaces)      //adding whitespaces to our character set of punctuation we don't want in our words array
        let components = sentence.components(separatedBy: characterSet) //taking out punctuation
        let words = components.filter{ !$0.isEmpty }  //'words' is an array that now contains just the words in our sentence
        numOfWords = words.count
        
        //randomly pick words/indices that'll get swapped & ensure they're all unique
        var firstIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        var secondIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        var thirdIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        var fourthIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        var fifthIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        var sixthIndexToBeSwapped = Int.random(in: 0..<numOfWords)
        
        while (firstIndexToBeSwapped == secondIndexToBeSwapped || firstIndexToBeSwapped == thirdIndexToBeSwapped || firstIndexToBeSwapped == fourthIndexToBeSwapped
        || firstIndexToBeSwapped == fifthIndexToBeSwapped || firstIndexToBeSwapped == sixthIndexToBeSwapped) {
            firstIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        while (secondIndexToBeSwapped == firstIndexToBeSwapped || secondIndexToBeSwapped == thirdIndexToBeSwapped || secondIndexToBeSwapped == fourthIndexToBeSwapped
        || secondIndexToBeSwapped == fifthIndexToBeSwapped || secondIndexToBeSwapped == sixthIndexToBeSwapped) {
            secondIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        while (thirdIndexToBeSwapped == firstIndexToBeSwapped || thirdIndexToBeSwapped == secondIndexToBeSwapped || thirdIndexToBeSwapped == fourthIndexToBeSwapped
        || thirdIndexToBeSwapped == fifthIndexToBeSwapped || thirdIndexToBeSwapped == sixthIndexToBeSwapped) {
            thirdIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        while (fourthIndexToBeSwapped == firstIndexToBeSwapped || fourthIndexToBeSwapped == secondIndexToBeSwapped || fourthIndexToBeSwapped == thirdIndexToBeSwapped
        || fourthIndexToBeSwapped == fifthIndexToBeSwapped || fourthIndexToBeSwapped == sixthIndexToBeSwapped) {
            fourthIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        while (fifthIndexToBeSwapped == firstIndexToBeSwapped || fifthIndexToBeSwapped == secondIndexToBeSwapped || fifthIndexToBeSwapped == thirdIndexToBeSwapped
        || fifthIndexToBeSwapped == fourthIndexToBeSwapped || fifthIndexToBeSwapped == sixthIndexToBeSwapped) {
            fifthIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        while (sixthIndexToBeSwapped == firstIndexToBeSwapped || sixthIndexToBeSwapped == secondIndexToBeSwapped || sixthIndexToBeSwapped == thirdIndexToBeSwapped
        || sixthIndexToBeSwapped == fourthIndexToBeSwapped || sixthIndexToBeSwapped == fifthIndexToBeSwapped) {
            sixthIndexToBeSwapped = Int.random(in: 0..<numOfWords) }
        
        
        var punctuationArray : [(Int,String)] = []  //2-tuple array that will hold the punctuation in original sentence and what index it goes after
        let charsInSentence = Array(sentence) //array of all characters in sentence (each individual letter, whitespace, and punctuation)
        var currIndex : Int = 0 //var denoting which word we're on
        
        var scrambledSentenceArray : [String] = []    //array containing the scrambled words in the order they will be displayed
        var scrambledSentence = ""  //string containing the scrambled words in the order they will be displayed
        
        if difficulty == "Easy" {
            for i in 0..<words.count {
                if i == firstIndexToBeSwapped {  //if we're at the first index that gets swapped...
                    scrambledSentenceArray.append(words[secondIndexToBeSwapped])  //instead of appending the word at that index, append the word at the second index we're swapping with
                } else if i == secondIndexToBeSwapped {
                    scrambledSentenceArray.append(words[firstIndexToBeSwapped])
                } else {
                    //every other word will get appended in the same order they're in in the original sentence
                    scrambledSentenceArray.append(words[i])
                }
            }
        } else if difficulty == "Normal" {
            for i in 0..<words.count {
                if i == firstIndexToBeSwapped {  //if we're at the first index that gets swapped...
                    scrambledSentenceArray.append(words[secondIndexToBeSwapped])  //instead of appending the word at that index, append the word at the second index we're swapping with
                } else if i == secondIndexToBeSwapped {
                    scrambledSentenceArray.append(words[firstIndexToBeSwapped])
                } else if i == thirdIndexToBeSwapped {
                    scrambledSentenceArray.append(words[fourthIndexToBeSwapped])
                } else if i == fourthIndexToBeSwapped {
                    scrambledSentenceArray.append(words[thirdIndexToBeSwapped])
                } else {
                    //every other word will get appended in the same order they're in in the original sentence
                    scrambledSentenceArray.append(words[i])
                }
            }
        } else {
            //difficulty == "Hard"
            for i in 0..<words.count {
                if i == firstIndexToBeSwapped {  //if we're at the first index that gets swapped...
                    scrambledSentenceArray.append(words[secondIndexToBeSwapped])  //instead of appending the word at that index, append the word at the second index we're swapping with
                } else if i == secondIndexToBeSwapped {
                    scrambledSentenceArray.append(words[firstIndexToBeSwapped])
                } else if i == thirdIndexToBeSwapped {
                    scrambledSentenceArray.append(words[fourthIndexToBeSwapped])
                } else if i == fourthIndexToBeSwapped {
                    scrambledSentenceArray.append(words[thirdIndexToBeSwapped])
                } else if i == fifthIndexToBeSwapped {
                    scrambledSentenceArray.append(words[sixthIndexToBeSwapped])
                } else if i == sixthIndexToBeSwapped {
                    scrambledSentenceArray.append(words[fifthIndexToBeSwapped])
                } else {
                    //every other word will get appended in the same order they're in in the original sentence
                    scrambledSentenceArray.append(words[i])
                }
            }
        }
            
        for i in 0..<charsInSentence.count {
            if !charsInSentence[i].isLetter && !charsInSentence[i].isNumber && !charsInSentence[i].isWhitespace && (i+1 == charsInSentence.count || charsInSentence[i+1].isWhitespace || charsInSentence[i] == "-") {
                //we enter this is if statement when charsInSentence[i] is not a letter,number, or whitespace *and* when we're at the end of a sentence, or the next character is a whitespace, or charsInSentence[i] is a hyphen. Essentially, whenever we're at a punctuation
                let punc : String = String(charsInSentence[i]) //save the punctuation to punc
                punctuationArray.append((currIndex, punc)) //save punc and what word it appears after to punctuationArray
            }
            if charsInSentence[i].isWhitespace {
                currIndex+=1    //increase currIndex whenever we pass a space (goes up to numOfWords-1)
            }
        }
        
        for i in 0..<numOfWords {
            scrambledSentence += scrambledSentenceArray[i] //assigning the elements from scrambledSentenceArray into scrambledSentence
            for j in 0..<punctuationArray.count {
                if i == punctuationArray[j].0 {  //if the word index we're on (i) equals one of the word indices that a punctuation goes after...
                    scrambledSentence += punctuationArray[j].1  //add the punctuation symbol to the string in the placement it was in in the original sentence
                }
            }
            if i != numOfWords-1 {
                scrambledSentence += " "
            }
        }
        return scrambledSentence
    }
    
    
    
    func scrambleLetters(in sentence: String, diff difficulty: String) -> String {
        var characterSet = CharacterSet.init(charactersIn: ",.-!?") //creating a character set of punctuation we *don't* want in our words array
        characterSet = characterSet.union(.whitespaces)      //adding whitespaces to our character set of punctuation we don't want in our words array
        let components = sentence.components(separatedBy: characterSet) //taking out punctuation
        let words = components.filter{ !$0.isEmpty }  //'words' is an array that now contains just the words in our sentence
        numOfWords = words.count
        
        if difficulty == "Easy" {
            var randomWordIndex = Int.random(in: 0..<numOfWords)
            var randomWord = words[randomWordIndex]
            while (randomWord.count <= 3 || randomWord.contains("’") || (randomWord.rangeOfCharacter(from: .uppercaseLetters) != nil)) {
                randomWordIndex = Int.random(in: 0..<numOfWords)
                randomWord = words[randomWordIndex] }
            
            var randomWordEditable = randomWord
            let lengthOfWord = randomWord.count
            var scrambledWord = ""
            var randomIndexToBeRemoved = Int.random(in: 0..<randomWordEditable.count)
            repeat {
                for _ in 0..<lengthOfWord {
                    scrambledWord += String(randomWordEditable.remove(at: randomWordEditable.index(randomWordEditable.startIndex, offsetBy: randomIndexToBeRemoved)))
                    if randomWordEditable.count > 0 {
                        randomIndexToBeRemoved = Int.random(in: 0..<randomWordEditable.count)
                    }
                }
            } while scrambledWord == randomWord
            
            print("scrambledWord : \(scrambledWord)")
            let indexInSentence = sentence.range(of: randomWord)
            let completedSentence = sentence.replacingCharacters(in: indexInSentence!, with: scrambledWord)
            
            return completedSentence
        } else if difficulty == "Normal" {
            var randomWordIndex1 = Int.random(in: 0..<numOfWords)
            var randomWordIndex2 = Int.random(in: 0..<numOfWords)
            var randomWord1 = words[randomWordIndex1]
            var randomWord2 = words[randomWordIndex2]
            while (randomWord1.count <= 3 || randomWord1.contains("’") || (randomWord1.rangeOfCharacter(from: .uppercaseLetters) != nil)) {
                randomWordIndex1 = Int.random(in: 0..<numOfWords)
                randomWord1 = words[randomWordIndex1] }
            while (randomWord2.count <= 3 || randomWord2.contains("’") || (randomWord2.rangeOfCharacter(from: .uppercaseLetters) != nil) || randomWord2 == randomWord1) {
                randomWordIndex2 = Int.random(in: 0..<numOfWords)
                randomWord2 = words[randomWordIndex2] }
            
            var randomWordEditable1 = randomWord1
            var randomWordEditable2 = randomWord2
            let lengthOfWord1 = randomWord1.count
            let lengthOfWord2 = randomWord2.count
            var scrambledWord1 = ""
            var scrambledWord2 = ""
            var randomIndexToBeRemoved1 = Int.random(in: 0..<randomWordEditable1.count)
            var randomIndexToBeRemoved2 = Int.random(in: 0..<randomWordEditable2.count)
            
            repeat {
                for _ in 0..<lengthOfWord1 {
                    scrambledWord1 += String(randomWordEditable1.remove(at: randomWordEditable1.index(randomWordEditable1.startIndex, offsetBy: randomIndexToBeRemoved1)))
                    if randomWordEditable1.count > 0 {
                        randomIndexToBeRemoved1 = Int.random(in: 0..<randomWordEditable1.count)
                    }
                }
            } while scrambledWord1 == randomWord1
            
            repeat {
                for _ in 0..<lengthOfWord2 {
                    scrambledWord2 += String(randomWordEditable2.remove(at: randomWordEditable2.index(randomWordEditable2.startIndex, offsetBy: randomIndexToBeRemoved2)))
                    if randomWordEditable2.count > 0 {
                        randomIndexToBeRemoved2 = Int.random(in: 0..<randomWordEditable2.count)
                    }
                }
            } while scrambledWord2 == randomWord2
            
            print("scrambledWord1 : \(scrambledWord1) ; scrambledWord2 : \(scrambledWord2)")
            let indexInSentence1 = sentence.range(of: randomWord1)
            let indexInSentence2 = sentence.range(of: randomWord2)
            var completedSentence = sentence.replacingCharacters(in: indexInSentence1!, with: scrambledWord1)
            completedSentence = completedSentence.replacingCharacters(in: indexInSentence2!, with: scrambledWord2)
            
            return completedSentence
        } else {
            //difficulty == "Hard"
            var randomWordIndex1 = Int.random(in: 0..<numOfWords)
            var randomWordIndex2 = Int.random(in: 0..<numOfWords)
            var randomWordIndex3 = Int.random(in: 0..<numOfWords)
            var randomWord1 = words[randomWordIndex1]
            var randomWord2 = words[randomWordIndex2]
            var randomWord3 = words[randomWordIndex3]
            while (randomWord1.count <= 3 || randomWord1.contains("’") || (randomWord1.rangeOfCharacter(from: .uppercaseLetters) != nil)) {
                randomWordIndex1 = Int.random(in: 0..<numOfWords)
                randomWord1 = words[randomWordIndex1] }
            while (randomWord2.count <= 3 || randomWord2.contains("’") || (randomWord2.rangeOfCharacter(from: .uppercaseLetters) != nil) || randomWord2 == randomWord1) {
                randomWordIndex2 = Int.random(in: 0..<numOfWords)
                randomWord2 = words[randomWordIndex2] }
            while (randomWord3.count <= 3 || randomWord3.contains("’") || (randomWord3.rangeOfCharacter(from: .uppercaseLetters) != nil) || randomWord3 == randomWord1 || randomWord3 == randomWord2) {
                randomWordIndex3 = Int.random(in: 0..<numOfWords)
                randomWord3 = words[randomWordIndex3] }
            
            var randomWordEditable1 = randomWord1
            var randomWordEditable2 = randomWord2
            var randomWordEditable3 = randomWord3
            let lengthOfWord1 = randomWord1.count
            let lengthOfWord2 = randomWord2.count
            let lengthOfWord3 = randomWord3.count
            var scrambledWord1 = ""
            var scrambledWord2 = ""
            var scrambledWord3 = ""
            var randomIndexToBeRemoved1 = Int.random(in: 0..<randomWordEditable1.count)
            var randomIndexToBeRemoved2 = Int.random(in: 0..<randomWordEditable2.count)
            var randomIndexToBeRemoved3 = Int.random(in: 0..<randomWordEditable3.count)
            
            repeat {
                for _ in 0..<lengthOfWord1 {
                    scrambledWord1 += String(randomWordEditable1.remove(at: randomWordEditable1.index(randomWordEditable1.startIndex, offsetBy: randomIndexToBeRemoved1)))
                    if randomWordEditable1.count > 0 {
                        randomIndexToBeRemoved1 = Int.random(in: 0..<randomWordEditable1.count)
                    }
                }
            } while scrambledWord1 == randomWord1
            
            repeat {
                for _ in 0..<lengthOfWord2 {
                    scrambledWord2 += String(randomWordEditable2.remove(at: randomWordEditable2.index(randomWordEditable2.startIndex, offsetBy: randomIndexToBeRemoved2)))
                    if randomWordEditable2.count > 0 {
                        randomIndexToBeRemoved2 = Int.random(in: 0..<randomWordEditable2.count)
                    }
                }
            } while scrambledWord2 == randomWord2
            
            repeat {
                for _ in 0..<lengthOfWord3 {
                    scrambledWord3 += String(randomWordEditable3.remove(at: randomWordEditable3.index(randomWordEditable3.startIndex, offsetBy: randomIndexToBeRemoved3)))
                    if randomWordEditable3.count > 0 {
                        randomIndexToBeRemoved3 = Int.random(in: 0..<randomWordEditable3.count)
                    }
                }
            } while scrambledWord3 == randomWord3
            
            print("scrambledWord1 : \(scrambledWord1) \n scrambledWord2 : \(scrambledWord2) \n scrambledWord3 : \(scrambledWord3)")
            let indexInSentence1 = sentence.range(of: randomWord1)
            let indexInSentence2 = sentence.range(of: randomWord2)
            let indexInSentence3 = sentence.range(of: randomWord3)
            var completedSentence = sentence.replacingCharacters(in: indexInSentence1!, with: scrambledWord1)
            completedSentence = completedSentence.replacingCharacters(in: indexInSentence2!, with: scrambledWord2)
            completedSentence = completedSentence.replacingCharacters(in: indexInSentence3!, with: scrambledWord3)
            
            return completedSentence
        }
        
    }

    //takes in answer "correct", "incorrect"
    func toggleSubmitButton(for answer : String) {
        if answer == "correct" {
            submitButton.setTitleColor(UIColor.green, for: .normal) //Submit button will become green
            submitButton.setTitle("Correct!", for: .normal)  // and say "Correct!" temporarily...
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.submitButton.setTitleColor(self.submitButtonColor, for: .normal) //Submit color goes back to the original
                self.submitButton.setTitle("Submit", for: .normal)  //and the title goes back to "Submit"
            }
        } else {
            //answer == "incorrect"
            submitButton.setTitleColor(UIColor.red, for: .normal) //Submit button will become green
            submitButton.setTitle("Incorrect!", for: .normal)  // and say "Correct!" temporarily...
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.submitButton.setTitleColor(self.submitButtonColor, for: .normal) //Submit color goes back to the original
                self.submitButton.setTitle("Submit", for: .normal)  //and the title goes back to "Submit"
            }
        }
    }
    
    
    @IBAction func onNewButton(_ sender: Any) {
        newButtonClicked = true
        
        if puzzleType == "Math Equations" {
            inputTextField.text = ""
            makeMathQuery(diff: difficultyLevel)
        } else {
            //puzzleType == "Scrambled Word Sentence" OR "Scrambled Letter Sentence"
            inputTextField.text = ""
            makeSentenceQuery(diff: difficultyLevel)
        }
        restartTimer()
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        submitButtonClicked = true
        if puzzleType == "Math Equations" {
            var ans : Float
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2

            // Avoid getting a zero on numbers lower than 1
            // Eg: .5, .67, etc...
            //If ans is a decimal number, it will be rounded to the nearest tenths place
            formatter.numberStyle = .decimal

            if difficultyLevel == "Easy" {
                ans = self.compute(Float(num1), Float(num2), symbol1)
            } else if difficultyLevel == "Normal" {
                ans = self.compute(Float(num1), Float(num2), symbol1)
                ans = self.compute(ans, Float(num3), symbol2)
            } else {
                //difficulty == "Hard"
                ans = self.compute(Float(num1), Float(num2), symbol1)
                ans = self.compute(ans, Float(num3), symbol2)
                ans = self.compute(ans, Float(num4), symbol3)
            }

            let finalAns : String = formatter.string(from: ans as NSNumber)!
            if inputTextField.text! == finalAns {
                //answer is correct
                toggleSubmitButton(for: "correct")
                
                numberOfCorrectAnswers += 1 //increment number of correct answers
                inputTextField.text = "" //clear text field
                if difficultyLevel == "Easy" && numberOfCorrectAnswers < 3 {
                    makeMathQuery(diff: difficultyLevel)
                } else if difficultyLevel == "Normal" && numberOfCorrectAnswers < 2 {
                    makeMathQuery(diff: difficultyLevel)
                } else {
                    //"Easy" && numberOfCorrectAnswers == 3 OR "Normal" && numberOfCorrectAnswers == 2 OR "Hard" && numberOfCorrectAnswers == 1
                    //segue to home screen gets performed
                }
            } else {
                //answer is incorrect
                toggleSubmitButton(for: "incorrect")
                
                numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
                inputTextField.text = "" //clear text field
                makeMathQuery(diff: difficultyLevel)
            }
        } else {
            //puzzleType == "Scrambled Word Sentence" OR "Scrambled Letter Sentence"
            if sentence == inputTextField.text! {
                //answer is correct
                toggleSubmitButton(for: "correct")
                
                numberOfCorrectAnswers += 1 //increment number of correct answers
                inputTextField.text = "" //clear text field
                if difficultyLevel == "Easy" && numberOfCorrectAnswers < 3 {
                    makeSentenceQuery(diff: difficultyLevel)
                } else if difficultyLevel == "Normal" && numberOfCorrectAnswers < 2 {
                    makeSentenceQuery(diff: difficultyLevel)
                } else {
                    //"Easy" && numberOfCorrectAnswers == 3 OR "Normal" && numberOfCorrectAnswers == 2 OR "Hard" && numberOfCorrectAnswers == 1
                    //segue to home screen gets performed
                }
            } else {
                //answer is incorrect
                toggleSubmitButton(for: "incorrect")
                
                numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
                inputTextField.text = "" //clear text field
                makeSentenceQuery(diff: difficultyLevel)
            }
        }
        restartTimer()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "submitToHomeButton" {
            if (difficultyLevel == "Easy" && numberOfCorrectAnswers == 3) || (difficultyLevel == "Normal" &&  numberOfCorrectAnswers == 2) || (difficultyLevel == "Hard" &&  numberOfCorrectAnswers == 1) {
                successfulSolve = true
                return true
                
            }
        }
        return false
    }
}


extension SolveAlarmViewController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation,
    finished flag: Bool) {
    if successfulSolve {
        layer0.removeFromSuperlayer()
        layer1.removeFromSuperlayer()
    }
    inputTextField.text = ""
    if !submitButtonClicked && !newButtonClicked {
        //if submit button was NOT clicked at all and new Button was not clicked
        numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
        toggleSubmitButton(for: "incorrect")
        restartTimer()
        puzzleType == "Math Equations" ? makeMathQuery(diff: difficultyLevel) : makeSentenceQuery(diff: difficultyLevel)
    }
    if newButtonClicked {
        //if new button was clicked
        newButtonClicked = false
    }
    submitButtonClicked = false
  }
}



@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
