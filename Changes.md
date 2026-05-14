# Detailed Changes - May 14, 2026

## 1. Authentication & Sync System (Critical Refactor)
- **JWT Transition:** Replaced static API secret with a dynamic JWT-based authentication flow. Tokens are valid for 1 year.
- **Server-Side Security:**
    - Created `users` table in PostgreSQL to store PIN hashes.
    - Implemented `api/login.js` for secure PIN verification and token issuance.
    - Seeded initial PIN '1965' with an auto-transition to bcrypt hashing on first use.
- **Client-Side Sync Logic:**
    - Updated `SyncService` and `SyncProvider` to handle the new login flow.
    - Added `AUTH_REQUIRED` state handling which triggers the PIN dialog if a session expires or is missing.
    - Fixed typo in production API URL (`financial-v2.vercel.app`).
- **Improved Connectivity:** `ConnectivityService` now performs a real `InternetAddress.lookup` to ensure actual internet access, not just a local connection.

## 2. UI/UX Refinement
- **Theme & Branding:**
    - Increased saturation of the Creamy Yellow palette for a richer look.
    - Integrated **Outfit** font for headings and titles across the app.
    - Created a custom `_HexagonDollarIcon` for the desktop sidebar and app branding.
- **Dashboard Enhancements:**
    - Added a high-impact **Total Net Worth** card with a gold gradient and shadow.
    - Integrated summary labels for quick Stats and Loans insight.
- **Monthly Tracker:**
    - Refactored bar chart to a **Cumulative Line Chart** that tracks net balance over time.
    - Corrected transaction sorting to **Newest First**.
    - Fixed "Manage Tags" button to correctly navigate to the Settings tab.
- **Stats Manager:**
    - Moved **Net Total** to the top of the page for immediate visibility.
    - Added a **Visual Health Bar** comparing positive (Assets+Income) vs. negative (Liabilities+Expenses).
- **Loans Manager:**
    - Implemented a **Bento Grid** layout for summary cards.
    - Moved person management actions (Rename/Delete) to the AppBar actions menu.
    - Refactored loan list items to show descriptions in the primary row and handle actions via long-press/right-click.

## 3. Platform & Technical Improvements
- **Mobile UX:**
    - Wrapped all modals in `SingleChildScrollView` to prevent keyboard overlap issues.
    - Added **horizontal swiping** to change months in the tracker.
    - Added **swipe-to-navigate** between primary tabs using `PageView`.
- **Desktop Polish:**
    - Added **Right-Click (Secondary Tap)** support for all long-press actions.
    - Improved NavigationRail styling with better active states and background colors.
- **Performance:**
    - Added an initial **Loading Spinner** to prevent UI flickering during state initialization.
    - Fixed UUID validation errors in the backend API by ensuring correct data types are passed.

## 4. Backend & Database
- Updated `setup.sql` with the new `users` table and initial seed.
- Installed `jsonwebtoken` and `bcryptjs` dependencies.
- Refactored `api/_auth.js` to use JWT verification.
