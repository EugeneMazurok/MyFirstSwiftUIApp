//
//  HomeView.swift
//  Alternative
//
//  Created by Евгений Мазурок on 13.03.2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject  var firebaseManager:FirebaseManager
    @State var altushkas: [Altushka] = []
    @State var buttonColor: Color = Color.gosBlue
    @State private var buttonDisabled = false
    @State var me:MyUser = MyUser(name: "String", email: "String", age: 0, weight: 0, alcoholStage: 0, isConfirmed: "String", score: 0)
    
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 30), GridItem(.flexible(), spacing: 30)]){
                    
                    ForEach(firebaseManager.altushkas, id:\.self) { altushka in
                        VStack(alignment:.leading) {
                            AsyncImage(url:URL(string: altushka.photo)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150) 
                                }
                            }
                            Text(altushka.tags)
                                .foregroundStyle(.gray)
                                .lineLimit(2)
                            Text(altushka.name)
                                .font(.title3)
                                .lineLimit(2)
                            Spacer()
                            Button(action: {
                                firebaseManager.updateAltushkaStatus(name: altushka.name, status: "false")
                                firebaseManager.fetchAltushkas() { altushkas in
                                    DispatchQueue.main.async {
                                        self.firebaseManager.altushkas = altushkas
                                    }
                                }
                                let newOrder = Order(deliveryDate: DateFormatter.localizedString(from: Date().addingTimeInterval(60*60*24*7), dateStyle: .short, timeStyle: .none)
, altushka: altushka.name, user: me.email)
                                firebaseManager.addOrder(order: newOrder)
                                firebaseManager.checkIfUserHaveOrder { hasOrder in
                                    DispatchQueue.main.async {
                                        if hasOrder {
                                            self.buttonColor = Color.red
                                        }
                                        else {
                                            buttonColor = Color.blue
                                            buttonDisabled = false
                                        }
                                    }
                                }
                            }
                            ) {
                                Text("Забронировать")
                                    .padding(8)
                                    .foregroundStyle(buttonColor)
                                    .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(buttonColor, lineWidth: 2)
                                                )
                            }.disabled(buttonDisabled)
                        }.frame(width: 150, height: 300)
                    }

                }
                .padding(.horizontal)
            }
            .padding()
            .clipped()
        }
        .refreshable {
            firebaseManager.fetchAltushkas(){ altushkas in
                DispatchQueue.main.async {
                    firebaseManager.altushkas = altushkas
                    firebaseManager.checkIfUserHaveOrder(){ hasOrder in
                        DispatchQueue.main.async {
                            if hasOrder {
                                buttonColor = Color.red
                                buttonDisabled = true
                            }
                            else {
                                buttonColor = Color.gosBlue
                                buttonDisabled = false
                            }
                            
                        }
                    }
                }
            }
        }
        .onAppear{
            firebaseManager.getUserByEmail() { user in
                if let user = user {
                    
                    me = user
                    if me.score < 5 {
                        buttonColor = Color.red
                        buttonDisabled = true
                    }
                    else {
                        buttonColor = Color.gosBlue
                        buttonDisabled = false
                    }
                }
            }
            firebaseManager.fetchAltushkas(){ altushkas in
                DispatchQueue.main.async {
                    firebaseManager.altushkas = altushkas
                    firebaseManager.checkIfUserHaveOrder(){ hasOrder in
                        DispatchQueue.main.async {
                            if hasOrder {
                                buttonColor = Color.red
                                buttonDisabled = true
                            }
                            else {
                                buttonColor = Color.gosBlue
                                buttonDisabled = false
                            }
                            
                        }
                    }
                }
            }
            
        }
    }
}
