"""Django Ninja endpoints orchestrating the two-phase chat flow.

Endpoint map:
  GET  /api/chats/                     -> list chat sessions
  POST /api/chats/                     -> create a new chat session
  GET  /api/chats/{chat_id}/messages/  -> list messages for a chat session
  POST /api/chat/message/              -> step 2..6  (user message -> SQL)
  POST /api/chat/process_sql_results/  -> step 8..11 (local rows -> final answer)
"""

from __future__ import annotations

from ninja import NinjaAPI

from chat.schemas import (
    ChatCreateIn,
    ChatMessageOut,
    ChatOut,
    FinalAnswerOut,
    MessageIn,
    SqlOut,
    SqlResultsIn,
)
from chat.services.chat_storage_service import ChatStorageService
from chat.services.openai_service import OpenAIChatService


api = NinjaAPI(title="Generic Local SQL AI Chat", version="1.0.0")

_storage = ChatStorageService()
_openai = OpenAIChatService()


_HISTORY_LIMIT = 8


def _chat_history(chat_id: str) -> list[dict[str, str]]:
    messages = _storage.list_messages(chat_id)
    recent = messages[-_HISTORY_LIMIT:] if len(messages) > _HISTORY_LIMIT else messages
    return [
        {"role": message["role"], "content": message["content"]}
        for message in recent
    ]


@api.get("/chats/", response=list[ChatOut], tags=["chat"])
def list_chats(request) -> list[dict]:
    return _storage.list_chats()


@api.post("/chats/", response=ChatOut, tags=["chat"])
def create_chat(request, payload: ChatCreateIn) -> dict:
    return _storage.create_chat(title=payload.title)


@api.get("/chats/{chat_id}/messages/", response=list[ChatMessageOut], tags=["chat"])
def list_chat_messages(request, chat_id: str) -> list[dict]:
    return _storage.list_messages(chat_id)


@api.post("/chat/message/", response=SqlOut, tags=["chat"])
def post_message(request, payload: MessageIn) -> SqlOut:
    history = _chat_history(payload.chat_id)
    # Step 3 - persist the user message in the backend database.
    _storage.save_message(
        chat_id=payload.chat_id,
        role="user",
        content=payload.message,
    )
    # Steps 4-5 - ask OpenAI to translate the question into SQL.
    sql = _openai.generate_sql(payload.message, history=history)
    # Step 6 - return the SQL to Flutter for local execution.
    return SqlOut(chat_id=payload.chat_id, sql=sql)


@api.post("/chat/process_sql_results/", response=FinalAnswerOut, tags=["chat"])
def process_sql_results(request, payload: SqlResultsIn) -> FinalAnswerOut:
    history = _chat_history(payload.chat_id)
    # Step 9 - forward local rows to OpenAI for the natural-language reply.
    answer = _openai.format_answer(
        user_message=payload.user_message,
        sql=payload.sql,
        rows=payload.rows,
        history=history,
        total_row_count=payload.total_row_count,
        truncated=payload.truncated,
    )
    # Persist the assistant reply alongside the user message.
    _storage.save_message(
        chat_id=payload.chat_id,
        role="assistant",
        content=answer,
        metadata={
            "sql": payload.sql,
            "row_count": len(payload.rows),
            "total_row_count": payload.total_row_count,
            "truncated": payload.truncated,
        },
    )
    # Step 11 - return the final answer to Flutter.
    return FinalAnswerOut(chat_id=payload.chat_id, answer=answer)


@api.get("/health/", tags=["meta"])
def health(request) -> dict[str, str]:
    return {"status": "ok"}
