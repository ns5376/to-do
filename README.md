# TODO List – Flutter Web App

A polished TODO List application built with Flutter (web‑first), using local JSON seed data and local storage persistence.

## Demo

📹 **App Demo Video**: [`app_video.mov`](./app_video.mov)

Watch the demo video to see all features in action!  

## Project Structure

```text
to-do-1/
├── lib/
│   ├── main.dart              # App entry point, theme, routing
│   ├── models/
│   │   └── task.dart          # Task model (id, title, completed, createdAt)
│   ├── data/
│   │   ├── mock_task_api.dart # Loads seed tasks from assets/mock_tasks.json
│   │   └── task_repository.dart # CRUD + shared_preferences persistence
│   ├── state/
│   │   └── task_provider.dart # Riverpod state (tasks, filter, search, bulk ops)
│   ├── ui/
│   │   ├── components/
│   │   │   ├── app_bar.dart          # Top app bar: “TODO List”
│   │   │   ├── add_task_input.dart   # TextField + Add button with validation
│   │   │   ├── filter_segmented_control.dart # All / Completed / Pending toggle
│   │   │   └── task_list_item.dart   # Task card with inline edit, animations
│   │   └── screens/
│   │       └── home_screen.dart      # Main screen layout and logic
├── assets/
│   └── mock_tasks.json        # Seed tasks (matching the PRD JSON)                 
├── pubspec.yaml               # Flutter dependencies and asset config
└── analysis_options.yaml      # Lint rules
```

## Core Features (Must Have)

These implement the 5 core PRD features:

- ✅ **Add New Task**
  - User can create a new task with a title
  - Task has a creation timestamp
  - Empty titles are not allowed (basic validation)

- ✅ **View All Tasks**
  - Display all tasks in a list format
  - Show task title, creation date, and completion status
  - Tasks are initially fetched from mock backend data (`assets/mock_tasks.json`)

- ✅ **Mark Task as Complete/Incomplete**
  - User can toggle the completion status of a task
  - Clear visual distinction between completed and pending tasks (strikethrough + subdued style)

- ✅ **Delete Task**
  - User can remove a task from the list
  - Confirmation prompt before deletion

- ✅ **Filter Tasks**
  - Filter tasks by status: **All | Completed | Pending**
  - Active filter is visually indicated via segmented control

## Extra Features

On top of the core PRD, the app also includes:

- ✨ **Inline edit** task titles (click title → edit, Enter to save, Esc / click outside to cancel)
- ✨ **Undo delete** via snackbar (“Task deleted” + Undo)
- ✨ **Search** box that combines with the current filter
- ✨ **Smart ordering**: Pending first, Completed last; newest first within each group
- ✨ **Bulk actions**: “Mark all complete” and “Clear completed” (with confirmation)
- ✨ **Task counts + progress**: `X pending • Y completed` + thin completion bar



