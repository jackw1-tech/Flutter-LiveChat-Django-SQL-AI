# Flutter LiveChat Django SQL AI Template

A generic full-stack template for a chat app where users ask questions in natural language and the AI answers by querying a local on-device SQLite database.

The repository intentionally ships with:

- no business-specific prompt
- no business data
- an empty SQLite placeholder at `flutter-chat/assets/data/local_database.sqlite`
- a schema prompt template at `backend/schema_context.md`

Clone it, add your own local database, describe your schema, and run it for your own use case.

## How It Works

1. The user types a question in the Flutter app.
2. Flutter sends the message to the Django backend.
3. Django stores the chat message in its own backend database.
4. Django asks OpenAI to produce a safe SQLite `SELECT` query using your schema context.
5. Flutter runs that SQL locally against the bundled SQLite database.
6. Flutter sends only the query rows back to Django.
7. Django asks OpenAI to format a natural-language answer.
8. Flutter shows the final answer in the chat.

Your full local SQLite database is not uploaded to the backend. Only the returned query rows are sent back for answer formatting.

## Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| State management | BLoC + Pine architecture |
| Local database | SQLite via `sqflite` |
| Backend API | Python, Django, Django Ninja |
| Chat storage | Django ORM, SQLite locally or PostgreSQL in production |
| AI | OpenAI API, configurable model |

## Project Structure

```text
.
├── backend/
│   ├── chat/                 # API endpoints, AI service, chat storage
│   ├── config/               # Django settings and urls
│   ├── schema_context.md     # Replace with your SQLite schema context
│   ├── requirements.txt
│   └── .env.example
└── flutter-chat/
    ├── assets/data/
    │   └── local_database.sqlite  # Empty placeholder DB
    └── lib/
        ├── local_db/         # Bundled SQLite loader
        ├── network/          # Django API client and local SQL runner
        ├── repositories/     # Multi-step chat pipeline
        ├── state_management/ # Chat BLoC
        └── ui/               # Chat screens and widgets
```

## Configure Your App

### 1. Replace the Local Database

Replace:

```text
flutter-chat/assets/data/local_database.sqlite
```

with your own SQLite database.

Keep the same path/name, or update these constants in `flutter-chat/lib/local_db/local_database.dart`:

```dart
static const String _assetPath = 'assets/data/local_database.sqlite';
static const String _dbFileName = 'local_database.sqlite';
```

### 2. Describe the Schema for the AI

Edit:

```text
backend/schema_context.md
```

Remove `NO_SCHEMA_CONFIGURED` and describe exactly what the model may query:

- tables or views
- column names and types
- relationships
- meanings of important fields
- date formats
- currencies or units
- statuses, enums, categories, and business rules
- columns or tables that must not be used

Until this file is configured, the backend prompt tells the model to return:

```sql
SELECT 'unsupported' AS reason;
```

### 3. Configure the Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

Fill in `.env`:

```env
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini
AI_SCHEMA_CONTEXT_PATH=schema_context.md
```

For local development, `DATABASE_URL` can stay empty and Django will use `backend/db.sqlite3` for chat transcripts. In production, set `DATABASE_URL` to a PostgreSQL connection string.

### 4. Configure Flutter

```bash
cd flutter-chat
flutter pub get
flutter run
```

Set the backend URL in `flutter-chat/lib/other/contants/api_contants.dart`:

| Target | URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000/api` |
| iOS simulator / macOS | `http://127.0.0.1:8000/api` |
| Physical device | `http://<your-lan-ip>:8000/api` |

## Safety Notes

The backend prompt asks the model for `SELECT` statements only. The Flutter SQL runner also rejects mutating SQL before execution. This is still a template, so review the prompt, schema context, and SQL guardrails before using it with sensitive data.

If your real SQLite database contains private data, do not commit it to a public repository.
