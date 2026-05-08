from __future__ import annotations

from typing import Any

from ninja import Schema


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


class FinalAnswerOut(Schema):
    chat_id: str
    answer: str
