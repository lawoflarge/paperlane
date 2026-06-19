import SwiftUI
import ContactsUI
import Contacts

/// Presents the system new-contact editor pre-filled from a parsed business card
/// (Pro). The user reviews and saves to Contacts; nothing is stored without consent.
struct ContactCardView: UIViewControllerRepresentable {
    let contact: CNContact
    var onClose: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onClose: onClose) }

    final class Coordinator: NSObject, CNContactViewControllerDelegate {
        let onClose: () -> Void
        init(onClose: @escaping () -> Void) { self.onClose = onClose }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            onClose()
        }
    }
}
