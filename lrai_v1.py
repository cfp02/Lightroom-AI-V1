import socket
import keyboard
import webbrowser
import time

def send_to_lightroom(message):
    """Send a message to the Lightroom server."""
    try:
        print(f"Sending message to Lightroom: {message}")
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.connect(('localhost', 12345))
            sock.sendall(message.encode('utf-8'))
            # Optionally wait for a response and print it
            response = sock.recv(1024)
            print('Received from Lightroom:', response.decode())
    except Exception as e:
        print(f"Failed to send message to Lightroom: {e}")

def start_keyboard_listener():
    print("Starting keyboard listener. Press 'esc' to exit.")

    # Define command mappings or just listen for certain keys
    key_commands = {
        'q': 'adjust_exposure',
        'w': 'adjust_contrast',
        # Add more keys and commands as needed
    }

    keyboard.add_hotkey('esc', lambda: exit(0))  # Exit on ESC

    for key, command in key_commands.items():
        keyboard.add_hotkey(key, send_to_lightroom, args=[command])

    keyboard.wait('esc')

def open_lightroom_url(command, params):
    # Construct the URL
    base_url = "lightroom://com.coleparks.lrai_v1"
    url = f"{base_url}/{command}?{params}"

    # Log the URL to make sure it's correct
    # print("Opening URL:", url)

    # Use the webbrowser module to open the URL
    webbrowser.open(url)


def main():
    command = "Clarity"
    params = "78"
    # open_lightroom_url(command, params)

    for i in range(3):
        params = f"{20 + i}"
        print(f"Setting {command} to {params}")
        open_lightroom_url(command, params)
        time.sleep(0.05)


if __name__ == '__main__':
    main()
