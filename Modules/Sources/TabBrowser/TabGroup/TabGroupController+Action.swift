import Bookmarks
import Foundation
import SettingsUI
import TabManageUI
import UIKit
import Utils

extension TabGroupController {
    public enum Action: String, ActionProtocol {
        public static var category: String { "tabGroup" }

        case bookmarks
        case showMenuSheet
        case tabs
        case settings

        #if DEBUG
        case debugEditBookmark
        #endif

        public typealias BuilderContext = TabGroupController

        public var definition: ActionDefinition<Action> {
            switch self {
            case .bookmarks:
                return buildDefinition(
                    title: NSLocalizedString("Bookmarks", comment: ""),
                    image: UIImage(systemName: "book"),
                    builder: { definition, controller in
                        weak var controller = controller

                        return ExecutableAction(definition: definition) { _ in
                            guard let controller else { return }

                            let vc = BookmarkManageController(
                                bookmarkManager: controller.dependency.bookmarkManager,
                                onOpen: { _ in }
                            )
                            controller.present(vc, animated: true)
                        }
                    }
                )

            case .showMenuSheet:
                return buildDefinition(
                    title: NSLocalizedString("Show Menu", comment: ""),
                    image: UIImage(systemName: "ellipsis"),
                    builder: { definition, context in
                        weak var context = context

                        return ExecutableAction(definition: definition) { _ in
                            context?.showMenuSheet()
                        }
                    }
                )

            case .tabs: return
                buildDefinition(
                    title: NSLocalizedString("List Tabs", comment: ""),
                    image: UIImage(systemName: "square.on.square",
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)),
                    builder: { definition, controller in
                        weak var controller = controller

                        return ExecutableAction(definition: definition) { context in
                            guard let controller, let group = controller.group else { return }

                            let tabManageController = TabManageController(group: group)

                            (context.viewController ?? controller)?.present(tabManageController, animated: true)
                        }
                    }
                )

            case .settings:
                return buildDefinition(
                    title: NSLocalizedString("Settings", comment: ""),
                    image: UIImage(systemName: "gear"),
                    builder: { definition, controller in
                        weak var controller = controller

                        return ExecutableAction(definition: definition) { context in
                            guard let controller else { return }

                            let settingsController = SettingsController(dependency: controller.dependency)

                            (context.viewController ?? controller)?.present(settingsController, animated: true)
                        }
                    }
                )

            #if DEBUG
            case .debugEditBookmark:
                return buildDefinition(
                    title: "[Debug] Edit Bookmark",
                    builder: { definition, controller in
                        weak var controller = controller

                        return ExecutableAction(definition: definition) { context in
                            guard let controller else { return }

                            let editController = BookmarkItemEditController(
                                bookmarkManager: controller.dependency.bookmarkManager,
                                editingItem: controller.dependency.bookmarkManager.favoritesFolder.children.last!
                            ) { _ in
                            }

                            (context.viewController ?? controller)?.present(editController, animated: true)
                        }
                    }
                )
            #endif
            }
        }
    }

    public func executableAction(action: any ActionProtocol) -> ExecutableAction? {
        if let action = action as? Action {
            return action.buildExecutable(context: self)

        } else if let action = action as? TabViewController.Action,
                  let activeVC = activeVC
        {
            return action.buildExecutable(context: activeVC)
        }

        return nil
    }

    public static func supportedActions() -> [any ActionProtocol] {
        return TabGroupController.Action.allCases + TabViewController.Action.allCases
    }
}
