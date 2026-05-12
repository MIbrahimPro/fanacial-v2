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
- [ ] 7.8 Set Vercel env vars (DATABASE_URL, API_SECRET)
- [ ] 7.9 Backend first deployment to Vercel

## Phase 8: Sync Layer (Flutter Side)
- [ ] 8.1 Build `ApiService` (HTTP client for Vercel API)
- [ ] 8.2 Build `SyncService` (push pending records, pull server data, resolve conflicts)
- [ ] 8.3 Build PIN auth flow (4-digit PIN, 1-year token, flutter_secure_storage)
- [ ] 8.4 Build connectivity listener (online/offline detection)
- [ ] 8.5 Wire auto-sync toggle + manual sync button into Settings
- [ ] 8.6 Update all screens to show sync status indicator

## Phase 9: Polish + Build
- [ ] 9.1 Add page transition animations
- [ ] 9.2 Accessibility pass (contrast ratios, touch targets, labels)
- [ ] 9.3 Build APK for Android (`flutter build apk`)
- [ ] 9.4 Build Linux binary (`flutter build linux`)
- [ ] 9.5 Final lint + cleanup

## Phase 10: Deployment
- [ ] 10.1 Initialize git repo and commit
- [ ] 10.2 Create Vercel project and link to repo
- [ ] 10.3 Deploy backend
- [ ] 10.4 Connect Flutter app to production API
- [ ] 10.5 Final end-to-end test
