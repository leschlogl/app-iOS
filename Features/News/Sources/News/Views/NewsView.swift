import CommonLibrary
import Settings
import SwiftUI
import UIComponentsLibrary
import UIComponentsLibrarySpecial
import YouTubeLibrary

public enum NewsStyle {
    case home
    case carrousel
    case fullscreen
}

public struct NewsView: View {
    @Environment(\.theme) private var theme: ThemeColor
    @EnvironmentObject private var viewModel: NewsViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    private var width: CGFloat
    private var filter: NewsViewModel.Category
    private var style: NewsStyle
    
    public init(filter: NewsViewModel.Category,
                fit width: CGFloat,
                style: NewsStyle) {
        self.filter = filter
        self.width = width
        self.style = style
    }
    
    public var body: some View {
        VStack {
            headerView
            styleView
        }
        .padding(.horizontal)

        .navigationDestination(isPresented: Binding(get: { !viewModel.newsToShow.url.isEmpty },
                                                    set: { _, _ in })) {
            let webView = WebviewController(isPresenting: Binding(get: { !viewModel.newsToShow.url.isEmpty },
                                                                  set: { _, _ in }),
                                            removeAds: settingsViewModel.removeAds)
            
            Webview(title: viewModel.newsToShow.title,
                    url: viewModel.newsToShow.url,
                    isPresenting: Binding(get: { !viewModel.newsToShow.url.isEmpty },
                                          set: { _, _ in viewModel.newsToShow = NewsToShow(title: "", url: "", favorite: false) }),
                    navigationDelegate: webView,
                    userScripts: webView.userScripts,
                    cookies: webView.cookies(using: settingsViewModel),
                    scriptMessageHandlers: webView.scriptMessageHandlers,
                    userAgent: "/MacMagazine",
                    extraActions: extraActions,
                    backButton: AnyView(Image(systemName: "arrow.left.circle.fill")
                        .imageScale(.large)
                        .tint(theme.tertiary.background.color)
                    ))
            .navigationBarHidden(true)
        }
    }
}

extension NewsView {
    @ViewBuilder
    private var styleView: some View {
        switch style {
        case .home:
            NewsFullView(filter: .news, limit: 6)
        case .carrousel:
            CarrouselView(filter: filter, fit: width)
        case .fullscreen:
            ScrollView {
                NewsFullView(filter: filter)
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        if style == .fullscreen {
            HeaderFullView(title: filter.title, theme: theme) {
                withAnimation {
                    viewModel.options = .home
                }
            }
            .padding(.top)
            
        } else if filter.showHeader {
            HeaderView(title: filter.header, theme: theme) {
                withAnimation {
                    viewModel.options = .filter(category: filter)
                }
            }
        }
    }
}

extension NewsView {
    @ViewBuilder
    private var extraActions: some View {
        Button(action: {
            let favorite = UIActivityExtensions(title: "Favorito",
                                                image: UIImage(systemName: viewModel.newsToShow.favorite ? "star.fill" : "star")) { _ in
                //				Favorite().updatePostStatus(using: link) { [weak self] isFavorite in
                //					self?.post?.favorito = isFavorite
                //				}
            }
            
            let customCopy = UIActivityExtensions(title: "Copiar Link", image: UIImage(systemName: "link")) { items in
                for item in items {
                    guard let url = URL(string: "\(item)") else {
                        continue
                    }
                    UIPasteboard.general.url = url
                }
            }
            
            let items: [Any] = [viewModel.newsToShow.title, viewModel.newsToShow.url]
            
            Share().present(at: self, using: items, activities: [favorite, customCopy])
        }, label: {
            Image(systemName: "square.and.arrow.up.on.square.fill")
                .imageScale(.large)
                .tint(theme.tertiary.background.color)
        })
    }
}

#Preview("news") {
    let viewModel = NewsViewModel(inMemory: true)
    return NavigationStack {
        ScrollView {
            NewsView(filter: .news, fit: .infinity, style: .home)
                .environment(\.managedObjectContext, viewModel.mainContext)
                .environmentObject(viewModel)
                .environmentObject(SettingsViewModel())
                .environment(\.theme, ThemeColor())
        }
    }
    .task {
        try? await viewModel.getNews()
    }
}

#Preview("highlights") {
    let viewModel = NewsViewModel(inMemory: true)
    return ScrollView {
        NewsView(filter: .highlights, fit: 320, style: .carrousel)
            .environment(\.managedObjectContext, viewModel.mainContext)
            .environmentObject(viewModel)
            .environmentObject(SettingsViewModel())
            .environment(\.theme, ThemeColor())
    }
    .task {
        try? await viewModel.getNews()
    }
}

#Preview("appletv") {
    let viewModel = NewsViewModel(inMemory: true)
    return ScrollView {
        NewsView(filter: .appletv, fit: 380, style: .carrousel)
            .environment(\.managedObjectContext, viewModel.mainContext)
            .environmentObject(viewModel)
            .environmentObject(SettingsViewModel())
            .environment(\.theme, ThemeColor())
    }
    .task {
        try? await viewModel.getNews()
    }
}

#Preview("reviews") {
    let viewModel = NewsViewModel(inMemory: true)
    return ScrollView {
        NewsView(filter: .reviews, fit: 380, style: .carrousel)
            .environment(\.managedObjectContext, viewModel.mainContext)
            .environmentObject(viewModel)
            .environmentObject(SettingsViewModel())
            .environment(\.theme, ThemeColor())
    }
    .task {
        try? await viewModel.getNews()
    }
}
