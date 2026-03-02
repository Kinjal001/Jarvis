# Jarvis — Data Model

## Entity Hierarchy

```
User
 └── Goal          (long-term outcome: "Become ML Engineer")
      └── Project  (concrete effort: "Complete Fast.ai course")
           ├── Subtask[]
           ├── TimeBlock[]
           └── Reminder[]

Task              (standalone one-time action)
RecurringTask     (repeats on schedule)
Habit             (behavior to build — tracked with streaks)
  └── HabitLog[]  (one entry per day per habit)
Daily             (pinned must-do items, shown every day)
Tag               (label for any entity)
AISession         (stored AI planning conversation)
```

## Entities

### Goal
| Field | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | FK → users |
| title | string | "Learn ML basics" |
| intention | string | Why this goal matters |
| deadline | date? | Optional target date |
| priority | int | 1 = highest. Used for ordering. |
| status | enum | active, completed, archived, paused |
| created_at | timestamp | |
| updated_at | timestamp | Required for sync conflict resolution |

### Project
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| goal_id | uuid? | Optional — project can be standalone |
| title | string | |
| description | string? | |
| deadline | date? | |
| priority | int | |
| status | enum | active, completed, archived, paused |
| resource_link | string? | URL or file path (e.g., Obsidian vault path) |
| created_at | timestamp | |
| updated_at | timestamp | |

### Subtask
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| project_id | uuid | FK → projects |
| title | string | |
| description | string? | |
| deadline | date? | |
| is_recurring | bool | |
| recurrence_rule | string? | iCal RRULE format (e.g., "FREQ=DAILY;COUNT=15") |
| status | enum | pending, in_progress, completed, skipped |
| sort_order | int | User-defined ordering |
| created_at | timestamp | |
| updated_at | timestamp | |

### Task (one-time)
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| title | string | |
| description | string? | |
| due_date | date? | |
| priority | int | |
| status | enum | pending, completed, skipped |
| is_recurring | bool | |
| recurrence_rule | string? | RRULE if recurring |
| created_at | timestamp | |
| updated_at | timestamp | |

### Habit
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| title | string | "Read 20 pages daily" |
| description | string? | |
| frequency | enum | daily, weekly, custom |
| recurrence_rule | string? | For custom frequency |
| start_date | date | When tracking began |
| target_streak | int? | Goal streak count |
| color | string | Hex color for UI |
| icon | string | Icon name |
| created_at | timestamp | |

### HabitLog
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| habit_id | uuid | FK → habits |
| date | date | The day this log is for |
| completed | bool | |
| note | string? | Optional completion note |

### Daily
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| title | string | "Morning workout" |
| description | string? | |
| sort_order | int | Display order |
| is_active | bool | Can be temporarily disabled |
| created_at | timestamp | |

### Tag
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| name | string | "health", "work", "learning" |
| color | string | Hex color |

### EntityTag (junction — polymorphic)
| Field | Type | Notes |
|---|---|---|
| entity_type | enum | goal, project, task, habit |
| entity_id | uuid | ID of the tagged entity |
| tag_id | uuid | FK → tags |

### Reminder
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| entity_type | enum | goal, project, task, habit, subtask |
| entity_id | uuid | |
| remind_at | timestamp | When to fire |
| is_sent | bool | Prevents duplicate sends |
| note | string? | Optional reminder message |

### TimeBlock
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| entity_type | enum | project, task, subtask |
| entity_id | uuid | |
| start_time | timestamp | |
| end_time | timestamp | |
| calendar_event_id | string? | For future calendar sync |

### AISession
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | |
| entity_type | enum? | What the AI helped with |
| entity_id | uuid? | The entity created/planned |
| prompt | text | What the user asked |
| response | text | Raw AI response |
| model_used | string | "gemini-1.5-flash", etc. |
| created_at | timestamp | |

## Design Decisions

1. **Soft deletes** — use `status = archived` instead of SQL DELETE. History is preserved.
2. **updated_at everywhere** — offline sync conflict resolution uses this field.
3. **RRULE for recurrence** — industry standard format. Same spec Google Calendar uses. Dart library: `rrule`.
4. **Polymorphic associations** (entity_type + entity_id) — one Tags table, one Reminders table, one TimeBlocks table, all shared across entity types.
5. **Priority as int** — clean re-ordering. 1 = top priority. No naming conflicts.
6. **resource_link as string** — handles both URLs (https://) and local paths (C:\Users\...). App decides how to open it.
