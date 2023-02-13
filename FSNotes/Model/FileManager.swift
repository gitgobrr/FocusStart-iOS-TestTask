//
//  FileManager.swift
//  FocusStart
//
//  Created by sergey on 06.02.2023.
//

import SwiftUI

final public class DocumentsModel {
    static let fileManager = FileManager.default
    static let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    static var folders: [String] {
        guard let url = documentsDirectory else {
            return []
        }
        do {
            return try fileManager.contentsOfDirectory(at: url,
                                                       includingPropertiesForKeys: [],
                                                       options: [
                                                        .skipsHiddenFiles,
                                                        .skipsPackageDescendants,
                                                        .skipsSubdirectoryDescendants
                                                       ]).filter(\.hasDirectoryPath).map { $0.lastPathComponent }
        } catch {
            print("6",error)
            return []
        }
    }
    static func createFolder(with name: String) {
        guard let url = documentsDirectory?.appendingPathComponent(name) else {
            return
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            print("5",error)
            return
        }
    }
    static func notes(from folderName: String) -> [String] {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true) else {
            return []
        }
        do {
            return try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: []).filter({ url in
                let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
                //                print(type, url.lastPathComponent)
                return type == .rtfd ? true : false
            }).map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            print("4",error)
            return []
        }
    }
    static func create(file fileName: String, in folderName: String) {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(fileName, conformingTo: .rtfd) else {
            return
        }
        if !fileManager.fileExists(atPath: url.path) {
            writeAttr(text: .init(), to: fileName, in: folderName)
        }
    }
    static func remove(file fileName: String?, in folderName: String) {
        guard var url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true) else {
            return
        }
        if let fileName = fileName {
            url.appendPathComponent(fileName, conformingTo: .rtfd)
        }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("3",error)
        }
    }
    static func write(text string: String, to fileName: String, in folderName: String) {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(fileName, conformingTo: .utf8PlainText) else {
            return
        }
        do {
            try string.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("2",error)
        }
    }
    static func read(from fileName: String, in folderName: String) -> String {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(fileName, conformingTo: .utf8PlainText) else {
            return "wrong url"
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("1",error)
            return error.localizedDescription
        }
    }
    static func writeAttr(text string: NSAttributedString, to fileName: String, in folderName: String) {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(fileName, conformingTo: .rtfd) else {
            return
        }
        do {
            let fw = try string.fileWrapper(from: .init(location: 0, length: string.length), documentAttributes: [.documentType:NSAttributedString.DocumentType.rtfd])
            try fw.write(to: url, options: [.atomic,.withNameUpdating], originalContentsURL: url)
        } catch {
            print("22",error.localizedDescription)
        }
    }
    static func readAttr(from fileName: String, in folderName: String) -> NSAttributedString {
        guard let url = documentsDirectory?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(fileName, conformingTo: .rtfd) else {
            return NSAttributedString(string: "wrong url")
        }
        do {
            let attributedString = try NSAttributedString(url: url, options: [.documentType:NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
                return attributedString
        } catch {
            print("11",error)
            return NSAttributedString(string: error.localizedDescription)
        }
    }
}
