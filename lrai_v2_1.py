from flask import Flask, request
import threading
import keyboard
import subprocess

app = Flask(__name__)

@app.route('/send_command', methods=['GET'])
def send_command():
    command = request.args.get('command')
    param = request.args.get('param')
    operation = request.args.get('operation', 'set')
    construct_and_send_url(command, param, operation)
    return f"Sent command {command} with param {param} and operation {operation}."

def construct_and_send_url(command, param, operation):
    base_url = "lightroom://com.coleparks.lrai_v2"
    print(f"Sending command {command} with param {param} and operation {operation}.")
    param_prefix = 'N' if int(param) < 0 else 'P'
    url = f"{base_url}/{command}?{param_prefix}{abs(int(param))}?{operation}"
    subprocess.run(['start', url], shell=True)  # Windows-specific

def keyboard_listener():
    global exit_flag

    key_commands = {
        'q': ['Dehaze', -10, 'increment'],
        'w': ['Dehaze', 10, 'increment'],
    }

    for key, (command, param, operation) in key_commands.items():
        keyboard.add_hotkey(key, lambda: construct_and_send_url(command, param, operation))

    print("Keyboard listener started. Press ESC to exit.")
    while not exit_flag:
        keyboard.wait('esc')
        exit_flag = True

    print("Exiting keyboard listener...")

def flask_thread():
    app.run(port=5000, use_reloader=False)

if __name__ == '__main__':
    flask_app_thread = threading.Thread(target=flask_thread)
    flask_app_thread.start()
    try:
        keyboard_listener()
    finally:
        exit_flag = True
        flask_app_thread.join()  # Ensure the Flask thread has finished
        print("Program exited cleanly.")
