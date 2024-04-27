import socket
import keyboard
import webbrowser
import time
import requests
from flask import Flask, request
import subprocess

app = Flask(__name__)

def start_keyboard_listener():
    print("Starting keyboard listener. Press 'esc' to exit.")

    # Define command mappings or just listen for certain keys
    key_commands = {
        '1': ['Shadows', -10, 'increment'],
        '2': ['Shadows', 10, 'increment'],
        # Add more keys and commands as needed
    }

    # keyboard.add_hotkey('`', lambda: exit(0))  # Exit on ESC

    for key, command in key_commands.items():
        keyboard.add_hotkey(key, open_lightroom_url, args=[command[0], command[1], command[2]])

    keyboard.wait('esc')

def open_lightroom_url(command, param, operation="set"):
    # Construct the URL
    base_url = "lightroom://com.coleparks.lrai_v2"
    if param < 0:
        param = 'N' + str(abs(param))
    else:
        param = 'P' + str(param)
    url = f"{base_url}/{command}?{param}?{operation}"

    send_lightroom_url(url)

def send_lightroom_url(url, mode = 'webbrowser'):

    if mode == 'webbrowser':
        webbrowser.open(url)
    elif mode == 'subprocess':
        try:
            subprocess.run(['start', url], shell=True)
            # On Linux, you might use subprocess.run(['xdg-open', url])
        except subprocess.CalledProcessError as e:
            print(f"Failed to open URL: {e}")

def main():
    command = "Clarity"
    params = "78"

    

    for i in range(20):
        params = f"{20 + i}"
        print(f"Setting {command} to {params}")
        open_lightroom_url(command, params)
        # time.sleep(0.01)


if __name__ == '__main__':
    # main()
    start_keyboard_listener()
