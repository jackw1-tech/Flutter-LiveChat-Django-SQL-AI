# Flutter LiveChat Django SQL AI

A full-stack chat application where the user asks questions in natural language and the AI answers by querying a local on-device database — without ever sending the raw data to an external server.

---

## How it works

1. The user types a question in the Flutter app
2. The message is sent to the Django backend, which persists it on Supabase
3. The backend forwards the question to OpenAI, which replies with a SQL query
4. Flutter receives the SQL and runs it against a local SQLite database
5. The query results are sent back to Django
6. Django asks OpenAI to compose a natural-language answer from the data
7. The final answer is returned to Flutter and shown in the chat

The user's raw data never leaves the device — only the AI-generated answer travels back.

---

## Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| State management | BLoC + Pine architecture |
| Local database | SQLite via `sqflite` |
| Backend API | Python, Django, Django Ninja |
| Remote storage | Supabase (chat transcript) |
| AI | OpenAI API (gpt-4o) |

---

## Project structure

```
.
├── backend/          # Django + Django Ninja API
│   ├── chat/         # endpoints, OpenAI service, Supabase service
│   ├── config/       # settings, urls, wsgi
│   ├── requirements.txt
│   └── .env.example
└── flutter-chat/     # Flutter app
    └── lib/
        ├── di/               # Pine dependency injection
        ├── local_db/         # SQLite schema + seed data
        ├── model/            # domain entities
        ├── network/          # Django API client (dio) + local SQL service
        ├── repositories/     # orchestrates the multi-step pipeline
        ├── state_management/ # ChatBloc with per-phase states
        └── ui/               # ChatPage, message bubbles, phase indicator
```

---

## Getting started

### Backend

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in OPENAI_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
python manage.py runserver 0.0.0.0:8000
```

Create the Supabase table before running:

```sql
create table chat_messages (
  id uuid primary key,
  chat_id text not null,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
```

### Flutter

```bash
cd flutter-chat
flutter pub get
flutter run
```

Set the correct backend URL in [lib/other/contants/ApiContants.dart](flutter-chat/lib/other/contants/ApiContants.dart):

| Target | URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000/api` |
| iOS simulator | `http://127.0.0.1:8000/api` |
| Physical device | `http://<your-lan-ip>:8000/api` |
