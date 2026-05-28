"""OpenAI integration for the two-phase chat flow.

Phase A - `generate_sql`: the user question is turned into a single SQL
statement that runs against the on-device SQLite database. The model MUST
return raw SQL only (no markdown fences, no commentary), otherwise the
Flutter client will fail to execute it.

Phase B - `format_answer`: given the rows returned by the device, the
model produces the natural-language answer that the user actually reads.
"""

from __future__ import annotations

import json
import re
from typing import Any

from django.conf import settings
from openai import OpenAI


ConversationMessage = dict[str, str]


NO_SCHEMA_CONFIGURED = """NO_SCHEMA_CONFIGURED
The application owner has not provided a SQLite schema yet."""


SQL_SYSTEM_PROMPT_TEMPLATE = """You translate user questions into one SQL query for a local SQLite database.

The app owner provides the queryable schema in the schema context below. Treat that schema as the only source of truth.

Rules:
- Output raw SQL only. No prose, no markdown fences, no trailing comments.
- Return exactly one statement.
- Use SQLite syntax.
- Use SELECT only. Never use INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, REPLACE, ATTACH, DETACH, or PRAGMA.
- Use only tables, views, columns, relationships, meanings, and business rules explicitly listed in the schema context.
- Never invent table names, column names, enum values, metrics, date formats, currencies, or units.
- Prefer explicit column lists. Never use SELECT *.
- For detail/list queries, include a LIMIT no higher than 200 unless the user asks for fewer rows.
- For totals, rankings, averages, counts, or breakdowns, use aggregate functions and GROUP BY when appropriate.
- When ranking grouped results, add a sensible ORDER BY and LIMIT.
- Use the recent conversation to resolve follow-up questions and pronouns.
- If the schema context contains NO_SCHEMA_CONFIGURED, or the request cannot be answered with the configured schema, output exactly:
SELECT 'unsupported' AS reason;

Schema context:
"""


ANSWER_SYSTEM_PROMPT = """You are a generic data assistant.
You receive: the recent conversation, the user's original question, the SQL the system ran, the JSON rows it returned,
and a `meta` object with `total_row_count` and `truncated` (true when the result was capped).
Write a concise, natural-language answer in the user's language.
Never mention SQL, JSON, or database internals. Answer the question from the returned data.
Never add closing filler phrases like "Se hai bisogno di altro fammi sapere", "Fammi sapere se hai altre domande", "Se hai bisogno di ulteriori informazioni" or any similar offer-to-help sentence. End the answer with the actual content.
Do not assume currency, units, domain labels, or business meaning unless they are present in the returned rows or the user's question.
Format numbers and dates naturally for the user's language.

Handling list-style results:
- If `meta.truncated` is true, start by saying you are showing the first N rows out of total_row_count, then present the rows.
- If many rows are returned but the user asked for an aggregate, prefer summarizing patterns rather than dumping rows.

Handling edge cases:
- If the rows are empty, say you couldn't find anything matching the request.
- If the rows only contain {"reason": "unsupported"}, say the available data configuration is not sufficient to answer.
"""


_SQL_FENCE = re.compile(r"^```(?:sql)?\s*|\s*```$", re.IGNORECASE | re.MULTILINE)


def _client() -> OpenAI:
    if not settings.OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not configured.")
    return OpenAI(api_key=settings.OPENAI_API_KEY)


def _strip_fences(text: str) -> str:
    return _SQL_FENCE.sub("", text).strip()


def _schema_context() -> str:
    try:
        content = settings.AI_SCHEMA_CONTEXT_PATH.read_text(encoding="utf-8").strip()
    except OSError:
        return NO_SCHEMA_CONFIGURED
    return content or NO_SCHEMA_CONFIGURED


def _sql_system_prompt() -> str:
    return f"{SQL_SYSTEM_PROMPT_TEMPLATE}\n{_schema_context()}"


def _format_history(history: list[ConversationMessage] | None) -> str:
    if not history:
        return "No previous conversation."
    return "\n".join(
        f"{message['role']}: {message['content']}"
        for message in history
        if message.get("role") and message.get("content")
    )


class OpenAIChatService:
    def __init__(self) -> None:
        self._model = settings.OPENAI_MODEL

    def generate_sql(
        self,
        user_message: str,
        *,
        history: list[ConversationMessage] | None = None,
    ) -> str:
        """Phase A - user question -> single SQL statement."""
        completion = _client().chat.completions.create(
            model=self._model,
            temperature=0,
            messages=[
                {"role": "system", "content": _sql_system_prompt()},
                {
                    "role": "user",
                    "content": (
                        f"Recent conversation:\n{_format_history(history)}\n\n"
                        f"Current question:\n{user_message}"
                    ),
                },
            ],
        )
        return _strip_fences(completion.choices[0].message.content or "")

    def format_answer(
        self,
        *,
        user_message: str,
        sql: str,
        rows: list[dict[str, Any]],
        history: list[ConversationMessage] | None = None,
        total_row_count: int | None = None,
        truncated: bool = False,
    ) -> str:
        """Phase B - local rows -> natural-language reply."""
        payload = json.dumps(
            {
                "conversation": history or [],
                "question": user_message,
                "sql": sql,
                "rows": rows,
                "meta": {
                    "row_count": len(rows),
                    "total_row_count": (
                        total_row_count if total_row_count is not None else len(rows)
                    ),
                    "truncated": truncated,
                },
            },
            ensure_ascii=False,
        )
        completion = _client().chat.completions.create(
            model=self._model,
            temperature=0.4,
            messages=[
                {"role": "system", "content": ANSWER_SYSTEM_PROMPT},
                {"role": "user", "content": payload},
            ],
        )
        return (completion.choices[0].message.content or "").strip()
