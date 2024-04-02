import CommonLibrary
import SwiftUI
import UIComponentsLibrary

public struct CategoriesView: View {
	@Environment(\.theme) private var theme: ThemeColor
	@EnvironmentObject private var viewModel: NewsViewModel

	public init() {}

	public var body: some View {
		ForEach(NewsViewModel.Category.allCases, id: \.self) { category in
			Button(action: {},
				   label: {
                HStack {
                    Text(category.title)
                    Spacer()
                }
			})
		}
        .padding([.leading, .bottom])
    }
}

#Preview {
	CategoriesView()
		.environment(\.theme, ThemeColor())
		.environmentObject(NewsViewModel())
}
