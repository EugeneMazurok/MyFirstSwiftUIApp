//
//  SurveyView.swift
//  Alternative
//
//  Created by Евгений Мазурок on 14.03.2024.
//

import SwiftUI

struct SurveyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedAnswerIndices: [Int]
    @ObservedObject var firebaseManager:FirebaseManager
    @State var score: Int = 0
    var questions: [Question]
    @Binding var user: MyUser

    init(questions: [Question], firebaseManager: FirebaseManager, showSurvey: Bool, user: Binding<MyUser>) {
           self.questions = questions
           self._selectedAnswerIndices = State(initialValue: Array(repeating: 0, count: questions.count))
           self.firebaseManager = firebaseManager
           self._user = user
       }


    var body: some View {
        VStack(alignment:.leading) {
            ForEach(questions.indices, id: \.self) { index in
                VStack(alignment:.leading) {
                    Text(questions[index].question)
                        .font(.title)
                        .bold()
                    Picker(selection: $selectedAnswerIndices[index], label: Text("")) {
                        ForEach(questions[index].answerOptions.indices, id: \.self) { optionIndex in
                            Text(questions[index].answerOptions[optionIndex].option)
                        }
                    }
                    .fixedSize()
                }
            }

            Button(action: {
                calculateScore()
                user.isConfirmed = "true"
                user.score = score
                firebaseManager.addDataToUser(field: "isConfirmed", value: "true")
                firebaseManager.addDataToUser(field: "score", value: score)
                dismiss()
            }) {
                Text("Отправить")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                
            }.frame(height: 50)
                .frame(maxWidth: .infinity)
                
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gosBlue, lineWidth: 2)
                        .background(Color.gosBlue.cornerRadius(10))
                }
        }
        .padding()
    }

    func calculateScore() {

        for i in 0..<questions.count {
            let selectedAnswerIndex = selectedAnswerIndices[i]
            score += questions[i].answerOptions[selectedAnswerIndex].pointValue
        }
    }
}

