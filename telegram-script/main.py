from config import Config
import re
import requests


# Read release.json file
release = requests.get(Config.REVANCED_APKS_RELEASE_URL).json()


def revanced_version_message():
    version_message = "\n".join(re.findall(r"CLI:\s[a-zA-Z-.\s0-9:\/]+.jar", release["body"])) or ""
    # Remove duplicate version message
    version_message = "\n".join(list(dict.fromkeys(version_message.split("\n"))))
    return version_message


def generate_file_bullet(file_name, file_url):
    return f"🔗 [{file_name}]({file_url})"


def generate_files_message():

    # Collect browser_download_url from assets in release
    nonroot_files = []
    root_files = []

    for asset in release["assets"][::-1]:
        file_name = asset["name"]
        file_url = asset["browser_download_url"]
        if ".zip" in file_name:
            root_files.append(generate_file_bullet(file_name, file_url))
        else:
            nonroot_files.append(generate_file_bullet(file_name, file_url))

    microg = fetch_microg()
    nonroot_files.append(
        generate_file_bullet(microg["microg_name"], microg["microg_file"])
    )

    return {"nonroot_files": nonroot_files, "root_files": root_files}


def fetch_microg():

    vanced_microg_release = requests.get(Config.MICROG_RELEASE_URL).json()

    microg_file = vanced_microg_release["assets"][0] or []

    microg_name = (
        microg_file["name"].strip(".apk")
        + "-"
        + vanced_microg_release["tag_name"]
        + ".apk"
        or "microg.apk"
    )
    microg_file = microg_file["browser_download_url"] or ""

    if "microg" in microg_file:
        return {"microg_name": microg_name, "microg_file": microg_file}
    else:
        # to avoid error returning empty string
        return {"microg_name": "", "microg_file": ""}


def fetch_changelogs():
    previous_version_release = requests.get(
        Config.REVANCED_APKS_RELEASE_URL.removesuffix("/latest")
    ).json()[1]

    re_exp = r"(?<=revanced-patches-)[0-9.]+(?=.jar)"
    previous_revanced_version = re.findall(re_exp, previous_version_release["body"])[1]
    current_revanced_version = re.findall(re_exp, release["body"])[1]

    changelogs = requests.get(
        Config.REVANCED_CHANGES_URL
        + f"/v{previous_revanced_version}...v{current_revanced_version}"
    ).json()["commits"]

    changelogs = [
        "✴ " + ch["commit"]["message"].split("\n")[0]
        for ch in changelogs
        if not "chore" in ch["commit"]["message"]
    ] if changelogs else ["✴ Same as previous version with minor source changes."]

    return changelogs


def main():
    files = generate_files_message()
    changelogs = fetch_changelogs()

    # Format release message
    release_message = Config.RELEASE_MESSAGE.format(
        release_name=release["name"],
        revanced_version_message=revanced_version_message(),
        changelogs="\n".join(changelogs),
        notes=Config.NOTES,
        nonroot_files="\n".join(files["nonroot_files"]),
        root_files="\n".join(files["root_files"]),
        credits_message=Config.CREDITS_MESSAGE,
    )

    # remove whats new if changelogs is empty
    if not changelogs:
        release_message = release_message.replace("*What's new:*\n\n", "")

    print(release_message)

    # Write release message to file
    with open("release_notification.md", "w") as f:
        f.write(release_message)
