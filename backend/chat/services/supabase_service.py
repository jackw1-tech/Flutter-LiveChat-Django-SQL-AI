"""Persistence of chat messages on Supabase.

The Django backend never queries user data directly: it only stores the
conversation transcript so the chat history is available across devices.
"""

from __future__ import annotations

from typing import Any
from uuid import uuid4

from django.conf import settings
from supabase import Client, create_client


def _client() -> Client:
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise RuntimeError(
            "Supabase credentials missing. Set SUPABASE_URL and "
            "SUPABASE_SERVICE_ROLE_KEY in the backend .env file."
        )
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


class SupabaseChatService:
    """Thin wrapper around the Supabase `chat_messages` table."""

    def __init__(self) -> None:
        self._table = settings.SUPABASE_MESSAGES_TABLE

    def save_message(
        self,
        *,
        chat_id: str,
        role: str,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        payload = {
            "id": str(uuid4()),
            "chat_id": chat_id,
            "role": role,
            "content": content,
            "metadata": metadata or {},
        }
        response = _client().table(self._table).insert(payload).execute()
        return (response.data or [payload])[0]

    def list_messages(self, chat_id: str) -> list[dict[str, Any]]:
        response = (
            _client()
            .table(self._table)
            .select("*")
            .eq("chat_id", chat_id)
            .order("created_at")
            .execute()
        )
        return response.data or []
