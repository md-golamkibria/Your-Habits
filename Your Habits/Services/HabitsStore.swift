import Foundation

@MainActor
final class HabitsStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    private var userId: UUID?

    func setUser(user: User?) {
        userId = user?.id
        load()
    }

    func add(_ habit: Habit) {
        habits.append(habit)
        save()
    }

    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        save()
    }

    private func storageKey() -> String? {
        guard let userId else { return nil }
        return "habits_\(userId.uuidString)"
    }

    private func load() {
        guard let key = storageKey() else {
            habits = []
            return
        }
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        } else {
            habits = []
        }
    }

    private func save() {
        guard let key = storageKey(),
              let data = try? JSONEncoder().encode(habits) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}