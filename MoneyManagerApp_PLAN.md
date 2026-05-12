# Money Manager App - Complete Planning Document

## Executive Summary

A personal offline-first money manager app with cross-platform native support (Android + Linux/ZorinOS). The app manages four independent data domains: monthly transactions, financial stats (assets/liabilities/income/expenses), loans tracking, and user preferences. All features work offline with optional cloud sync via Vercel + Neon/MongoDB. Theme: creamy yellow with artistic fonts, dark mode support.

**Tech Stack:**
- **Frontend**: Flutter (Dart) - native Android + Linux desktop
- **Backend**: Vercel Serverless Functions (Node.js)
- **Database**: Neon (PostgreSQL) or MongoDB Atlas Free Tier
- **Offline Storage**: Hive/GetStorage (local), SQLite on-device
- **Deployment**: APK (Android) + Linux binary (desktop)

---

## Architecture Overview

### Data Domains (Independent)
1. **Monthly Tracker** - Transaction log (income/outgoing) with tags
2. **Stats Manager** - Separate financial tracking (Assets, Liabilities, Income, Expenses)
3. **Loans Manager** - Give/take loans between people
4. **Settings & Tags** - Cross-domain: theme, sync, tag definitions

### Technology Stack
- **Frontend**: Flutter (Dart) - single codebase for Android & Linux
- **Backend**: Vercel Edge/Serverless Functions (Node.js)
- **Database**: Neon (PostgreSQL) or MongoDB Atlas Free Tier
- **Offline Storage**: Hive or GetStorage (local key-value), SQLite for structured data
- **Deployment**: APK via Gradle (Android), Snap or AppImage (Linux)

### Sync Strategy
- **Default**: Sync OFF, requires 4-digit PIN to enable
- **PIN**: 1-year token validity, auto-refreshes
- **Conflict Resolution**: Latest-timestamp-wins
- **Offline Mode**: Full functionality, queues changes, pushes on reconnection
- **Manual Sync**: Settings page trigger

---

## Data Models & Schemas

### 1. Transaction (Monthly Tracker)
```
{
  id: UUID
  type: "income" | "outgoing"
  name: string
  description: string (optional)
  amount: number
  tagId: UUID
  date: ISO8601
  createdAt: timestamp
  updatedAt: timestamp
  syncStatus: "synced" | "pending" | "conflict"
}
```

### 2. StatEntry (Stats Manager)
```
{
  id: UUID
  cardType: "assets" | "liabilities" | "income" | "expenses"
  name: string
  amount: number
  createdAt: timestamp
  updatedAt: timestamp
  syncStatus: "synced" | "pending"
}
```

### 3. Loan (Loans Manager)
```
{
  id: UUID
  personId: UUID
  amount: number
  type: "given" | "taken"
  description: string (optional)
  date: ISO8601
  createdAt: timestamp
  updatedAt: timestamp
  syncStatus: "synced" | "pending"
}
```

### 4. Person (Loans Manager)
```
{
  id: UUID
  name: string
  netBalance: number (calculated from loans)
  createdAt: timestamp
  updatedAt: timestamp
}
```

### 5. Tag (Cross-Domain)
```
{
  id: UUID
  name: string
  color: hex (e.g., #FFD700)
  createdAt: timestamp
  updatedAt: timestamp
}
```

### 6. UserSettings
```
{
  userId: "local" (single user)
  theme: "light" | "dark"
  autoSync: boolean
  syncToken: string | null
  syncTokenExpiry: ISO8601 | null
  lastSyncTime: ISO8601
  language: string
}
```

### 7. SyncMetadata
```
{
  id: UUID
  recordId: UUID
  recordType: "transaction" | "statEntry" | "loan" | "person" | "tag"
  lastModified: timestamp
  isDeleted: boolean
  version: number
}
```

---

## Logical Issues & Solutions

### Issue 1: Data Independence vs. Consistency
**Problem**: Three separate data domains mean no referential integrity; stats aren't auto-calculated from transactions.
**Solution**: Clear user mental model - each domain is intentionally independent. Stats are manual tracking (planned income vs. actual), Monthly Tracker is actual log, Loans is separate accounting.

### Issue 2: Tag Management
**Problem**: Tags are used in Monthly Tracker but managed in Settings; other domains don't use tags.
**Solution**: Tags are global, but only Monthly Tracker requires them. Settings page provides tag CRUD with preview; Add Transaction dialog has quick "manage tags" link.

### Issue 3: PIN Security
**Problem**: 4-digit PIN (10,000 combinations) is weak for real security.
**Solution**: Acceptable for single-user app. PIN doesn't encrypt data, just gates sync. Recommend device-level security (Android fingerprint, Linux sudo) handles rest. Document this as a trade-off.

### Issue 4: Offline Sync Conflicts
**Problem**: User modifies transaction on Android, then Linux, both go offline, both sync—which wins?
**Solution**: Latest-timestamp-wins. Each record has `updatedAt`. On sync conflict, server compares timestamps. UI shows "last modified on [device]" to set expectations.

### Issue 5: Expandable List Items
**Problem**: Clicking item A expands description, then clicking item B should collapse A and expand B. Managing state?
**Solution**: Single expandedId state variable. onClick sets expandedId to current item; if already expanded, toggles close.

### Issue 6: Tag Color Contrast
**Problem**: User picks dark color + text becomes unreadable.
**Solution**: Calculate HSL lightness on color input. If lightness < 50%, use white text; else black. Implement in tag preview and all displays.

### Issue 7: Loans Net Calculation
**Problem**: Should "given" count as positive or negative?
**Solution**: Convention - given = positive (asset owed to you), taken = negative (debt). Net = given - taken. Person's balance = sum of all their loans with this sign convention.

---

## UI/UX Specifications

### Design System
- **Primary Theme**: Creamy Yellow (#FFF8DC, #FFFACD), Accent Gold
- **Secondary**: Clean whites, soft grays
- **Dark Mode**: Dark charcoal (#1a1a1a), cream text, muted gold
- **Typography**: Artistic fonts (e.g., Poppins, Outfit, Comfortaa)
- **Feel**: Fast, snappy, minimal, clean

### Navigation
- **Mobile (Android)**: Bottom navigation bar (5 tabs)
  - Dashboard
  - Monthly Tracker
  - Stats
  - Loans
  - Settings
- **Desktop (Linux)**: Sidebar navigation (can switch to top nav or drawer)

### Page Layouts

#### Monthly Tracker
```
[Upper Section]
- Custom graph (user provides reference)
- Controls: month navigation, view options
- Legend: Blue=Income, Red=Outgoing

[Lower Section]
- Add Income / Add Outgoing buttons (prominent)
- Transaction list:
  - Each entry: [Date] [Name] [Amount] [Tag]
  - Tap to expand → show Description (if exists)
  - Long press → open detail page (edit/delete/full info)
  - Sorted: earliest first
```

#### Stats Manager
```
[4 Cards, Scrollable]
- Card: Assets
  - List of entries (name + amount)
  - Add button
  - Prominent total (gold text)
  
- Card: Liabilities
  - Same structure
  - Total (red text)
  
- Card: Income
  - Same structure
  - Total (blue text)
  
- Card: Expenses
  - Same structure
  - Total (red text)

[Outside Cards]
- Net Total = (Assets - Liabilities) + (Income - Expenses)
- Text color: green if positive, red if negative
```

#### Loans Manager
```
[Upper Section - 2 columns (stack on mobile)]
- Left Column:
  - Card: Total Given (gold, prominent number)
  - Card: Total Taken (red, prominent number)
- Right Column:
  - Card: Net = Given - Taken (green/red based on sign)

[Lower Section]
- People list:
  - Each: [Name] [Net Balance]
  - Add Person button
  - Tap to open detail page
  - Long press to edit/delete

[Detail Page (opened from list)]
- Person name
- Net Balance (prominent)
- List: Give & Take history
  - Tap to expand/see description
  - Long press to edit/delete
- Add button (opens transaction entry)
  - Fields: amount, type (give/take), description
```

#### Dashboard
```
[3 Summary Sections]
1. Monthly Tracker Summary
   - Graph preview / recent balance
   - "View Details" link
   
2. Stats Summary
   - Cards preview (Assets, Liabilities, etc.)
   - "View Details" link
   
3. Loans Summary
   - Net given/taken
   - Top 3 people
   - "View Details" link
```

#### Settings
```
[Theme Section]
- Toggle: Light / Dark mode
- Preview

[Sync Section]
- Status: Connected / Not Connected / Syncing
- Toggle: Auto Sync (only if PIN entered)
- Manual Sync button
- PIN Entry dialog (to enable/change PIN)
- Last Sync Time

[Tags Section]
- List of all tags (as pills)
- Each tag pill shows:
  - Name + color
  - Edit icon
  - Delete icon
- Add Tag button

[Edit Tag Dialog]
- Name input
- Color picker (12 presets + hex input)
- Preview with correct text contrast
- Save/Cancel

---

## Implementation Steps

### Phase 1: Project Setup & Infrastructure

#### INSTRUCTION: Initialize Flutter Project
```bash
# Install Flutter SDK if not already done
# https://flutter.dev/docs/get-started/install

# Create new Flutter project
flutter create --org com.yourname money_manager_app
cd money_manager_app

# Initialize git
git init
git add .
git commit -m "Initial Flutter project"
```

#### INSTRUCTION: Set Up Project Structure
Create folders in your Flutter project:
```
money_manager_app/
├── lib/
│   ├── main.dart
│   ├── models/              # Data classes
│   ├── services/            # Business logic (storage, sync, API calls)
│   ├── screens/             # Full-page screens
│   ├── widgets/             # Reusable UI components
│   ├── utils/               # Helpers, constants, themes
│   └── providers/           # State management (GetX or Provider)
├── pubspec.yaml
├── backend/                 # Vercel functions (separate repo or folder)
│   └── api/
├── docs/
└── README.md
```

#### INSTRUCTION: Add Flutter Dependencies to pubspec.yaml
The AI will provide the complete list, but core ones will include:
- `hive` or `get_storage` - offline storage
- `http` or `dio` - API calls to Vercel
- `uuid` - generating unique IDs
- `intl` - date/time formatting
- `provider` or `get` - state management
- `sqflite` - SQLite for structured data (optional, Hive usually sufficient)

#### INSTRUCTION: Set Up Vercel Project for Backend
1. Create `/backend` folder (can be same repo or separate)
2. Inside, create `api/` folder for serverless functions
3. Create `vercel.json` configuration
4. Go to vercel.com, create new project, link to your repo
5. Set environment variables in Vercel dashboard

#### INSTRUCTION: Set Up Database
Choose one:

**Option A: Neon (PostgreSQL - Recommended)**
1. Go to neon.tech, sign up
2. Create new project
3. Copy connection string
4. Add to Vercel env: `DATABASE_URL=<connection_string>`
5. Note: Neon has generous free tier (5 GB storage)

**Option B: MongoDB Atlas**
1. Go to mongodb.com, sign up
2. Create free M0 cluster
3. Create database user + whitelist your IPs
4. Copy connection string
5. Add to Vercel env: `MONGODB_URI=<connection_string>`

#### INSTRUCTION: Set Up Linux Desktop Build
```bash
# Enable desktop support (if not already)
flutter config --enable-linux-desktop

# Build Linux dependencies
flutter pub get
```

---

### Phase 2: Frontend Architecture & Offline Storage

#### PROMPT: Design Flutter App Architecture for Offline-First Money Manager

You are designing the architecture for a personal money manager Flutter app that must work offline-first on Android and Linux desktop.

Requirements:
- Framework: Flutter (Dart)
- Offline storage: Hive (key-value) or GetStorage for settings, SQLite via sqflite for structured data
- Data domains: Monthly Transactions, Stats Entries, Loans, Tags, Settings
- Sync strategy: Latest-timestamp-wins, manual and auto-sync
- Devices: Android native, Linux desktop (Flutter)
- UI: Bottom navigation on mobile, sidebar/drawer on desktop

Task:
1. Propose a state management approach for Flutter (Provider, Riverpod, GetX, or BLoC - recommend the best fit)
2. Design the offline storage layer using Hive + sqflite:
   - Which data goes in Hive (key-value) vs sqflite (structured)?
   - How to structure Hive boxes for each data domain
   - SQLite schema for Transaction, StatEntry, Loan, Person, Tag, SyncMetadata
3. Specify data sync state tracking:
   - How to mark records as pending/synced/conflict
   - How to detect if app is online/offline
   - How to queue changes when offline and push when online
4. Design the API service layer:
   - How to call Vercel backend functions
   - Error handling for network failures
   - Retry strategy for failed sync
5. Document how to handle the 4-digit PIN for sync:
   - Where to store PIN token (secure storage)
   - Token validation logic (1-year expiry)
   - How PIN gates the sync feature

Provide:
- High-level component/service architecture diagram (text-based)
- Directory structure for lib/ folder
- List of services/classes to build (StorageService, SyncService, AuthService, ApiService)
- Data flow diagrams for offline→online sync and online→offline scenarios
- State management setup guide

Do NOT write code yet, only architectural patterns and specifications.

---

#### PROMPT: Define Data Storage Layer for Flutter

You are designing the offline storage layer for a Flutter money manager app.

Context:
- Data models: Transactions, StatEntries, Loans, Persons, Tags, Settings, SyncMetadata
- Needs to work offline using Hive (key-value) and SQLite (structured data)
- Must track sync status for each record
- Target: Android (native) and Linux (desktop)

Task:
1. Design which storage mechanism for each data type:
   - Hive boxes (simple, fast, good for settings and caching)
   - SQLite tables (structured queries, complex filtering)
   - Recommendation on what should go where
2. Define complete SQLite schema:
   - CREATE TABLE statements for each entity
   - Include columns: id (UUID), createdAt, updatedAt, syncStatus, isDeleted
   - Define relationships (Loan→Person, Transaction→Tag, etc.)
3. Specify Hive box structure:
   - Settings box: theme, autoSync, lastSyncTime, etc.
   - How to structure tag list in Hive vs SQLite
4. Define data access patterns (queries needed):
   - Transactions: by date range, by month, by tag, list all
   - StatEntries: by card type, calculate totals per type
   - Loans: by person, by date, calculate net per person
   - Persons: list all, calculate balance per person
   - Tags: list all, get by ID
   - Sync: find all pending records, find all to delete, get last sync time
5. Specify sync metadata tracking:
   - How to track which records changed locally
   - How to detect conflict (record modified locally and on server)
   - How to mark records as deleted (soft delete) for sync
6. Document CRUD operations for each entity:
   - Operations: create, read, update, delete, list, query with filters
   - Should return results immediately from local storage
   - All operations must be fast (< 100ms for UI responsiveness)

Output:
- SQLite schema (all CREATE TABLE statements)
- Hive box names and key structure
- Data access interface/contract (method signatures for StorageService)
- List of queries with their parameters
- Sync metadata tracking logic

---

### Phase 3: UI Implementation - Monthly Tracker

#### PROMPT: Build Monthly Tracker Screen in Flutter

You are building the Monthly Tracker screen for an offline-first money manager Flutter app.

Features:
- Upper section: Custom graph showing monthly income vs. outgoing
- Graph controls: Previous/next month navigation, month/year display
- Lower section: Transaction list (income in blue, outgoing in red)
- List interactions:
  - Tap transaction to expand and show description
  - Long press to open detail page
  - Add Income / Add Outgoing buttons

Design requirements:
- Creamy yellow theme (#FFF8DC, #FFFACD) with dark mode support
- Artistic fonts (Poppins, Outfit, Comfortaa)
- Fast, snappy, minimal feel
- Bottom navigation on mobile, sidebar on desktop

Data:
- Transaction model: { id, type (income/outgoing), name, description, amount, tagId, date, createdAt, updatedAt }
- Tag model: { id, name, color (hex), createdAt, updatedAt }

Task:
1. Build CustomMonthlyGraph widget:
   - StatefulWidget that displays monthly data
   - Inputs: List<Transaction> for current month, DateTime currentMonth
   - Features:
     - Bar chart or area chart (visual style: clean, minimal)
     - Shows total income (blue) vs outgoing (red)
     - Previous/Next month buttons with month/year label
     - Optional: sparkline showing 3-month trend
   - No external charting library required (build simple with CustomPaint or Stack)
   - Responsive (full width on mobile, constrained on desktop)

2. Build TransactionList widget:
   - StatefulWidget showing all transactions for the month
   - List items display: [Date] [Name] [Amount] [Tag]
   - Colors: income amounts in blue, outgoing in red
   - Tags displayed as colored pills with white/black text (based on HSL lightness)
   - Expand/collapse: tap item to expand and show full description
   - Only one item expanded at a time (manage with expandedId state)
   - Sorted by date (earliest first)
   - Long-press detection: opens TransactionDetailPage

3. Build AddTransactionModal:
   - StatefulWidget modal dialog
   - Two buttons above: "Add Income" (blue) | "Add Outgoing" (red)
   - Form fields:
     - Name (required, TextField)
     - Description (optional, TextField, multiline)
     - Amount (required, number input)
     - Tag (dropdown/selector, required)
     - Quick link: "Manage Tags" → opens tag settings
   - Validation: name not empty, amount > 0
   - Submit: calls StorageService.createTransaction()
   - Visual feedback: loading spinner on submit
   - Success: toast notification, close modal, refresh transaction list
   - Error: show error message in modal

4. Build TransactionDetailPage:
   - Opened via long-press on list item
   - Display all transaction details
   - Buttons: Edit, Delete
   - Edit button: opens form pre-filled with transaction data
   - Delete button: confirmation dialog, then delete
   - Back button: returns to MonthlyTracker screen

Requirements:
- Use state management (GetX or Provider for access to StorageService)
- All operations save immediately to local storage (offline-first)
- Handle loading states with spinners/skeleton loaders
- Empty state: friendly message if no transactions for the month
- Images: you may provide a reference image for the graph style; AI adapts design accordingly

Output: Modular widgets in lib/screens/monthly_tracker/ with:
- monthly_tracker_screen.dart (main screen)
- widgets/custom_monthly_graph.dart
- widgets/transaction_list.dart
- widgets/add_transaction_modal.dart
- pages/transaction_detail_page.dart

---

#### PROMPT: Implement Custom Graph Component

[User will provide reference image here. Deepseek will review image and build the graph component to match design.]

You are building a custom graph component for the Monthly Tracker page.

Reference image provided by user shows the graph style.

Task:
1. Analyze the provided reference image
2. Recreate the visual style using Canvas or SVG (your recommendation)
3. Build component to accept:
   - Monthly data: { date, income, outgoing }
   - Current month/year state
   - Responsive width
4. Include:
   - Visual legend (blue=income, red=outgoing)
   - Grid lines or minimalist background
   - Smooth animations on month change
   - Tooltips on hover (show exact amounts)
5. Handle edge cases:
   - No data for month
   - Very large/small amounts (scaling)
   - Dark mode adjustments

Output modular component in /frontend/src/components/CustomGraph.js

---

### Phase 4: UI Implementation - Stats Manager

#### PROMPT: Build Stats Manager Page

You are building the Stats Manager page for a personal money manager app using OpenCode.

Features:
- 4 independent cards: Assets, Liabilities, Income, Expenses
- Each card:
  - Scrollable list of entries (name + amount)
  - Add button to add new entry
  - Prominent total at top/bottom
  - Long press entry to edit/delete
- Outside cards: Net Total calculation
  - Formula: Net = (Assets - Liabilities) + (Income - Expenses)
  - Color: green if positive, red if negative

Design:
- Creamy yellow theme, dark mode support
- Fast, snappy, minimal
- Cards should be visually distinct (possibly different accent colors per card type)

Task:
1. Build the 4 card components (Assets, Liabilities, Income, Expenses)
   - Each card has identical structure
   - Pass cardType prop to differentiate
   - Card total color varies by type:
     - Assets: gold
     - Liabilities: red
     - Income: blue
     - Expenses: red
2. Implement list within each card:
   - Entry item: [Name] [Amount] [Delete button on hover/long-press]
   - Long-press opens edit modal
   - Tap to select (highlight)
3. Implement Add Entry modal:
   - Fields: Name, Amount (number input)
   - Validation: both required, amount > 0
   - Submit adds to card's list
4. Calculate and display Net Total:
   - Assets - Liabilities + Income - Expenses
   - Update in real-time as entries change
   - Color dynamically based on sign
5. State management:
   - Local state for each card's entries
   - Persist to local storage (Phase 2 layer)
   - Handle offline: all changes sync when online

Output modular components in /frontend/src/pages/StatsManager/

---

### Phase 5: UI Implementation - Loans Manager

#### PROMPT: Build Loans Manager Page

You are building the Loans Manager page for a personal money manager app.

Features:
- Upper section: Summary cards (desktop: 2 columns, mobile: stack)
  - Left: Total Given (gold, prominent)
  - Left: Total Taken (red, prominent)
  - Right: Net = Given - Taken (green/red based on sign)
- Lower section: People list
  - Each person: [Name] [Net Balance]
  - Tap to open detail page
  - Add Person button
  - Delete/edit on long-press

Detail page (opened from list):
- Person's name
- Net balance (given - taken, prominent)
- List of loans with this person:
  - Tap entry to expand/show description
  - Long press to edit/delete
- Add Loan button (opens form)
  - Fields: amount, type (give/take), description
  - Defaults to "give" or "take" based on context

Design:
- Creamy yellow, dark mode
- Responsive (mobile: stacked cards, desktop: side-by-side)
- Fast, minimal

Task:
1. Build summary cards (Given, Taken, Net):
   - Calculate totals from all loans in app
   - Show prominent large number + label
   - Color code: gold, red, green/red
   - Responsive grid (1x2 mobile, 1x3 desktop)
2. Build person list:
   - Person item: [Name] [Net balance (green/red)]
   - No person name duplication (validate on add)
   - Add Person button → dialog (just name, required)
   - Long press → edit (rename) or delete (with confirmation)
3. Build person detail page:
   - Header: Person name, Net balance
   - Tabs or sections: "Loans history"
   - List entries: [Amount] [Type: Give/Take] [Date] [Description on expand]
   - Long press to edit/delete
   - Add Loan button → form:
     - Fields: amount (required, >0), type (give/take radio), description (optional)
     - Submit adds to person's loan list
4. State & calculations:
   - Loan list linked to person
   - Person's balance = sum of all their loans (give +, take -)
   - App totals = sum of all people's give and take
   - Real-time updates
5. Offline persistence:
   - All data saved to local storage (Phase 2 layer)
   - Sync tracked per loan and person

Output modular components in /frontend/src/pages/LoansManager/

---

### Phase 6: UI Implementation - Dashboard & Settings

#### PROMPT: Build Dashboard Page

You are building the Dashboard page for a personal money manager app.

Purpose: Overview of all three data domains (Monthly Tracker, Stats, Loans) with quick summaries and navigation links.

Sections:
1. Monthly Tracker Summary
   - Show: Last 3 months trend (small graph or sparkline)
   - Show: Current month total income and outgoing
   - Button: "View Details" → goes to Monthly Tracker page
2. Stats Summary
   - Show: Current totals for Assets, Liabilities, Income, Expenses (4 mini cards)
   - Show: Net total
   - Button: "View Details" → goes to Stats page
3. Loans Summary
   - Show: Total given and total taken (2 mini cards)
   - Show: Net
   - Show: Top 3 people (by balance)
   - Button: "View Details" → goes to Loans page

Design:
- Creamy yellow, dark mode
- Cards with subtle shadows
- Scrollable (one column)
- Fast load (summaries computed from local storage)

Task:
1. Build dashboard layout (scrollable column)
2. Build each summary section component:
   - Accept summary data as props
   - Render mini cards with key metrics
   - Include "View Details" navigation buttons
3. Implement data computation:
   - Pull totals from local storage
   - Calculate trends (monthly tracker: last 3 months)
   - Rank people by balance (loans)
4. Responsive design:
   - Mobile: full-width summary cards, stacked sections
   - Desktop: can use 2-column layout if preferred
5. Navigation:
   -