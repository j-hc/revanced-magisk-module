import argparse
import requests
import firebase_admin
from firebase_admin import credentials, messaging

# Initialize Firebase (replace with your Firebase project credentials)
cred = credentials.Certificate("google-services.json")
firebase_admin.initialize_app(cred)

def send_firebase_notifications(title, body, api_url, bearer_key):
    """Sends Firebase notifications, handling pagination, invalid tokens, and errors.

    Args:
        title (str): Notification title.
        body (str): Notification body.
        api_url (str): Base API URL for fetching tokens.
        bearer_key (str): Bearer authorization key.
    """

    headers = {"Authorization": f"Bearer {bearer_key}"}
    last_key = None  # Initialize for the first API call

    while True:
        params = {"last": last_key} if last_key else {}
        try:
            response = requests.get(f"{api_url}/all", headers=headers, params=params)
            response.raise_for_status()  # Raise an exception for error status codes
            data = response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching tokens: {e}")
            return

        items = data["items"]
        fcm_tokens = [item["key"] for item in items]
        if not fcm_tokens:
            break  # No more tokens to process

        # Build the Firebase notification message
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            tokens=fcm_tokens,
        )

        try:
            # Send the notifications
            response = messaging.send_multicast(message)

            # Handle invalid or expired tokens
            if response.failure_count > 0:
                for index, result in enumerate(response.responses):
                    if not result.success and result.exception:
                        print(f"Error sending notification: {result.exception}")
                        print("Deleting expired token...")
                        token_to_delete = fcm_tokens[index]
                        delete_expired_token(api_url, bearer_key, token_to_delete)
        except Exception as e:
            print(f"Error sending notifications: {e}")

        last_key = data.get("last")  # Extract the last key for pagination
        if not last_key:
            break  # Stop if there are no more pages


def delete_expired_token(api_url, bearer_key, fcm_token):
    """Deletes an expired or invalid FCM token."""
    delete_url = f"{api_url}/"  # Construct the delete URL
    headers = {"Authorization": f"Bearer {bearer_key}"}
    data = {"fcm_token": fcm_token}

    try:
        requests.delete(delete_url, headers=headers, json=data)
    except requests.exceptions.RequestException as e:
        print(f"Error deleting token: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Send Firebase Notifications")
    parser.add_argument("--title", required=True, help="Title of the notification")
    parser.add_argument("--body", required=True, help="Body of the notification")
    parser.add_argument("--api_url", required=True, help="Firebase API URL")
    parser.add_argument("--bearer", required=True, help="Firebase Bearer token")

    args = parser.parse_args()

    send_firebase_notifications(args.title, args.body, args.api_url, args.bearer)
