//
//  ContentView.swift
//  WordScramble
//
//  Created by Sudeshna Patra on 12/21/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorMsg = ""
    @State private var errorTitle = ""
    @State private var showingErr = false
    @State private var score = 0
    @State private var scrollText = false

    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord).foregroundColor(.purple).textFieldStyle(RoundedBorderTextFieldStyle()).padding().autocapitalization(.none)
                
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0).foregroundColor(Color(red: .random(in: 0.1..<0.6), green: .random(in:0.1..<0.6), blue:.random(in: 0.1..<0.6))).bold().font(.title3)
                        //.font(.headline)
                }
                
                Text("Current Score:  \(score)").padding().font(.title)
            }
            .navigationBarTitle(rootWord).onAppear(perform: startGame).alert(isPresented: $showingErr){
                Alert(title: Text(errorTitle), message: Text(errorMsg), dismissButton: .default(Text("OK")))
            }
           // .navigationBarItems(leading: Text("make word as many").font(.footnote))
            .navigationBarItems(trailing: Button(action: startGame, label: {
                Text("New Game").foregroundColor(.purple).offset(x: scrollText ? .zero : 100.0)
                    .animation(Animation.linear(duration: 8).repeatForever(autoreverses: true))
                    .onAppear {
                      self.scrollText.toggle()
                    }
            }
            ))
           
        }
    }
    
     func addNewWord(){
        //lowercase and trim the word
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        //exit if the remaining string is empty
       
        guard answer.count > 0 else {
                return
            }
        
        //extra validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word alredy used", msg: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "word not recognized", msg: "You can't just make them up, you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", msg: "That is not a real word")
            return
        }
        guard hasProperLength(word: answer) else {
            wordError(title: "Word is too short", msg: "word should have atleast 3 letters")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        score = score + (answer.count * 2) + 10
        
    }
    
    func startGame(){
        usedWords.removeAll()
        score = 0
        newWord = ""
        // 1. Find the URL for start.txt in our app bundle
        if let wordFileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            //Load start.txt into string
            if let words = try? String(contentsOf: wordFileURL){
                //3. Split the string up into an array of strings, splitting on line breaks
                let allwords = words.components(separatedBy: "\n")
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allwords.randomElement() ?? "silkworm"
                
                //5. If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If we are *here* then there was a problem – trigger a crash and report the error
        fatalError("could not load from the bundle")
    }
    
    
    //Check: is the word original (it hasn’t been used already)
    func isOriginal(word: String) -> Bool{
        return !usedWords.contains(word)
    }
    
    //Check: is the word possible (they aren’t trying to spell “car” from “silkworm”)
    func isPossible(word: String)-> Bool{
        var temp = rootWord
        for letter in word{
            //get the position of the letter
            if let pos = temp.firstIndex(of: letter){
                temp.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    //Check: is the word real (it’s an actual English word).
    func isReal(word: String) -> Bool{
         let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missplledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missplledRange.location == NSNotFound
    }
    
    func hasProperLength(word: String) -> Bool{
        guard word.count>2 else {
            return false
        }
        return true
    }
    
    func wordError(title: String,msg:String){
        errorMsg = msg
        errorTitle = title
        showingErr = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


