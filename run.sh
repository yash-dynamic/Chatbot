#!/bin/bash
cd "$(dirname "$0")"
source venv/Scripts/activate

# Load token from .env
if [ -f .env ]; then
  set -a; source .env; set +a
fi

# Build the vector store if it's empty
if [ -z "$(ls -A vectorstore/db_faiss 2>/dev/null)" ]; then
  echo ">> Building vector store..."
  python create_memory_for_llm.py
fi

streamlit run medibot.py
