# FinanceV2 Project Instructions

## General Principles
- **Offline-First:** All functionality must work without an internet connection.
- **Sync:** PIN-gated sync using latest-timestamp-wins conflict resolution.
- **Design:** Creamy yellow theme (#FFF8DC, #FFFACD), artistic fonts, snappy and minimal feel.
- **Platforms:** Native Android (ZorinOS/Linux also supported via Flutter Desktop).

## Development Workflow
- **Frontend:** Located in `money_manager_app/`. Use `provider` for state management and `hive` for local storage.
- **Backend:** Located in `money_manager_app/backend/`. Vercel serverless functions with PostgreSQL (Neon).
- **Testing:** Unit tests for services and providers are mandatory.

## Naming Conventions
- Dart: Follow standard Flutter/Dart naming (camelCase for variables, PascalCase for classes).
- API: CamelCase or kebab-case as established in `backend/api/`.

## Reference Documentation
- Architecture: `MoneyManagerApp_PLAN.md`
- Requirements: `RequirmentsMaster.txt`
- Progress: `CHECKLIST.md`
