//
//  TextViewController.swift
//  FSNotes
//
//  Created by sergey on 13.02.2023.
//

import UIKit
import PhotosUI

class TextViewController: UIViewController {
    
    var folderName: String?
    var noteName: String?
    var fileContents: NSAttributedString {
        get {
            guard let folderName = self.folderName, let noteName = self.noteName else {
                return .init()
            }
            return DocumentsModel.readAttr(from: noteName ,in: folderName)
        }
        set {
            guard let folderName = self.folderName, let noteName = self.noteName else {
                return
            }
            DocumentsModel.writeAttr(text: newValue, to: noteName, in: folderName)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configure()
    }
    
    @IBOutlet weak var textView: UITextView!
    
    //MARK: IBActions
    @IBAction func makeSmaller(_ sender: Any) {
        guard let font = textView.font,
              font.pointSize > 12 + 2
        else {
            return
        }
        textView.font = font.withSize(font.pointSize-2)
    }
    @IBAction func makeLarger(_ sender: Any) {
        guard let font = textView.font
        else {
            return
        }
        textView.font = font.withSize(font.pointSize+2)
    }
    @IBAction func changeFont(_ sender: Any) {
        showFontPicker(sender)
    }
    
    //MARK: Methods
    func configure() {
        textView.attributedText = fileContents
        textView.delegate = self
        textView.allowsEditingTextAttributes = true
        textView.typingAttributes = [
            .font:UIFont.systemFont(ofSize: 22),
        ]
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textView.frame.size.width, height: 44))
        let attachmentButton = UIBarButtonItem(
            image: UIImage(systemName: "paperclip"),
            style: .plain,
            target: self,
            action: #selector(imagePicker))
        toolBar.items = [attachmentButton]
        textView.inputAccessoryView = toolBar
    }
}

extension TextViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.fileContents = textView.attributedText
    }
    
    func addImage(_ results: [PHPickerResult]) {
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    let scaleFactor = self.textView.frame.width/self.textView.font!.pointSize
                    let att = NSTextAttachment()
                    att.image = UIImage(cgImage: image.cgImage!, scale: image.scale*scaleFactor, orientation: .up)
                    self.textView.textStorage.insert(NSAttributedString(attachment: att), at:self.textView.textStorage.length)
                    self.fileContents = self.textView.attributedText
                }
            }
        }
    }
}

extension TextViewController: UIFontPickerViewControllerDelegate {
    func showFontPicker(_ sender: Any) {
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let font = textView.font, let newFont = viewController.selectedFontDescriptor
        else {
            return
        }
        textView.font = .init(descriptor: newFont, size: font.pointSize)
    }
}

extension TextViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        addImage(results)
    }
    
    @objc func imagePicker() {
        let configuration = PHPickerConfiguration(photoLibrary: .shared())
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}
