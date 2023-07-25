//
//  ContentView.swift
//  wordScramble
//
//  Created by Maverick Brazill on 7/25/23.
//

import SwiftUI

struct ContentView: View {
    @State var usedWords = [String]()
    @State var rootWord = ""
    @State var newWord = ""
    
    @State var errorTitle = ""
    @State var errorMessage = ""
    @State var showingError = false
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addNewWord(){
        let ans = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard ans.count > 0 else { return }
        
        guard isOriginal(str: ans) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(str: ans) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(str: ans) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation{
            usedWords.insert(ans, at: 0)
        }
        newWord = ""
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(str: String)-> Bool{
        !usedWords.contains(str)
    }
    
    func isPossible(str: String)-> Bool{
        var temp = rootWord
        
        for letter in str{
            if let pos = temp.firstIndex(of: letter){
                temp.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    func isReal(str: String)-> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: str.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: str, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    //begin view
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter a word", text: $newWord)
                        .autocapitalization(.none)
                        .onSubmit { addNewWord() }
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
        }.navigationTitle(rootWord).onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("Dismiss", role: .cancel){ }}message:{
                    Text(errorMessage)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
