//
//  SolveAlarmViewController.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 4/28/21.
//

import UIKit
import Parse



class SolveAlarmViewController: UIViewController, UITextViewDelegate {
    
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    let puzzleType = "Math Equations" // Three options: "Math Equations" ,  "Scrambled Word Sentence", "Scrambled Letter Sentence"
    let difficultyLevel = "Easy" // Three options: "Easy" ,  "Normal", "Hard" ; difficulty level chosen by user ; should always start with capital letter
    var numberOfCorrectAnswers : Int = 0 //User must get 3 if difficulty = Easy ; 2 if difficulty = Normal ; 1 if difficulty = Hard
    var numberOfCorrectAnswersNeeded : Int = 0
    
    var numOfSeconds : Double = 60 //selected by user on settings screen
    
    var submitButtonColor = UIColor(rgb: 0x8D733E)
    var submitButtonClicked : Bool = false
    var newButtonClicked : Bool = false
    var successfullySolvedAllPuzzles : Bool = false
    var onStart : Bool = false
    
    let layer1 = CAShapeLayer()
    let layer0 = CAShapeLayer()
    
    //Math Equations
    var num1 : Int = 0
    var num2 : Int = 0
    var num3 : Int = 0
    var num4 : Int = 0
    var symbol1 : String = ""
    var symbol2 : String = ""
    var symbol3 : String = ""
    var openParenthesis1 = "("
    var openParenthesis2 = "("
    var closedParenthesis1 = ")"
    var closedParenthesis2 = ")"
    var randomOperandIndex : Int = 0
    var randomOperatorIndex : Int = 0
    let easyArithmeticDifficultyId = "8XTOzojIhh"
    let normalArithmeticDifficultyId = "AFBlskbw6f"
    let hardArithmeticDifficultyId = "l7Mz6YPDS0"
    var mathEquationString : String = ""
    var mathEquationArray : [String] = []
    
    //Sentences
    var sentence : String = ""
    var scrambledLetterSentence : String = ""
    var scrambledWordSentence : String = ""
    var numOfWords : Int = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        numOfSeconds = Double(defaults.integer(forKey: "timeSelected"))
        
        restartTimer()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Choose which Keyboard to display & get height for display of inputTextField
        if puzzleType == "Math Equations" {
            self.inputTextField.keyboardType = .numbersAndPunctuation
        } else {
            //puzzleType == "Scrambled Word Sentence" or "Scrambled Letter Sentence"
            self.inputTextField.keyboardType = .alphabet
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handle(keyboardShowNotification:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        
        inputTextField.delegate = self
        inputTextField.becomeFirstResponder()
        if difficultyLevel == "Hard" && puzzleType == "Math Equations" {
            inputTextField.text = "Round fractional numbers to two decimal places..."
            inputTextField.textColor = UIColor.lightGray
            onStart = true
        }
        

        //Setting Submit Button to display correctly upon load
        submitButton.setTitleColor(submitButtonColor, for: .normal)
        submitButton.setTitle("Submit", for: .normal)
        
        //Setting Score Label to display correctly upon load
        switch difficultyLevel {
        case "Easy":
            numberOfCorrectAnswersNeeded = 3
        case "Normal":
            numberOfCorrectAnswersNeeded = 2
        case "Hard":
            numberOfCorrectAnswersNeeded = 1
        default:
            numberOfCorrectAnswersNeeded = 0
        }
        scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
        
        //if puzzleType selected is "Math Equations" then call makeMathQuery(), else call makeSentenceQuery()
        puzzleType == "Math Equations" ? makeMathQuery(diff: difficultyLevel) : makeSentenceQuery(diff: difficultyLevel)
        
        //dark mode implementation
        if defaults.bool(forKey: "darkModeToggleOn") {
            submitButtonColor = .white
            inputTextField.backgroundColor = .black
            newButton.backgroundColor = .black
            submitButton.backgroundColor = .black
            
            inputTextField.textColor = .white
            newButton.setTitleColor(.white, for: .normal)
            submitButton.setTitleColor(.white, for: .normal)
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if onStart {
            inputTextField.textColor = .black
            let inputtedText = inputTextField.text.suffix(1)
            inputTextField.text = String(inputtedText)
            onStart = false
        }
    }
    
    @objc
    private func handle(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo,
           //set up constraints for inputTextField to always end 5 points above top of keyboard
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            NSLayoutConstraint.activate([inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(keyboardRectangle.height) - 5 )])
        }
    }
    
    
    @objc func restartTimer() {
        //Lay down background stroke
        let shapeLayerBottom = UIBezierPath()
        shapeLayerBottom.move(to: CGPoint(x:(UIScreen.main.bounds.width)-10, y:60))
        shapeLayerBottom.addLine(to: CGPoint(x: 10, y: 60))
        layer0.path = shapeLayerBottom.cgPath
        let myColor : UIColor = UIColor(rgb: 0x8D733E)
        layer0.strokeColor = myColor.cgColor
        layer0.lineWidth = 8
        layer0.lineCap = CAShapeLayerLineCap.round
        layer0.strokeEnd = (UIScreen.main.bounds.width)-20
        self.view.layer.addSublayer(layer0)
        
        //creation of white overlay stroke
        let shapeLayerTop = UIBezierPath()
        shapeLayerTop.move(to: CGPoint(x:(UIScreen.main.bounds.width)-10, y:60))
        shapeLayerTop.addLine(to: CGPoint(x: 10, y: 60))
        layer1.path = shapeLayerTop.cgPath
        layer1.strokeColor = UIColor.white.cgColor
        layer1.lineWidth = 8
        layer1.lineCap = CAShapeLayerLineCap.round
        layer1.strokeEnd = 0
        self.view.layer.addSublayer(layer1)
        
        if !successfullySolvedAllPuzzles {
            //if we user hasn't solved all the required puzzles yet, continue to reset animation
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 1
            basicAnimation.duration = numOfSeconds
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            basicAnimation.delegate = self
            layer1.add(basicAnimation, forKey: "randomString1")
            
            let basicAnimation0 = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation0.toValue = 1
            basicAnimation0.duration = 1
            basicAnimation0.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation0.isRemovedOnCompletion = false
            layer0.add(basicAnimation0, forKey: "randomString0")
        }
    }
    
    
    
    //*********************************************************************** Math Equations ************************************************************************
    
    /**
     This function returns a math equation based on the difficulty selected by the user.
      
     - parameter difficulty: difficulty selected by user, options are *Easy*, *Normal*, and *Hard*
     - returns: The math equation to be displayed
     
     # Notes: #
     1. Easy - Returns an equation with 1 operator (choices being +,-) and 2 operands (choices being 1...50)
     2.   Normal - Returns an equation with 2 operators (choices being +,-,*) and 3 operands (choices being 1...75)
     3.   Hard- Returns an equation with 3 operators (choices being +,-,*,/) and 4 operands (choices being 1...100)
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
                
                self.mathEquationArray = [String(self.num1), String(self.symbol1), String(self.num2)]
                
                for symbol in self.mathEquationArray {
                    self.mathEquationString += symbol
                    if symbol != String(self.num2) { self.mathEquationString += " " }
                }
                
                self.displayLabel.text = "\(self.mathEquationString)"

                
                if (difficulty == "Normal") || (difficulty == "Hard") {
                    //get more numbers and symbols
                    self.randomOperandIndex = Int.random(in: 0..<operands.count)
                    self.num3 = operands[self.randomOperandIndex]
                    self.randomOperatorIndex = Int.random(in: 0..<operators.count)
                    self.symbol2 = operators[self.randomOperatorIndex]
                    
                    //add random parentheses to equation before displaying
                    self.mathEquationArray += [String(self.symbol2), String(self.num3)]

                    if difficulty == "Normal" {
                        let possibleInsertionChoices = [0,2] //Possibilities for open parenthesis
                        self.mathEquationArray.insert(self.openParenthesis1, at: possibleInsertionChoices[Int.random(in: 0...1)])
                        if self.mathEquationArray[0] == self.openParenthesis1 {
                            //insert closing parenthesis at index 4
                            self.mathEquationArray.insert(self.closedParenthesis1, at: 4)
                        } else {
                            //open parenthesis is at index 2 ; insert closing parenthesis at end of array
                            self.mathEquationArray.append(self.closedParenthesis1)
                        }
                    }
                    
                    self.mathEquationString = ""
                    for symbol in self.mathEquationArray {
                        if symbol == self.closedParenthesis1 { self.mathEquationString.removeLast() }
                        self.mathEquationString += symbol
                        //no spaces after last number, after open parentheses, or before closing parentheses
                        if symbol != self.openParenthesis1 { self.mathEquationString += " " }
                    }
                    self.mathEquationString.removeLast() //remove extra space at end
                    self.displayLabel.text = "\(self.mathEquationString)"
                }
                if difficulty == "Hard" {
                    self.randomOperandIndex = Int.random(in: 0..<operands.count)
                    self.num4 = operands[self.randomOperandIndex]
                    self.randomOperatorIndex = Int.random(in: 0..<operators.count)
                    self.symbol3 = operators[self.randomOperatorIndex]
                    
                    //add random parentheses to equation before displaying
                    self.mathEquationArray += [String(self.symbol3), String(self.num4)]
                    
                    let possibleInsertionChoices0 = [0,2,4]
                    self.mathEquationArray.insert(self.openParenthesis1, at: possibleInsertionChoices0[Int.random(in: 0...2)])
                    if self.mathEquationArray[0] == self.openParenthesis1 {
                        //insert closing parenthesis at index 4, and new set of parentheses around remaining 2 numbers
                        self.mathEquationArray.insert(self.closedParenthesis1, at: 4)
                        self.mathEquationArray.insert(self.openParenthesis2, at: 6)
                        self.mathEquationArray.append(self.closedParenthesis2)
                    } else if self.mathEquationArray[2] == self.openParenthesis1 {
                        //insert closing parenthesis at index 6
                        self.mathEquationArray.insert(self.closedParenthesis1, at: 6)
                    } else {
                        //open parenthesis is at index 4 ; insert closing parenthesis at end of array
                        self.mathEquationArray.append(self.closedParenthesis2)
                    }
                    
                    self.mathEquationString = ""
                    for symbol in self.mathEquationArray {
                        if symbol == self.closedParenthesis1 { self.mathEquationString.removeLast() }
                        self.mathEquationString += symbol
                        if  (symbol != self.openParenthesis1) || (symbol != self.openParenthesis2) { self.mathEquationString += " " }
                    }
                    self.mathEquationString.removeLast() //remove extra space at end
                    self.displayLabel.text = "\(self.mathEquationString)"
                }
                
                self.mathEquationString = ""
            }
        }
    }
    
    func precedence(_ op: String) -> Int {
        if(op == "+"||op == "-") {
            return 1
        }
        if(op == "*"||op == "/") {
            return 2
        }
        return 0
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
            
            var numbersStack = Stack()
            var operatorsStack = Stack()
            
            if difficultyLevel == "Easy" {
                ans = self.compute(Float(num1), Float(num2), symbol1)
            } else if difficultyLevel == "Normal" {
                //create infix expression
                for element in self.mathEquationArray {
                    if element == "(" {
                        //push opening parentheses to operatorsStack
                        operatorsStack.push(element)
                    } else if (Int(element) != nil) {
                        //push numbers to numbersStack
                        numbersStack.push(element)
                    } else if element == ")" {
                        //solve upon encountering closing parentheses
                        while !operatorsStack.isEmpty() && operatorsStack.peek() != "(" {
                            let val2 = numbersStack.peek()
                            _ = numbersStack.pop()
                            
                            let val1 = numbersStack.peek()
                            _ = numbersStack.pop()
                            
                            let op = operatorsStack.peek()
                            _ = operatorsStack.pop()
                            
                            numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                        }
                        if !operatorsStack.isEmpty() {
                            //pop opening brace
                            _ = operatorsStack.pop()
                        }
                    } else {
                        //current element is an operator
                        // While top of 'operatorStack' has same or greater precedence to current element, which
                        //is an operator. Apply operator on top of 'ops' to top two elements in values stack.
                        while(!operatorsStack.isEmpty() && (precedence(operatorsStack.peek()) >= precedence(element))) {
                            let val2 = numbersStack.peek();
                            _ = numbersStack.pop();
                             
                            let val1 = numbersStack.peek();
                            _ = numbersStack.pop();
                             
                            let op = operatorsStack.peek();
                            _ = operatorsStack.pop();
                             
                            numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                        }
                        // Push current element to operatorsStack
                        operatorsStack.push(element)
                    }
                }
                
                // Entire expression has been parsed at this point, apply remaining ops to remaining values
                while(!operatorsStack.isEmpty()){
                    let val2 = numbersStack.peek()
                    _ = numbersStack.pop()
                             
                    let val1 = numbersStack.peek()
                    _ = numbersStack.pop()
                             
                    let op = operatorsStack.peek()
                    _ = operatorsStack.pop()
                             
                    numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                    }
                     
                // Top of 'values' contains final answer
                ans = Float(numbersStack.peek())!
                
            } else {
                //difficulty == "Hard"
                //create infix expression
                for element in self.mathEquationArray {
                    if element == "(" {
                        //push opening parentheses to operatorsStack
                        operatorsStack.push(element)
                    } else if (Int(element) != nil) {
                        //push numbers to numbersStack
                        numbersStack.push(element)
                    } else if element == ")" {
                        //solve upon encountering closing parentheses
                        while !operatorsStack.isEmpty() && operatorsStack.peek() != "(" {
                            let val2 = numbersStack.peek()
                            _ = numbersStack.pop()
                            
                            let val1 = numbersStack.peek()
                            _ = numbersStack.pop()
                            
                            let op = operatorsStack.peek()
                            _ = operatorsStack.pop()
                            
                            numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                        }
                        if !operatorsStack.isEmpty() {
                            //pop opening brace
                            _ = operatorsStack.pop()
                        }
                    } else {
                        //current element is an operator
                        // While top of 'operatorStack' has same or greater precedence to current element, which
                        //is an operator. Apply operator on top of 'ops' to top two elements in values stack.
                        while(!operatorsStack.isEmpty() && (precedence(operatorsStack.peek()) >= precedence(element))) {
                            let val2 = numbersStack.peek();
                            _ = numbersStack.pop();
                             
                            let val1 = numbersStack.peek();
                            _ = numbersStack.pop();
                             
                            let op = operatorsStack.peek();
                            _ = operatorsStack.pop();
                             
                            numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                        }
                        // Push current element to operatorsStack
                        operatorsStack.push(element)
                    }
                }
                
                // Entire expression has been parsed at this point, apply remaining operators to remaining values
                while(!operatorsStack.isEmpty()){
                    let val2 = numbersStack.peek()
                    _ = numbersStack.pop()
                             
                    let val1 = numbersStack.peek()
                    _ = numbersStack.pop()
                             
                    let op = operatorsStack.peek()
                    _ = operatorsStack.pop()
                             
                    numbersStack.push(String(compute(Float(val1)!, Float(val2)!, op)))
                    }
                     
                ans = Float(numbersStack.peek())!
            }
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2

            // Avoid getting a zero on numbers lower than 1 (Eg: .5, .67, etc...)
            // If ans is a decimal number, it will be rounded to the nearest hundredths place
            formatter.numberStyle = .decimal
            let finalAns : String = formatter.string(from: ans as NSNumber)!
            
            if inputTextField.text! == finalAns {
                //answer is correct
                toggleSubmitButton(for: "correct")
                
                numberOfCorrectAnswers += 1 //increment number of correct answers
                scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
                inputTextField.text = "" //clear text field
                if numberOfCorrectAnswers < numberOfCorrectAnswersNeeded {
                    makeMathQuery(diff: difficultyLevel)
                }
            } else {
                //answer is incorrect
                toggleSubmitButton(for: "incorrect")
                
                numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
                scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
                inputTextField.text = "" //clear text field
                makeMathQuery(diff: difficultyLevel)
            }
            
            
        } else {
            //puzzleType == "Scrambled Word Sentence" OR "Scrambled Letter Sentence"
            if sentence == inputTextField.text! {
                //answer is correct
                toggleSubmitButton(for: "correct")
                
                numberOfCorrectAnswers += 1 //increment number of correct answers
                scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
                inputTextField.text = "" //clear text field
                if numberOfCorrectAnswers < numberOfCorrectAnswersNeeded {
                    makeSentenceQuery(diff: difficultyLevel)
                }
            } else {
                //answer is incorrect
                toggleSubmitButton(for: "incorrect")
                
                numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
                scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
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
            if (numberOfCorrectAnswers == numberOfCorrectAnswersNeeded) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { //delay so user can see updated score
                    self.successfullySolvedAllPuzzles = true
                }
                return true
            }
        }
        return false
    }
}


extension SolveAlarmViewController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation,
    finished flag: Bool) {
    if successfullySolvedAllPuzzles {
        layer1.removeFromSuperlayer()
        layer0.removeFromSuperlayer()
    }
    inputTextField.text = ""
    if !submitButtonClicked && !newButtonClicked {
        //if submit button was NOT clicked, and new Button was NOT clicked (timer ran out)
        numberOfCorrectAnswers = (numberOfCorrectAnswers == 0) ? 0 : (numberOfCorrectAnswers - 1) //lowest possible value of numOfCorrectAnswers is 0
        scoreLabel.text = "\(numberOfCorrectAnswers)/\(numberOfCorrectAnswersNeeded)"
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

struct Stack {
    private var stackArray : [String] = []
    
    mutating func push(_ stringToPush: String) {
      stackArray.append(stringToPush)
    }
    
    mutating func pop() -> String? {
        return stackArray.popLast()
    }
    
    func isEmpty() -> Bool {
        return stackArray.isEmpty
    }
    
    func peek() -> String {
        guard let topElement = stackArray.last else { return "This stack is empty." }
        return topElement
    }
}

