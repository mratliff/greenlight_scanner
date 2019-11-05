//
//  ViewController.swift
//  Greenlight Scanner
//
//  Created by Mike Ratliff on 6/14/19.
//  Copyright © 2019 Mike Ratliff. All rights reserved.
//

//
//  ViewController.swift
//  Greenlight
//
//  Created by Mike Ratliff on 6/13/19.
//  Copyright © 2019 Mike Ratliff. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftPhoenixClient

class ViewController: UIViewController {
    static let url = "ws://172.16.3.177:4000/socket/websocket"
//  static let url = "ws://192.168.7.255:4000/socket/websocket"
    var socket = Socket(url)
    var topic: String = "inventory_verification:1"
    var scanChannel: Channel!

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var statusView: UITextView!
    @IBAction func startInventoryScan(_ sender: Any) {
        connectAndJoin()
        
    }
    
    private func connectAndJoin() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
      print("In")
        socket = Socket(ViewController.url, params: ["email": email, "password": password])
        print("Out")
        self.scanChannel = socket.channel(topic, params: ["status":"joining"])
      print("In and out")
        self.scanChannel
            .join()
            .delegateReceive("ok", to: self) { (self, _) in
              print("got it")
                self.addText("Joined Channel")
                let viewController = self.makeBarcodeScannerViewController()
                viewController.title = "Inventory Scanning"
                self.navigationController?.pushViewController(viewController, animated: true)
            }.delegateReceive("error", to: self) { (self, message) in
              print("error")
                self.addText("Failed to join channel: \(message.payload)")
        }
        self.socket.connect()
        
    }
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        return viewController
    }
    private func addText(_ text: String) {
        let updatedText = self.statusView.text?.appending(text).appending("\n")
        self.statusView.text = updatedText
    }

}

// MARK: - BarcodeScannerCodeDelegate

extension ViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        print("Symbology Type: \(type)")
        scanChannel
            .push("scanned", payload: ["barcode": code])
            .receive("scanned", callback: { (payload) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    controller.resetWithMessage(message: "Logged Inventory Verification of \(code)")
                }
            })
          .receive("barcode_not_found", callback: { (payload) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              controller.resetWithMessage(message: "Barcode: \(code) not found in system")
            }
          })
          .receive("already_scanned", callback: { (payload) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              controller.resetWithMessage(message: "Barcode: \(code) has already been scanned in this Inventory Verification")
            }
          })


    }
}

// MARK: - BarcodeScannerErrorDelegate

extension ViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

// MARK: - BarcodeScannerDismissalDelegate

extension ViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
