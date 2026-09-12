import SwiftUI

struct PDFShareView: UIViewControllerRepresentable {
    let pdfData: Data

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("AutoPulse_Report.pdf")
        try? pdfData.write(to: tempURL)

        let controller = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
