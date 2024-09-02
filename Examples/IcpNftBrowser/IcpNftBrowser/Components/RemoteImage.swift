//
//  RemoteImage.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import UIKit
import SVGView

struct RemoteImage: View {
    //@StateObject private var viewModel: ViewModel
    let url: URL?
    @State var error: Bool = false
    
    init(_ url: URL?) {
        self.url = url
//        _viewModel = StateObject(wrappedValue: ViewModel(url: url))
    }
    
    
    var body: some View {
        if error {
            Color.red
        } else if let url = url {
            MiniWebView(url: url, error: $error)
                .scaledToFill()
        } else {
            Image(uiImage: .remove)
                .resizable()
                .scaledToFit()
        }
        
//
//        switch viewModel.state {
//        case .initial, .loading:
//            ProgressView()
//        case .loaded(let imageType):
//            switch imageType {
//            case .empty:
//                Image(uiImage: .remove)
//                    .resizable()
//                    .scaledToFit()
//            case .image(let uiImage):
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//            case .svg(let data):
//                
//                MiniWebView(url: viewModel.url!)
//                //SVGView(data: data)
//                    .scaledToFit()
//            case .other(let data):
//                MiniWebView(url: viewModel.url!)
//                    .scaledToFit()
//            }
//            
//        case .error:
//            Color.red
//        }
    }
}
//
//private class ViewModel: ObservableObject {
//    enum RemoteImageState {
//        case initial
//        case loading(URLSessionDataTask)
//        case loaded(ImageType)
//        case error
//    }
//    enum ImageType {
//        case empty
//        case image(UIImage)
//        case svg(Data)
//        case other(Data)
//    }
//    let url: URL?
//    @Published var state: RemoteImageState = .initial
//    
//    init(url: URL?) {
//        self.url = url
//        Task { try await fetch() }
//    }
//    
//    @MainActor
//    func fetch() async throws {
//        guard let url = url else {
//            self.state = .loaded(.empty)
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            if data.starts(with: Self.svgHeader) {
//                state = .loaded(.svg(data))
//            } else if let image = UIImage(data: data) {
//                state = .loaded(.image(image))
//            } else {
//                state = .loaded(.other(data))
//            }
//        } catch {
//            state = .error
//        }
//    }
//    
//    private static let svgHeader = Data("<svg ".utf8)
//}

#Preview {
    RemoteImage(PreviewModels.mockSvgUrl)
}
