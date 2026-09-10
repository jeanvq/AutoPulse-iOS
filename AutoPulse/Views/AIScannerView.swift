import SwiftUI

struct AIScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var diagnosis = ""
    @State private var isAnalyzing = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()

            NavigationStack {
                ZStack {
                    AppTheme.backgroundPrimary.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 24) {

                            // Header
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentGlow)
                                        .frame(width: 70, height: 70)
                                    Image(systemName: "cpu.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                Text("AI Scanner")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Take a photo of your dashboard warning light and get an AI diagnosis")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top)

                            // Image preview
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.backgroundCard)
                                    .frame(height: 220)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.textMuted, lineWidth: 1)
                                    )

                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(AppTheme.textMuted)
                                        Text("No image selected")
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Buttons
                            HStack(spacing: 12) {
                                Button(action: { showCamera = true }) {
                                    Label("Camera", systemImage: "camera.fill")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(AppTheme.accent)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                Button(action: { showImagePicker = true }) {
                                    Label("Gallery", systemImage: "photo.fill")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(AppTheme.backgroundCard)
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textMuted, lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)

                            // Analyze button
                            Button(action: analyze) {
                                Group {
                                    if isAnalyzing {
                                        HStack(spacing: 10) {
                                            ProgressView().tint(.white)
                                            Text("Analyzing...").fontWeight(.semibold)
                                        }
                                    } else {
                                        Label("Analyze Warning Light", systemImage: "magnifyingglass")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(selectedImage != nil ? AppTheme.warning : AppTheme.textMuted)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(selectedImage == nil || isAnalyzing)
                            .padding(.horizontal)

                            // Result
                            if showResult && !diagnosis.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppTheme.success)
                                        Text("AI Diagnosis")
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.textPrimary)
                                    }
                                    Text(diagnosis)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(AppTheme.backgroundCard)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.success.opacity(0.4), lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
    }

    func analyze() {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        showResult = false
        diagnosis = ""

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            isAnalyzing = false
            return
        }

        let base64Image = imageData.base64EncodedString()

        let payload: [String: Any] = [
            "model": "claude-haiku-4-5",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": "You are an automotive expert. Analyze this dashboard warning light image and provide: 1) What warning light this is, 2) What it means, 3) How urgent it is (low/medium/high), 4) What the driver should do. Be concise and clear. If this is not a dashboard warning light, say so."
                        ]
                    ]
                ]
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            isAnalyzing = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(Config.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isAnalyzing = false
                guard let data = data, error == nil else {
                    diagnosis = "Error connecting to AI. Please try again."
                    showResult = true
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let first = content.first,
                   let text = first["text"] as? String {
                    diagnosis = text
                    showResult = true
                } else {
                    diagnosis = "Could not parse AI response. Please try again."
                    showResult = true
                }
            }
        }.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
