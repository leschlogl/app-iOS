import CommonLibrary
import SwiftUI
import YouTubeLibrary

struct FavouritesView: View {
    @Environment(\.theme) private var theme: ThemeColor
    @EnvironmentObject private var viewModel: MainViewModel

    var body: some View {
        ZStack {
            (theme.main.background.color ?? .black)
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            viewModel.selectedTab = .home
                        }
                    }, label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .tint(theme.tertiary.background.color)
                            .imageScale(.large)
                    })

                    Text("Favoritos")
                        .font(.largeTitle)
                        .foregroundColor(theme.text.terciary.color)

                    Spacer()
                }

                VideosFullscreenView(favorite: true, theme: theme)
                    .environment(\.managedObjectContext, viewModel.videosViewModel.context)

                Spacer()
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

#Preview {
    FavouritesView()
}
