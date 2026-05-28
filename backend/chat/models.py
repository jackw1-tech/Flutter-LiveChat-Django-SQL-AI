from __future__ import annotations

import uuid

from django.db import models


class ChatSession(models.Model):
    id = models.CharField(primary_key=True, max_length=255)
    title = models.CharField(max_length=120, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at"]
        db_table = "chat_sessions"


class ChatMessage(models.Model):
    ROLE_CHOICES = [("user", "User"), ("assistant", "Assistant")]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    chat_id = models.CharField(max_length=255, db_index=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    content = models.TextField()
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]
        db_table = "chat_messages"
