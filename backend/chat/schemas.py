from __future__ import annotations

from typing import Any

from ninja import Schema


class ChatCreateIn(Schema):
    title: str | None = None


class ChatOut(Schema):
    chat_id: str
    title: str
    created_at: str
    updated_at: str
    message_count: int
    last_message: str | None = None


class ChatMessageOut(Schema):
    id: str
    chat_id: str
    role: str
    content: str
    created_at: str
    metadata: dict[str, Any]


class MessageIn(Schema):
    chat_id: str
    message: str


class SqlOut(Schema):
    chat_id: str
    sql: str


class SqlResultsIn(Schema):
    chat_id: str
    user_message: str
    sql: str
    rows: list[dict[str, Any]]
    total_row_count: int | None = None
    truncated: bool = False


class FinalAnswerOut(Schema):
    chat_id: str
    answer: str
