import Database
import Foundation

public struct ContentFilter: Identifiable, Hashable {
    public var setting: ContentFilterSetting
    public var encodedContentRuleList: String

    public var id: String { setting.id }
    public var name: String { setting.name }

    public init(
        setting: ContentFilterSetting,
        encodedContentRuleList: String
    ) {
        self.setting = setting
        self.encodedContentRuleList = encodedContentRuleList
    }
}
