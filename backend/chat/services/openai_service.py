"""OpenAI integration for the two-phase chat flow.

Phase A — `generate_sql`: the user question is turned into a single SQL
statement that runs against the on-device SQLite database. The model MUST
return raw SQL only (no markdown fences, no commentary), otherwise the
Flutter client will fail to execute it.

Phase B — `format_answer`: given the rows returned by the device, the
model produces the natural-language answer that the user actually reads.
"""

from __future__ import annotations

import json
import re
from typing import Any

from django.conf import settings
from openai import OpenAI


SQL_SYSTEM_PROMPT = """You translate user questions into a single SQL query for a local SQLite database.

Schema (do NOT invent tables or columns):
- users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, created_at TEXT)
- products(id INTEGER PRIMARY KEY, name TEXT, price REAL, stock INTEGER)
- orders(id INTEGER PRIMARY KEY, user_id INTEGER, product_id INTEGER, quantity INTEGER, ordered_at TEXT)

Rules:
- Output raw SQL only. No prose, no markdown fences, no trailing semicolon-comments.
- One statement per response. SELECT only — never INSERT/UPDATE/DELETE/DROP.
- If the question cannot be answered with the schema, output: SELECT 'unsupported' AS reason;
"""


ANSWER_SYSTEM_PROMPT = """You are a helpful assistant.
You receive: the user's original question, the SQL the system ran, and the JSON rows it returned.
Write a concise, natural-language answer in the user's language.
Never mention SQL, JSON, or the database — just answer the question.
If the rows are empty, say you couldn't find anything matching the request.
"""


_SQL_FENCE = re.compile(r"^```(?:sql)?\s*|\s*```$", re.IGNORECASE | re.MULTILINE)


def _client() -> OpenAI:
    if not settings.OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not configured.")
    return OpenAI(api_key=settings.OPENAI_API_KEY)


def _strip_fences(text: str) -> str:
    return _SQL_FENCE.sub("", text).strip()


class OpenAIChatService:
    def __init__(self) -> None:
        self._model = settings.OPENAI_MODEL

    def generate_sql(self, user_message: str) -> str:
        """Phase A — user question -> single SQL statement."""
        completion = _client().chat.completions.create(
            model=self._model,
            temperature=0,
            messages=[
                {"role": "system", "content": SQL_SYSTEM_PROMPT},
                {"role": "user", "content": user_message},
            ],
        )
        return _strip_fences(completion.choices[0].message.content or "")

    def format_answer(
        self,
        *,
        user_message: str,
        sql: str,
        rows: list[dict[str, Any]],
    ) -> str:
        """Phase B — local rows -> natural-language reply."""
        payload = json.dumps(
            {"question": user_message, "sql": sql, "rows": rows},
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
