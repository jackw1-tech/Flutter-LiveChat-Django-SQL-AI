from __future__ import annotations

import uuid
from typing import Any

from django.utils import timezone

from chat.models import ChatMessage, ChatSession


class ChatStorageService:
    def create_chat(self, *, title: str | None = None) -> dict[str, Any]:
        chat = ChatSession.objects.create(
            id=str(uuid.uuid4()),
            title=(title or "").strip()[:120],
        )
        return self._chat_summary(chat)

    def list_chats(self) -> list[dict[str, Any]]:
        return [self._chat_summary(chat) for chat in ChatSession.objects.all()]

    def save_message(
        self,
        *,
        chat_id: str,
        role: str,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        chat, _ = ChatSession.objects.get_or_create(
            id=chat_id,
            defaults={"title": content.strip()[:120] if role == "user" else ""},
        )
        chat.updated_at = timezone.now()
        if role == "user" and not chat.title:
            chat.title = content.strip()[:120]
        chat.save(update_fields=["title", "updated_at"])

        msg = ChatMessage.objects.create(
            chat_id=chat_id,
            role=role,
            content=content,
            metadata=metadata or {},
        )
        return {
            "id": str(msg.id),
            "chat_id": msg.chat_id,
            "role": msg.role,
            "content": msg.content,
            "metadata": msg.metadata,
            "created_at": msg.created_at.isoformat(),
        }

    def list_messages(self, chat_id: str) -> list[dict[str, Any]]:
        qs = ChatMessage.objects.filter(chat_id=chat_id).order_by("created_at")
        return [
            {
                "id": str(m.id),
                "chat_id": m.chat_id,
                "role": m.role,
                "content": m.content,
                "metadata": m.metadata,
                "created_at": m.created_at.isoformat(),
            }
            for m in qs
        ]

    def _chat_summary(self, chat: ChatSession) -> dict[str, Any]:
        messages = ChatMessage.objects.filter(chat_id=chat.id)
        first_user = messages.filter(role="user").order_by("created_at").first()
        last_message = messages.order_by("-created_at").first()
        title = chat.title or (first_user.content[:120] if first_user else "Nuova chat")
        updated_at = last_message.created_at if last_message else chat.updated_at

        return {
            "chat_id": chat.id,
            "title": title,
            "created_at": chat.created_at.isoformat(),
            "updated_at": updated_at.isoformat(),
            "message_count": messages.count(),
            "last_message": last_message.content if last_message else None,
        }
