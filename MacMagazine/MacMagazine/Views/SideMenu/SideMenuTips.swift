import CommonLibrary
import SwiftUI
import TipKit

public enum SideMenuTips: TipType {
	case subscriptions
	case settings
	case about

	@available(iOS 17, *)
	private static var subscriptionsTip: SubscriptionsTip { SubscriptionsTip() }

	@available(iOS 17, *)
	private static var settingsTip: SettingsTip { SettingsTip() }

	@available(iOS 17, *)
	private static var aboutTip: AboutTip { AboutTip() }
}

extension SideMenuTips {
	@ViewBuilder
	public func tipView(with theme: ThemeColor) -> some View {
		if #available(iOS 17, *) {
			Group {
				switch self {
				case .subscriptions:
					TipView(Self.subscriptionsTip, arrowEdge: .bottom)

				case .settings:
					TipView(Self.settingsTip, arrowEdge: .bottom)

				case .about:
					TipView(Self.aboutTip, arrowEdge: .bottom)
				}
			}
			.style(theme: theme)
		}
	}

	public func invalidate() {
		if #available(iOS 17, *) {
			switch self {
			case .subscriptions: Self.subscriptionsTip.invalidate(reason: .actionPerformed)
			case .settings: Self.settingsTip.invalidate(reason: .actionPerformed)
			case .about: Self.aboutTip.invalidate(reason: .actionPerformed)
			}
		}
	}

	public func show() {
		if #available(iOS 17, *) {
			switch self {
			case .subscriptions: SubscriptionsTip.isActive = true
			case .settings: SettingsTip.isActive = true
			case .about: AboutTip.isActive = true
			}
		}
	}
}
