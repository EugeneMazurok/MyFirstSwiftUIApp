import SwiftUI

struct ProfileView: View {
    @State private var showSurvey = false
    @ObservedObject  var firebaseManager:FirebaseManager
    @State var myOrder:Order = Order(deliveryDate: "", altushka: "", user: "")
    @State var myAltushka: Altushka = Altushka(name: "", tags: "", photo: "", isFree: true)
    @State var me:MyUser = MyUser(name: "String", email: "String", age: 0, weight: 0, alcoholStage: 0, isConfirmed: "String", score: 0)
    
    var questions: [Question] = [
        Question(question: "Укажите возраст", answerOptions: [
            AnswerOption(option: "18-24", pointValue: 0),
            AnswerOption(option: "25-35", pointValue: 2),
            AnswerOption(option: "35-45", pointValue: 4),
            AnswerOption(option: "45+", pointValue: 10),
        ]),
        Question(question: "Укажите ваш вес", answerOptions: [
            AnswerOption(option: "<80 КГ", pointValue: 0),
            AnswerOption(option: "80-90 КГ", pointValue: 2),
            AnswerOption(option: "90-100 КГ", pointValue: 4),
            AnswerOption(option: "100+ КГ", pointValue: 10),
        ]),
        Question(question: "Укажите вашу стадию алкоголизма", answerOptions: [
            AnswerOption(option: "Не употребляю", pointValue: 0),
            AnswerOption(option: "I", pointValue: 2),
            AnswerOption(option: "II", pointValue: 4),
            AnswerOption(option: "III", pointValue: 10),
        ]),
        Question(question: "Укажите сферу вашей профессии", answerOptions: [
            AnswerOption(option: "Другая", pointValue: 0),
            AnswerOption(option: "Офисный клерк", pointValue: 2),
            AnswerOption(option: "Оказание услуг (типо сантехник шаришь)", pointValue: 4),
            AnswerOption(option: "Производство (ЗАВОД))))", pointValue: 10),
        ])
    ]

    
    var body: some View {
        VStack(alignment:.leading) {
            VStack(alignment:.leading){
                HStack{
                    Image(systemName: "person.crop.circle").resizable()
                        .frame(width: 100,height: 100)
                    Text("\(me.email.components(separatedBy: "@").first ?? "")").bold()
                        .font(.title2)
                }
                
            }
            Text("Ваши заказы").bold()
                .font(.title)
            HStack{
                AsyncImage(url:URL(string: myAltushka.photo)){ phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 125, height: 125)
                    }
                }
                VStack(alignment:.leading){
                    Text(myAltushka.name).font(.title2).bold()
                    
                    if me.isConfirmed == "false" && myOrder.user != ""{
                        Spacer()
                        Text("Забронирована. Необходимо подтвердить скуфство")
                            .foregroundStyle(.yellow)
                            .bold()
                            .font(.subheadline)
                        Text("Примерная дата доставки: \(myOrder.deliveryDate)")
                            .bold()
                            .font(.subheadline)
                    }
                    else if me.score >= 5  && myOrder.user != ""{
                        Spacer()
                        Text("В доставке").foregroundStyle(.green)
                            .bold()
                            .font(.subheadline)
                        Text("Дата доставки: \(myOrder.deliveryDate)")
                            .bold()
                            .font(.subheadline)
                    }
                    else if me.score <= 5  && myOrder.user != "" {
                        Spacer()
                        Text("Отменена")
                            .foregroundStyle(.red)
                            .bold()
                            .font(.subheadline)
                    }
                    else {
                        Text("У вас нет заказов на данный момент")
                            .font(.title2).bold()
                    }
                }
            }.frame(maxHeight: 125)
            if me.isConfirmed == "false"{
                Button(action: {
                    showSurvey.toggle()
                }) {
                    Text("Подтвердить скуфство")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        
                }.frame(height: 50)
                    .frame(maxWidth: .infinity)
                    
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gosBlue, lineWidth: 2)
                            .background(Color.gosBlue.cornerRadius(10))
                    }
            }
            else if me.score >= 5 {
                Text("Скуфство подтверждено.").font(.title2).bold()
            }
            else {
                Text("Вы недостаточно СКУФИДОН, повторите попытку через год").font(.title2).bold()
            }
 
            Spacer()
        }
        .padding(.horizontal)
        .onAppear(){
            
            firebaseManager.getAllOrders(){
                order in
                    DispatchQueue.main.async {
                        myOrder = order
                        firebaseManager.getAltushkaByName(name: myOrder.altushka) { altushka in
                            DispatchQueue.main.async {
                                myAltushka = altushka
                                print(altushka)
                                print(altushka.photo)
                                firebaseManager.getUserByEmail() { user in
                                    if let user = user {
                                        
                                        me = user
                                    }
                                }
                                if me.score < 5 && me.isConfirmed == "true" {
                                    firebaseManager.updateAltushkaStatus(name: myAltushka.name, status: "true")
                                
                                }
                            }
                        }
                    }
            }
            
            
        }
        .sheet(isPresented: $showSurvey) {
            SurveyView( questions:questions, firebaseManager:firebaseManager, showSurvey: showSurvey, user: $me)
        }
    }
    
}
