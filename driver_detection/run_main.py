import sys
import os
import threading
import time
import socket
import webbrowser
import winsound
import cryptography.fernet
import cv2
import mediapipe
import pandas
import altair
import base64
import re

# When run with --noconsole, standard streams are None.
# Streamlit will crash trying to log to them if not handled.
if sys.stdout is None:
    sys.stdout = open(os.devnull, "w")
if sys.stderr is None:
    sys.stderr = open(os.devnull, "w")

import streamlit.web.cli as stcli

def wait_and_open_browser():
    def is_port_in_use(port):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            return s.connect_ex(('localhost', port)) == 0

    # Wait up to 30 seconds for the server to spin up
    for _ in range(60):
        if is_port_in_use(8501):
            time.sleep(1) # Give it 1 second to fully bind
            webbrowser.open("http://localhost:8501")
            return
        time.sleep(0.5)

def resolve_path(path):
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, path)

if __name__ == "__main__":
    app_path = resolve_path("app.py")
    sys.argv = ["streamlit", "run", app_path, "--global.developmentMode=false"]
    
    # Spawn background thread to open browser when ready
    threading.Thread(target=wait_and_open_browser, daemon=True).start()
    
    # Start the streamlit server
    sys.exit(stcli.main())
