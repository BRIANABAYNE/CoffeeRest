//
//  ContentView.swift
//  CoffeeRest
//
//  Created by Briana Bayne on 1/7/24.
//


// framework
import CoreML
import SwiftUI

// ContentView conforms to View - basic protocol
struct ContentView: View {
    @State private var wakeup = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Text("When do you want to wake up?")
                    .font(.headline)
                    .foregroundColor(Color(hue: 0.891, saturation: 1.0, brightness: 1.0, opacity: 0.921))
                
                DatePicker("Please enter a time", selection: $wakeup, displayedComponents: 
                        .hourAndMinute)
                .labelsHidden()
                Text("Desired amount of sleep")
                    .font(.headline)
                    .foregroundColor(Color(hue: 0.961, saturation: 0.916, brightness: 0.868, opacity: 0.902))
                    
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                    .foregroundColor(Color(hue: 0.733, saturation: 1.0, brightness: 1.0))
                    
                Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 1...20)
            }
            // title
            .navigationTitle("Better Rest").colorMultiply(.teal)
            .font(.footnote)
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
            // ?? 0 Nil Coal if it can't be read
            // times 60 to minutes and 60 to get seconds
            let hour = (components.hour ?? 0) * 60 * 60
            // times 60 for minutes
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeup - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is... "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
