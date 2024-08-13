# Gentoo SDK

Gentoo SDK is a powerful tool that enables you to integrate Gentoo, an interactive AI agent, into your iOS applications. This SDK provides the essential UI components and functionality to seamlessly incorporate Gentoo's capabilities into your mobile app.

## Installation

You can integrate Gentoo SDK into your project using Swift Package Manager

### Swift Package Manager

1. In Xcode, go to `File` -> `Add Packages...`
2. Enter the URL of this repository and select the latest version.
3. Add the package to your project.

## Usage

### GentooFloatingButton

This button is designed to encourage users to initiate a conversation with the AI agent.

When the button is tapped, the `GentooChatViewController` should be presented appropriately according to the client’s UI configuration

```swift
let floatingButton = GentooFloatingButton()
floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
view.addSubview(floatingButton)
floatingButton.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
    floatingButton.widthAnchor.constraint(equalToConstant: 300),
    floatingButton.heightAnchor.constraint(equalToConstant: 54)
])
```


### GentooChatViewController

The `GentooChatViewController` is the main interface for interacting with customers.

```swift
let chatViewController = GentooChatViewController()
navigationController?.pushViewController(chatViewController, animated: true)
```
