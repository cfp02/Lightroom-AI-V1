import requests

def send_command(command):
    """Sends a command to the Lightroom HTTP server."""
    url = f'http://localhost:12345/command?command={command}'
    try:
        response = requests.get(url)
        print("Response from Lightroom:", response.text)
    except requests.RequestException as e:
        print(f"Failed to send command: {e}")

if __name__ == '__main__':
    command = input("Enter command: ")
    send_command(command)
