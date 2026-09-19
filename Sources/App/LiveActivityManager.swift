import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var isActive = false
    @Published var errorMessage: String?

    private var activity: Activity<LiveContentAttributes>?

    init() {
        activity = Activity<LiveContentAttributes>.activities.first
        isActive = activity != nil
    }

    var activitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func startOrUpdate(state: LiveContentAttributes.ContentState) async {
        errorMessage = nil

        guard activitiesEnabled else {
            errorMessage = "설정에서 실시간 현황을 허용해 주세요."
            return
        }

        do {
            let content = ActivityContent(state: state, staleDate: nil)
            if let activity {
                await activity.update(content)
            } else {
                let attributes = LiveContentAttributes(activityID: UUID().uuidString)
                activity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
            }
            isActive = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func end(state: LiveContentAttributes.ContentState) async {
        guard let activity else { return }
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.end(content, dismissalPolicy: .immediate)
        self.activity = nil
        isActive = false
    }
}

