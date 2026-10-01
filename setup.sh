#!/bin/bash
# One-click setup for medical-chatbot (Git Bash on Windows)

set -e
cd "$(dirname "$0")"

PY312="/c/Users/$USERNAME/AppData/Local/Programs/Python/Python312/python.exe"
PY311="/c/Users/$USERNAME/AppData/Local/Programs/Python/Python311/python.exe"
PYTHON=""

# 1. Find a compatible Python (3.11 or 3.12)
if [ -f "$PY312" ]; then PYTHON="$PY312"
elif [ -f "$PY311" ]; then PYTHON="$PY311"
elif command -v py >/dev/null 2>&1 && py -3.12 --version >/dev/null 2>&1; then PYTHON="py -3.12"
elif command -v py >/dev/null 2>&1 && py -3.11 --version >/dev/null 2>&1; then PYTHON="py -3.11"
fi

# 2. If none found, download and install Python 3.12 silently
if [ -z "$PYTHON" ]; then
  echo ">> Python 3.12 not found. Downloading installer..."
  curl -L -o /tmp/python312.exe "https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe"
  echo ">> Installing Python 3.12 (this takes a minute)..."
  /tmp/python312.exe /quiet InstallAllUsers=0 PrependPath=0 Include_launcher=1
  PYTHON="$PY312"
  if [ ! -f "$PYTHON" ]; then
    echo "!! Install failed. Install Python 3.12 manually from python.org and re-run."
    exit 1
  fi
fi

echo ">> Using: $PYTHON"
$PYTHON --version

# 3. Create fresh virtual environment
if [ -d venv ]; then
  echo ">> Removing old venv..."
  rm -rf venv
fi
echo ">> Creating venv..."
$PYTHON -m venv venv
source venv/Scripts/activate

# 4. Install dependencies
echo ">> Installing packages (this can take a few minutes)..."
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install python-dotenv

# 5. HuggingFace token
if [ ! -f .env ]; then
  echo ""
  read -p "Paste your HuggingFace token (or press Enter to skip): " TOKEN
  if [ -n "$TOKEN" ]; then
    echo "HF_TOKEN=$TOKEN" > .env
    echo ">> Saved to .env"
  fi
fi

echo ""
echo "=========================================="
echo " Setup done! Start the chatbot with:  ./run.sh"
echo "=========================================="
