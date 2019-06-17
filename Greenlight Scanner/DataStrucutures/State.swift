import UIKit

// MARK: - State

/// Barcode scanner state.
enum State {
  case scanning
  case processing
  case unauthorized
  case notFound
  case found
}

/// State message provider.
public struct StateMessageProvider {
  public var scanningText = localizedString("Scan an Item")
  public var processingText = localizedString("Verifying")
  public var unathorizedText = localizedString("Not Authorized")
  public var notFoundText = localizedString("Barcode not found")
  public var foundText = "Successfully logged barcode"
  
  func makeText(for state: State) -> String {
    switch state {
    case .scanning:
      return scanningText
    case .processing:
      return processingText
    case .unauthorized:
      return unathorizedText
    case .notFound:
      return notFoundText
    case .found:
      return foundText
    }
  }
}

// MARK: - Status

/// Status is a holder of the current state with a few additional configuration properties.
struct Status {
  /// The current state.
  let state: State
  /// Flag to enable/disable animation.
  let animated: Bool
  /// Text that overrides a text from the state.
  let text: String?

  /**
   Creates a new instance of `Status`.
   - Parameter state: State value.
   - Parameter animated: Flag to enable/disable animation.
   - Parameter text: Text that overrides a text from the state.
   */
  init(state: State, animated: Bool = true, text: String? = nil) {
    self.state = state
    self.animated = animated
    self.text = text
  }
}
