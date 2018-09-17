//
//  ViewController.swift
//  Dapp
//
//  Created by Ivan Grachev on 16/09/2018.
//  Copyright © 2018 com.grachyov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var selectWalletButton: UIButton!
    @IBOutlet weak var successView: UIView!
    
    private var address: String?
    private var schema: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        guard let schema = schema, let url = URL(string: "\(schema)://?address=qQP2ZBcAQ2y9HHsskDYrVF8hiyg2sp95CQ&amount=1&caller=standalone") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(success), name: NSNotification.Name("success"), object: nil)
    }
    
    @objc private func success() {
        successView.isHidden = false
    }
    
    @IBAction func selectWalletButtonTapped(_ sender: Any) {
        openExtension()
    }
    
    private func openExtension() {
        let item = NSExtensionItem()
        let attachment = NSItemProvider(item: "test" as NSSecureCoding, typeIdentifier: "qtum.provider.request")
        item.attachments = [attachment]
        let shareViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        shareViewController.excludedActivityTypes = [.airDrop, .openInIBooks, .postToFlickr, .postToVimeo, .addToReadingList, .assignToContact, .copyToPasteboard, .mail, .message, .postToFacebook, .postToTencentWeibo, .postToWeibo, .print, .saveToCameraRoll]
        shareViewController.completionWithItemsHandler = { activity, success, items, error in
            guard let item = (items as? [NSExtensionItem])?.first, let provider = item.attachments?.first as? NSItemProvider else { return }
            provider.loadItem(forTypeIdentifier: "qtum.provider.response", options: nil) { [weak self] result, error in
                guard let result = result as? String else { return }
                DispatchQueue.main.async {
                    let splitted = result.split(separator: " ")
                    
                    let address = String(splitted[0])
                    let schema = String(splitted[1])
                    
                    self?.address = address
                    self?.schema = schema
                    
                    self?.infoLabel.isHidden = false
                    self?.selectWalletButton.isHidden = true
                    self?.sendButton.isHidden = false
                    self?.infoLabel.text = address
                }
            }
        }
        present(shareViewController, animated: true)
    }

}

