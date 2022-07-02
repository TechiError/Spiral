import os
import asyncio
from telethon import TelegramClient
from yaml import safe_load

if not os.path.exists(".last_version"):
    exit()

with open(".last_version", "r") as f:
    last_version = f.read()

with open("version.yml") as f:
    MetaJson = safe_load(f)

if MetaJson["version"] == last_version:
    exit()


API_ID = 6
API_HASH = "eb06d4abfb49dc3eeb1aeb98ae0f581e"
TOKEN = os.getenv("BOT_TOKEN")
CHAT = "SpiralBuilds"

BASE_PATH = r"build\app\outputs\flutter-apk"

FILES = [
    "app-arm64-v8a-release.apk",
    "app-armeabi-v7a-release.apk",
    "app-x86_64-release.apk",
]


async def main():
    files = []
    for i in FILES:
        path = os.path.join(BASE_PATH, i)
        if os.path.exists(path):
            files.append(path)

    if not files:
        return
    Message = f"**Spiral v{MetaJson['version']}**"
    if MetaJson.get("changelog"):
        Message += "\n\n**ChangeLog:**"
        for line in MetaJson["changelog"]:
            Message += f"\n{line}"
    if MetaJson.get("tags"):
        Message += "\n" + " ".join([f"#{tag}" for tag in MetaJson["tags"]])
    async with TelegramClient(None, api_id=API_ID, api_hash=API_HASH).start(
        bot_token=TOKEN
    ) as client:
        if MetaJson.get("images"):
            await client.send_message(
                CHAT, file=MetaJson["images"]
            )
        await client.send_message(
            CHAT, Message, file=files, thumb=MetaJson.get("thumb")
        )


asyncio.run(main())
