"""Django Ninja endpoints orchestrating the two-phase chat flow.

Endpoint map:
  POST /api/chat/message/              -> step 2..6  (user message -> SQL)
  POST /api/chat/process_sql_results/  -> step 8..11 (local rows -> final answer)
"""

from __future__ import annotations

from ninja import NinjaAPI

from chat.schemas import FinalAnswerOut, MessageIn, SqlOut, SqlResultsIn
from chat.services.openai_service import OpenAIChatService
from chat.services.supabase_service import SupabaseChatService


api = NinjaAPI(title="Flutter LiveChat SQL AI", version="1.0.0")

_supabase = SupabaseChatService()
_openai = OpenAIChatService()


@api.post("/chat/message/", response=SqlOut, tags=["chat"])
def post_message(request, payload: MessageIn) -> SqlOut:
    # Step 3 — persist the user message on Supabase.
    _supabase.save_message(
        chat_id=payload.chat_id,
        role="user",
        content=payload.message,
    )
    # Steps 4-5 — ask OpenAI to translate the question into SQL.
    sql = _openai.generate_sql(payload.message)
    # Step 6 — return the SQL to Flutter for local execution.
    return SqlOut(chat_id=payload.chat_id, sql=sql)


@api.post("/chat/process_sql_results/", response=FinalAnswerOut, tags=["chat"])
def process_sql_results(request, payload: SqlResultsIn) -> FinalAnswerOut:
    # Step 9 — forward local rows to OpenAI for the natural-language reply.
    answer = _openai.format_answer(
        user_message=payload.user_message,
        sql=payload.sql,
        rows=payload.rows,
    )
    # Persist the assistant reply alongside the user message.
    _supabase.save_message(
        chat_id=payload.chat_id,
        role="assistant",
        content=answer,
        metadata={"sql": payload.sql, "row_count": len(payload.rows)},
    )
    # Step 11 — return the final answer to Flutter.
    return FinalAnswerOut(chat_id=payload.chat_id, answer=answer)


@api.get("/health/", tags=["meta"])
def health(request) -> dict[str, str]:
    return {"status": "ok"}
