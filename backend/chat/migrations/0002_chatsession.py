from django.db import migrations, models


def backfill_chat_sessions(apps, schema_editor):
    ChatMessage = apps.get_model("chat", "ChatMessage")
    ChatSession = apps.get_model("chat", "ChatSession")

    for chat_id in ChatMessage.objects.values_list("chat_id", flat=True).distinct():
        first_user = (
            ChatMessage.objects.filter(chat_id=chat_id, role="user")
            .order_by("created_at")
            .first()
        )
        last_message = (
            ChatMessage.objects.filter(chat_id=chat_id).order_by("-created_at").first()
        )
        ChatSession.objects.get_or_create(
            id=chat_id,
            defaults={
                "title": (first_user.content[:120] if first_user else ""),
                "created_at": first_user.created_at if first_user else last_message.created_at,
                "updated_at": last_message.created_at,
            },
        )


class Migration(migrations.Migration):

    dependencies = [
        ("chat", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="ChatSession",
            fields=[
                (
                    "id",
                    models.CharField(max_length=255, primary_key=True, serialize=False),
                ),
                ("title", models.CharField(blank=True, default="", max_length=120)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
            ],
            options={
                "db_table": "chat_sessions",
                "ordering": ["-updated_at"],
            },
        ),
        migrations.RunPython(backfill_chat_sessions, migrations.RunPython.noop),
    ]
