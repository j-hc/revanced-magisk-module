from config import Config
import requests
from markdown_to_telegraph import MarkdownToTelegraph


# Read release.json file
release = requests.get(Config.REVANCED_APKS_RELEASE_URL).json()

telegraph = MarkdownToTelegraph("revanced_apks_web", "ReVanced APKs", "https://t.me/revanced_apks_web")


def generate_file_bullet(file_name, file_url):
    return f"🔗 [{file_name}]({file_url})"


def generate_files_message():

    # Collect browser_download_url from assets in release
    nonroot_files = []

    for asset in release["assets"][::-1]:
        file_name = asset["name"]
        file_url = asset["browser_download_url"]
        nonroot_files.append(generate_file_bullet(file_name, file_url))

    microg = fetch_microg()
    nonroot_files.append(
        generate_file_bullet(microg["microg_name"], microg["microg_file"])
    )

    return {"nonroot_files": nonroot_files}


def fetch_microg():
    return {"microg_name": "GMS_CORE(microg).apk", "microg_file": Config.MICROG_RELEASE_URL}


def fetch_changelogs_telegraph_url():
    return telegraph.create_page_from_string("Changelogs", release["body"])


def main():
    files = generate_files_message()
    changelogs_url = fetch_changelogs_telegraph_url()

    # Format release message
    release_message = Config.RELEASE_MESSAGE.format(
        release_name=release["name"],
        changelogs_url=changelogs_url,
        nonroot_files="\n".join(files["nonroot_files"]),
        credits_message=Config.CREDITS_MESSAGE,
    )

    print(release_message)

    # Write release message to file
    with open("release_notification.md", "w") as f:
        f.write(release_message)
