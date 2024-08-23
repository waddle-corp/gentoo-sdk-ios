//
//  GentooJavascriptInterface.swift
//
//
//  Created by USER on 8/23/24.
//

import WebKit

protocol GentooInputFocusEventListenerDelegate: AnyObject {
    func didReceiveFocusEvent(listener: GentooInputFocusEventListener)
}

final class GentooInputFocusEventListener: NSObject, WKScriptMessageHandler {
  
  static let name: String = "sendInputFocusState"
  
  weak var delegate: GentooInputFocusEventListenerDelegate?
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      if message.name == Self.name {
          self.delegate?.didReceiveFocusEvent(listener: self)
      }
  }
}

