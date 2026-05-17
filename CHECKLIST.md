# Money Manager App — Implementation Checklist

## Phase 0: Project Scaffold
- [x] 0.1 Create Flutter project in `money_manager_app/`
- [x] 0.2 Set up folder structure (`models/`, `services/`, `screens/`, `widgets/`, `utils/`, `providers/`)
- [x] 0.3 Add dependencies to `pubspec.yaml` (hive, uuid, provider, intl, path_provider, flutter_secure_storage)
- [x] 0.4 Build theme system — light + dark theme, color tokens (creamy yellow + gold accent)
- [x] 0.5 Scaffold `main.dart` with Provider setup (ThemeProvider, StorageService), and bottom navigation shell

## Phase 1: Offline Storage Layer + Data Models
- [x] 1.1 Define all Dart data models (Transaction, StatEntry, Loan, Person, Tag, UserSettings, SyncMetadata)
- [x] 1.2 Set up Hive — type adapters, box registration, initialization
- [x] 1.3 Build `StorageService` — full CRUD for all entities (local-only)
- [x] 1.4 Build `TagService` — tag CRUD with HSL-based contrast utility
- [x] 1.5 Build `DateHelpers` — month navigation, formatting helpers
- [x] 1.6 Write unit tests for StorageService (17 tests, all passing)

## Phase 2: Monthly Tracker Screen
- [x] 2.1 Build `CustomMonthlyGraph` widget (bar chart with CustomPainter, Y-axis scaling, legend)
- [x] 2.2 Build `TransactionList` widget (expandable items with single-expand state)
- [x] 2.3 Build `TransactionListItem` widget (tag pills with contrast-aware text, edit/delete action chips)
- [x] 2.4 Build `MonthNavigator` widget (prev/next buttons, Today chip)
- [x] 2.5 Build `MonthlySummaryCard` widget (Income | Outgoing | Net in card)
- [x] 2.6 Build `AddTransactionModal` (bottom sheet, income/outgoing toggle, form with tag selector, date picker, validation)
- [x] 2.7 Build `TransactionDetailPage` (full details, edit opens modal, delete with confirmation)
- [x] 2.8 Wire up state management (`MonthlyTrackerProvider` — month nav, CRUD, dailyData)
- [x] 2.9 Write provider tests (13 tests: navigation 6, transactions 6, tags 1)
- [x] 2.10 Update `main.dart` — register provider, add route for detail page

## Phase 3: Stats Manager Screen
- [x] 3.1 Build `StatsCard` reusable widget (scrollable list, prominent total, add button, color variants)
- [x] 3.2 Build `StatsManagerScreen` (4 cards + net total outside cards + empty states)
- [x] 3.3 Build `AddStatModal` (bottom sheet, supports create + edit mode, validation)
- [x] 3.4 Net total calculation + display (green/red based on sign)
- [x] 3.5 Wire up `StatsProvider` + StorageService
- [x] 3.6 Write provider tests (5 tests)

## Phase 4: Loans Manager Screen
- [x] 4.1 Build summary cards (Given gold, Taken red, Net green/red — responsive LayoutBuilder)
- [x] 4.2 Build person list + `AddPersonDialog` (create/edit modes, name uniqueness)
- [x] 4.3 Build `PersonDetailPage` (net balance header, loan history, expansion tiles, edit/delete)
- [x] 4.4 Build `AddLoanModal` (amount, give/take toggle, description, date picker)
- [x] 4.5 Loan net calculation logic (per person + app totals)
- [x] 4.6 Wire up `LoansProvider` + StorageService + `/person-detail` route
- [x] 4.7 Write provider tests (7 tests)

## Phase 5: Dashboard + Settings Screens
- [x] 5.1 Build `DashboardScreen` (3 summary sections with "View Details" tab switching)
- [x] 5.2 Build `SettingsScreen` — theme toggle (light/dark with persistence)
- [x] 5.3 Build sync placeholder section (disabled UI with "Coming soon")
- [x] 5.4 Build tag management UI (pills with contrast text + delete icon, dialog with 12 colors + hex, preview, protect last tag)
- [x] 5.5 Wire up settings persistence (Hive box + StorageService)

## Phase 6: Navigation Shell + Platform Adaptation
- [x] 6.1 `NavigationProvider` for tab switching across all screens
- [x] 6.2 `NavigationBar` at bottom for mobile (<600px)
- [x] 6.3 `NavigationRail` on left for desktop (≥600px)
- [x] 6.4 Updated `main.dart` with all 6 providers + 2 routes

## Phase 7: Backend Setup (Vercel + Neon)
- [x] 7.1 Create Vercel project and `vercel.json` + `package.json`
- [x] 7.2 Drop old Neon tables + create full schema (6 tables: transactions, stat_entries, loans, people, tags, sync_metadata)
- [x] 7.3 Build CRUD endpoints for all 5 entity types (10 files)
- [x] 7.4 Build `/api/sync` endpoint (push with timestamp comparison + conflicts, pull since last_sync)
- [x] 7.5 Create `api/_db.js` and `api/_auth.js` shared modules
- [x] 7.6 Create `setup.js` runner script + execute against Neon
- [x] 7.7 Fix tag delete bug in TagListSection (use TagService instead of raw StorageService)
- [x] 7.8 Set Vercel env vars (DATABASE_URL, API_SECRET, JWT_SECRET)
- [x] 7.9 Backend first deployment to Vercel

## Phase 8: Sync Layer (Flutter Side)
- [x] 8.1 Build `ApiService` (HTTP client for POST /api/sync)
- [x] 8.2 Build `SyncService` (push pending records, pull data, mark synced)
- [x] 8.3 Build PIN auth flow (4-digit PIN set/verify, 1-year token, flutter_secure_storage)
- [x] 8.4 Build `ConnectivityService` (online/offline detection via connectivity_plus)
- [x] 8.5 Build `SyncProvider` (wraps SyncService + PinService for UI)
- [x] 8.6 Rewrite `SyncSection` in Settings (enable/disable, auto toggle, manual sync, status)
- [x] 8.7 Build `PinEntryDialog` (4-field input, first-time confirm, verify mode)
- [x] 8.8 Update `main.dart` — register SyncProvider, init ConnectivityService
- [x] 8.9 Write PinService tests (7 tests: set, verify, failure, token lifecycle)
- [x] 8.10 Create `AppConstants` for configurable API base URL

## Phase 9: Polish + Build
- [x] 9.1 Add empty state illustrations (EmptyState widget, all screens)
- [x] 9.2 Add page transition animations (CupertinoPageTransitionsBuilder)
- [x] 9.3 Add accessibility (Semantics labels on empty states, buttons)
- [x] 9.4 Build APK for Android — `app-release.apk` (52.7MB)
- [x] 9.5 Build Linux binary — `build/linux/x64/release/bundle/`
- [x] 9.6 Create SETUP.md with install instructions for both platforms

## Phase 10: Deployment
- [x] 10.1 Initialize git repo and commit
- [x] 10.2 Create Vercel project and link to repo
- [x] 10.3 Deploy backend
- [x] 10.4 Connect Flutter app to production API (`fanacial-v2.vercel.app`)
- [x] 10.5 Final end-to-end test (sync API responds)

## Phase 11: Improvements & Fixes (May 2026)
- [x] 11.1 Increase theme color saturation
- [x] 11.2 Fix transaction sorting (newest first)
- [x] 11.3 Move Stats page net total to top
- [x] 11.4 Implement Bento grid layout for Loans summary
- [x] 11.5 Refactor Monthly Tracker graph to line chart (cumulative net)
- [x] 11.6 Fix keyboard overlap in modals (SingleChildScrollView)
- [x] 11.7 Fix Manage Tags redirection
- [x] 11.8 Move person actions to AppBar in Loans detail
- [x] 11.9 Refactor loan history items (long press actions, title row description)
- [x] 11.10 Refactor Sync to use JWT and DB-stored PIN
- [x] 11.11 Improve online/offline detection (real host lookup)
- [x] 11.12 Add swiping gestures (tabs and months)
- [x] 11.13 Add initial loading spinner
- [x] 11.14 Improve Dashboard visuals (Net Worth card)
- [x] 11.15 Add Stats Comparison Bar
- [x] 11.16 Desktop polish (sidebar, fonts, right-click)

## Phase 12: Stability, Packaging & Sync Fixes (May 2026)
- [x] 12.1 Fix sync foreign-key ordering bug (`transactions.tag_id`) by server push ordering
- [x] 12.2 Return `sync_time` from backend and persist server-based incremental cursor
- [x] 12.3 Reduce sync payload by only pushing changed `people` and `tags` since last sync
- [x] 12.4 Refactor Loans summary cards for stable responsive layout (no flex/unbounded height issues)
- [x] 12.5 Improve app naming (remove underscore label/title for Android + Linux window title)
- [x] 12.6 Generate and wire custom Linux app icon (`assets/icons/app_icon.png`)
- [x] 12.7 Add Debian package build script and desktop entry (`money-manager_1.0.0_amd64.deb`)
- [x] 12.8 Verify with `flutter test`, `flutter analyze`, `flutter build apk --release`, and Linux release/deb build
