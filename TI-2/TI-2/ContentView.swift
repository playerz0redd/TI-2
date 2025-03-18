//
//  ContentView.swift
//  TI-1
//
//  Created by Pavel Playerz0redd on 18.02.25.
//

import SwiftUI



struct ContentView: View {
    @State var input : String
    @State var key : String
    @State var encodedString : String = ""
    @State var badKey = false
    @State var newKey = ""
    @State var alertMessage = ""
    @State var path = ""
    @State private var boolsArray : [Bool] = []
    @State var resultBools : [Bool] = []
    @State var startText : String = ""
    
    var body: some View {
        VStack {
            Text("Лабораторная работа 2")
                .font(.system(size: 15))
                .padding(.vertical, 30)
            HStack(spacing: 50) {
                VStack {
                    //Text("Введите текст")
                    //TextField("", text: $input, prompt: Text("some text"))
                }
                VStack {
                    Text("Введите ключ")
                    TextField("", text: $key, prompt: Text("some key"))
                }
                Text("Количество символов: \(key.count)")
                    .padding(.top, 15)
            }
            .textFieldStyle(.roundedBorder)
            .padding(.bottom, 20)
            .padding(.horizontal, 80)
            
            HStack(spacing: 30) {
                Button {
                    //input.removeAll(where: {$0 != "1" && $0 != "0"})
                    key.removeAll(where: {$0 != "1" && $0 != "0"})
                    if key.count <= 39 {
                        for i in 0..<(39 - key.count) {
                            key += String(Int.random(in: 0...1))
                        }
                        //key += String(repeating: String(Int.random(in: 0...1)), count: 39 - key.count)
                    } else {
                        key = String(key.prefix(upTo: key.index(key.startIndex, offsetBy: 39)))
                    }
//                    if input == "" || key.count != 39 {
//                        alertMessage = "Некорректный ключ либо данные"
//                        badKey = true
//                    } else {
                        var boolsKey = convertStringToBools(str: key)
                        
                        resultBools = algorithm(
                            data: boolsArray,
                            key: &boolsKey)
                        //newKey = convertBoolsToString(data: boolsKey)
                        if resultBools.count > 144 {
                            encodedString = "\nПервые 72 бит: " + convertBoolsToString(data: Array(resultBools.prefix(upTo: 72))) + "\n"
                            encodedString += "Последние 72 бит: " + convertBoolsToString(data: Array(resultBools.suffix(from: resultBools.count - 72)))
                            
                            newKey = "\nПервые 72 бит: " + convertBoolsToString(data: Array(boolsKey.prefix(upTo: 72))) + "\n"
                            newKey += "Последние 72 бит: " + convertBoolsToString(data: Array(boolsKey.suffix(from: boolsKey.count - 72)))
                        } else {
                            encodedString = convertBoolsToString(data: resultBools)
                            newKey = convertBoolsToString(data: boolsKey)
                        }
                    //}
                } label: {
                    Text("Результат")
                        .frame(width: 100, height: 20)
                }.disabled(boolsArray == [])
                
                OpenButton(input: $input, alertMessage: $alertMessage, badKey: $badKey, boolsArray: $boolsArray, newKey: $newKey, resultString: $encodedString)
                SaveButton(alertMessage: $alertMessage, badKey: $badKey, encodedString: $encodedString, boolsArray: $resultBools)
                    .disabled(encodedString == "")
            }
            
        }.padding(.bottom, 20)
        
        .alert(alertMessage, isPresented: $badKey) {
            Button("OK", role: .cancel) { }
        }
        
        Text("Исходные данные: " + input)
            .textSelection(.enabled)
            .font(.system(size: 15))
            .padding(.bottom, 20)
        
        Text("Биты ключа: \(newKey)")
            .textSelection(.enabled)
            .font(.system(size: 15))
            .padding(.bottom, 20)
        
        Text("Результат: \(encodedString)")
            .textSelection(.enabled)
            .font(.system(size: 15))
        Spacer()
    }
}

struct OpenButton: View {
    @State private var selectedFilePath: String?
    @State private var path = ""
    @Binding var input : String
    @Binding var alertMessage : String
    @Binding var badKey : Bool
    @Binding var boolsArray : [Bool]
    @Binding var newKey : String
    @Binding var resultString : String
    var body: some View {
        VStack {
            Button("Открыть файл") {
                openFileDialog()
                path = selectedFilePath ?? ""
                if path != "" {
                    do {
                        boolsArray = []
                        let fileURL = URL(fileURLWithPath: path)
                        let data : Data = try Data(contentsOf: fileURL)
            
                        boolsArray.reserveCapacity(data.count * 8)
                        
                        for byte in data {
                            for bitPosition in (0..<8).reversed() {
                                boolsArray.append((byte >> bitPosition) & 1 == 1)
                            }
                        }
                        newKey = ""
                        resultString = ""
                        input = boolsArray.count < 144 ? convertBoolsToString(data: boolsArray) : "\nПервые 72 бит: " + convertBoolsToString(data: Array(boolsArray.prefix(upTo: 72))) + "\nПоследние 72 бит: " + convertBoolsToString(data: Array(boolsArray.suffix(from: boolsArray.count - 72)))
                        //input = convertBoolsToString(data: Array(boolsArray.prefix(upTo: boolsArray.count > 60 ? 60 : boolsArray.count)))
                    }
                    catch {
                        alertMessage = "Некорректный файл"
                        badKey = true
                    }
                }
            }
        }
    }

    func openFileDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            selectedFilePath = panel.url?.path
        }
    }
}

struct SaveButton: View {
    @State private var selectedFilePath: String?
    @State private var path = ""
    @Binding var alertMessage : String
    @Binding var badKey : Bool
    @Binding var encodedString: String
    @Binding var boolsArray : [Bool]
    var body: some View {
        VStack {
            Button("Сохранить в файл") {
                openSaveDialog()
                path = selectedFilePath ?? ""
                let fileURL = URL(fileURLWithPath: path)
                if path != "" {
                    do {
                        let data = Data(getStringByBites(boolsArray: boolsArray))//getStringByBites(boolsArray: boolsArray)
                        //try data.write(to: fileURL, atomically: true, encoding: .windowsCP1252)
                        try data.write(to: fileURL)
//                        let utf8Data = encodedString.data(using: .utf8)
//                        let utfString = String(data: utf8Data!, encoding: .utf8)!
//                        try utfString.write(to: fileURL, atomically: true, encoding: .utf8)
                    }
                    catch {
                        alertMessage = "Некорректный файл"
                        badKey = true
                    }
                }
            }
        }
    }
    
    func getBiteValue(bools : [Bool]) -> UInt8 {
        var num : UInt8 = 0
        for i in (0..<8) {
            num = num << 1
            num += (bools[i] ? 1 : 0)
        }
        return num//String(data: Data([num]), encoding: .windowsCP1252)!
    }
    
    func getStringByBites(boolsArray : [Bool]) -> [UInt8] {
        var str = ""
        var arr : [UInt8] = []
        arr.reserveCapacity(boolsArray.count / 8)
        str.reserveCapacity(boolsArray.count / 8)
        for i in stride(from: 0, to: boolsArray.count - 7, by: 8) {
            arr.append(getBiteValue(bools: Array(boolsArray[i..<i+8])))
            //str.append(getBiteValue(bools: Array(boolsArray[i..<i+8])))
        }
        return arr
    }

    func openSaveDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            selectedFilePath = panel.url?.path
        }
    }
}



#Preview {
    //ContentView(input: "", key: "")
}
