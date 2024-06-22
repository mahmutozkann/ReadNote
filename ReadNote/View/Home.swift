import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore





struct HomeView: View {
   
    
    @State private var bookTitle: String = ""
    @State private var author: String = ""
    @State private var pageNumber: String = ""
    @State private var quote: String = ""
    @State private var totalChars = 0
    @State private var lastText = ""
    @State private var isButtonsDisabled: Bool = true
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        
            VStack(spacing: 20) {
                Text("Add Book Note")
                    .font(.largeTitle)
                    .padding(.top, 40)
                    
                ScrollView{
                    TextField("", text: $bookTitle, prompt: Text("Book Title").foregroundStyle(Color("TextFieldColor")))
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(Color("TextColor"))
                        .border(Color("BorderColor"))
                        .padding(.horizontal)
                        .onChange(of: bookTitle) { _ in
                            validateFields()
                        }
                    
                    TextField("", text: $author, prompt: Text("Author").foregroundStyle(Color("TextFieldColor")))
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(Color("TextColor"))
                        .border(Color("BorderColor"))
                        .padding(.horizontal)
                        .onChange(of: bookTitle) { _ in
                            validateFields()
                        }
                    
                    TextField("", text: $pageNumber, prompt: Text("Page Number").foregroundStyle(Color("TextFieldColor")))
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(Color("TextColor"))
                        .border(Color("BorderColor"))
                        .padding(.horizontal)
                        .onChange(of: pageNumber) { _ in
                            validateFields()
                        }
                        
                    TextEditor(text: $quote)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(.gray)
                        .foregroundColor(.white)
                        .font(Font.custom("palatino", size: 20, relativeTo: .body))
                        .frame(width: 350,height: 200)
                        .cornerRadius(25)
                        .onChange(of: quote, perform: { quote in
                            totalChars = quote.count
                            if totalChars <= 150 {
                                    lastText = quote
                                } else {
                                    self.quote = lastText
                                }
                        })
                        .onChange(of: quote) { _ in
                            validateFields()
                        }
                        .padding()
                    ProgressView("Chars: \(totalChars) / 150",value: Double(totalChars),total: 150)
                        .frame(width: 150)
                        .padding()
                        .accentColor(Color("Progress"))

                    Button(action: {
                        saveNoteToFirestore(title: bookTitle, author: author, pageNumber: pageNumber, quote: quote)
                        clearFields()
                    }) {
                        Label("Save Note", systemImage: "square.and.arrow.down")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isButtonsDisabled ? Color("ButtonColor") : Color("DisabledButton"))
                            .cornerRadius(100)
                            .padding(.horizontal)
                    }
                    .disabled(isButtonsDisabled)
                    .alert("Saved success", isPresented: $showAlert) {
                        Button("OK"){}
                    }
                    
                    
                    Button(action: {
                        //Generate the text to image
                        generateImage()
                        saveNoteToFirestore(title: bookTitle, author: author, pageNumber: pageNumber, quote: quote)
                        clearFields()
                    }) {
                        
                        Label("Generate It!", systemImage: "pencil.and.outline")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isButtonsDisabled ? Color("ButtonColor") : Color("DisabledButton"))
                            .cornerRadius(100)
                            .padding(.horizontal)
                    }
                    .disabled(isButtonsDisabled)
                    .alert("Saved success", isPresented: $showAlert) {
                        Button("OK"){}
                    }
                    Spacer()
                }
                .scrollDismissesKeyboard(.immediately)
                
            }
            .navigationBarBackButtonHidden(true)
            .onAppear{
                clearFields()
            }
            
    }
    
    private func validateFields() {
           isButtonsDisabled = bookTitle.isEmpty || pageNumber.isEmpty || quote.isEmpty
       }

    private func clearFields() {
        bookTitle = ""
        author = ""
        pageNumber = ""
        quote = ""
    }
    private func saveNoteToFirestore(title: String, author: String, pageNumber: String, quote: String){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Authentication failed")
            return
        }
        let db = Firestore.firestore()
        let bookNote = BookNote(id:nil, title: title, author: author, pageNumber: pageNumber, quote: quote)
        
        do{
            let _ = try db.collection("users").document(userID).collection("bookNotes").addDocument(from: bookNote)
            showAlert = true
            print("Note saved successfully")
        }catch{
            print("Error saved notes to Firestore: \(error.localizedDescription)")
        }
    }
    
    private func generateImage() {
        let imageSize = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let parchmentImage = UIImage(named: "parchmentTexture")!
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.draw(parchmentImage.cgImage!, in: CGRect(origin: .zero, size: imageSize))
            
            guard let customFont = UIFont(name: "Palatino", size: 64) else {
                print("Özel yazı tipi yüklenemedi!")
                return
            }
            
            let titleFontSize: CGFloat = 60
            let authorFontSize: CGFloat = 40
            let quoteFontSize: CGFloat = 40
            let pageFontSize: CGFloat = 40
            
            let bookTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: customFont.withSize(titleFontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: centeredParagraphStyle()
            ]
            
            let authorAttributes: [NSAttributedString.Key: Any] = [
                .font: customFont.withSize(authorFontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: centeredParagraphStyle()
            ]
            
            let pageNumberAttributes: [NSAttributedString.Key: Any] = [
                .font: customFont.withSize(pageFontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: centeredParagraphStyle()
            ]
            
            let quoteAttributes: [NSAttributedString.Key: Any] = [
                .font: customFont.withSize(quoteFontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: centeredParagraphStyle()
            ]
            
            // Başlık (Kitap Adı) - En Üstte
            let titleRect = CGRect(x: 40, y: 80, width: imageSize.width - 80, height: 100)
            drawText(bookTitle, in: titleRect, attributes: bookTitleAttributes, context: cgContext)
            
            // Çizgi (Başlığın hemen altında)
            let lineYPosition = titleRect.maxY + 10
            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setLineWidth(2)
            cgContext.move(to: CGPoint(x: 40, y: lineYPosition))
            cgContext.addLine(to: CGPoint(x: imageSize.width - 40, y: lineYPosition))
            cgContext.strokePath()
            
            // Yazar Adı (Çizginin hemen altında)
            let authorRect = CGRect(x: 40, y: lineYPosition + 20, width: imageSize.width - 80, height: 50)
            drawText(author, in: authorRect, attributes: authorAttributes, context: cgContext)
            
            // Alıntı (Sayfanın ortalarına doğru)
            let quoteRect = CGRect(x: 40, y: imageSize.height / 2 - 100, width: imageSize.width - 80, height: 400)
            drawText(quote, in: quoteRect, attributes: quoteAttributes, context: cgContext)
            
            // Sayfa Numarası (En altta)
            let pageRect = CGRect(x: 40, y: imageSize.height - 100, width: imageSize.width - 80, height: 50)
            drawText(pageNumber, in: pageRect, attributes: pageNumberAttributes, context: cgContext)
        }
        saveImageToPhotos(image: image)
    }

    private func drawText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any], context: CGContext) {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textStorage = NSTextStorage(attributedString: attributedString)
        let textContainer = NSTextContainer(size: rect.size)
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let drawingPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
        
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: drawingPoint)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: drawingPoint)
    }

    private func centeredParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }

    private func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    
}

#Preview {
    HomeView()
}
