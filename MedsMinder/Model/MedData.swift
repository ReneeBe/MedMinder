//
//  MedData.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/15/21.
//


//import Foundation
//
//class MedData: ObservableObject {
//    private static var documentsFolder: URL {
//        do {
//            return try FileManager.default.url(for: .documentDirectory,
//                                               in: .userDomainMask,
//                                               appropriateFor: nil,
//                                               create: false)
//        } catch {
//            fatalError("Can't find documents directory.")
//        }
//    }
//
//    private static var fileURL: URL {
//        return documentsFolder.appendingPathComponent("meds.data")
//    }
//
//    @Published var meds: [Med] = []
//
//    func load() {
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let data = try? Data(contentsOf: Self.fileURL) else {
//                #if DEBUG
//                DispatchQueue.main.async {
//                    self?.meds = Med.data
//                }
//                #endif
//                return
//            }
//            guard let medications = try? JSONDecoder().decode([Med].self, from: data) else {
//                fatalError("Can't decode saved med data.")
//            }
//            DispatchQueue.main.async {
//                self?.meds = medications
//            }
//        }
//    }
//    func save() {
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let meds = self?.meds else { fatalError("Self out of scope") }
//            guard let data = try? JSONEncoder().encode(meds) else { fatalError("Error encoding data") }
//            do {
//                let outfile = Self.fileURL
//                try data.write(to: outfile)
//            } catch {
//                fatalError("Can't write to file")
//            }
//        }
//    }
//}


import Foundation
import CloudKit

class MedData: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }

    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("meds.data")
    }

    @Published var meds: [Med] = []

    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                #if DEBUG
                DispatchQueue.main.async {
                    self?.meds = Med.data
                }
                #endif
                return
            }
            do {
                let medications = try JSONDecoder().decode([Med].self, from: data)

                print(try! FileManager.default.url(for: .documentDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: false))

                DispatchQueue.main.async {
                    self?.meds = medications
                }
            } catch let error {
            print("caught: \(error)")
            }
        }
    }
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let meds = self?.meds else { fatalError("Self out of scope") }
            guard let data = try? JSONEncoder().encode(meds) else { fatalError("Error encoding data") }
            do {
                let outfile = Self.fileURL
                try data.write(to: outfile)
            } catch {
                fatalError("Can't write to file")
            }
        }
    }
}

