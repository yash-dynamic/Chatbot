# Medical Chatbot: Setup and Run Commands

Oct 1, 2026 · @DMS Infra

## Run it again (every time)

Open Git Bash and run these two commands. The chatbot opens at http://localhost:8501.

```bash
cd "/d/Yash Workspace/Projects/medical-chatbot"
bash run.sh
```

`run.sh` activates the virtual environment, loads your keys from `.env`, builds the vector index if it is empty, and starts Streamlit. To stop the chatbot, press `Ctrl+C` in the same Git Bash window.

If `run.sh` is missing, start it by hand:

```bash
cd "/d/Yash Workspace/Projects/medical-chatbot"
source venv/Scripts/activate
set -a; source .env; set +a
streamlit run medibot.py
```

The prompt must show `(venv)` once the environment is active. Ask questions that your PDFs in `data/` can answer. The bot answers only from those documents, so a question like "What is the current time?" gets "I don't know".

## First-time setup (one time only)

Use Git Bash for every command. Python 3.14 is too new for the pinned packages, so use Python 3.12.

1. Install Python 3.12 from python.org/downloads/windows (64-bit installer). It installs to `C:\Users\Lenovo\AppData\Local\Programs\Python\Python312\`.
2. Clone the project:

```bash
cd "/d/Yash Workspace/Projects"
git clone https://github.com/AIwithhassan/medical-chatbot.git
cd medical-chatbot
```

3. Create the virtual environment with Python 3.12 and activate it:

```bash
/c/Users/Lenovo/AppData/Local/Programs/Python/Python312/python.exe -m venv venv
source venv/Scripts/activate
python --version
```

The version must say `Python 3.12.x`, and the prompt must start with `(venv)`.

4. Install the packages:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install python-dotenv
```

5. Get the keys:
   - HuggingFace token: huggingface.co, then Settings, then Access Tokens. It is free and starts with `hf_`.
   - Groq API key: console.groq.com, then API Keys. It is free and starts with `gsk_`.
6. Create the `.env` file in the project folder with your real values and no spaces or quotes:

```
HF_TOKEN=hf_your_real_token
GROQ_API_KEY=gsk_your_real_key
```

7. Keep the keys out of Git:

```bash
echo ".env" >> .gitignore
```

8. Build the index and start the chatbot (see the next section if you added your own PDFs):

```bash
python create_memory_for_llm.py
bash run.sh
```

## Change the documents the bot answers from

The bot answers only from the PDFs in the `data/` folder. After you add, remove or change a PDF, rebuild the index. `run.sh` does not rebuild it when the index already exists.

```bash
cd "/d/Yash Workspace/Projects/medical-chatbot"
source venv/Scripts/activate
python create_memory_for_llm.py
bash run.sh
```

The rebuild reads every PDF in `data/`, splits it into chunks, creates embeddings on your CPU, and saves the index to `vectorstore/db_faiss/`. A normal run prints nothing at the end, so a returned prompt without an error means it worked.

- **Use only your company PDF:** move the medical book out of `data/` first, so the bot does not mix both sources.

```bash
mkdir -p data_backup
mv data/The_GALE_ENCYCLOPEDIA_of_MEDICINE_SECOND.pdf data_backup/
ls data
```

- **Rebuild time:** a large book such as the Gale Encyclopedia of Medicine (1,000+ pages) can take 10 to 30 minutes or more. A short company PDF takes seconds to a few minutes. Don't press `Ctrl+C` while it runs, because that stops the build and shows a `KeyboardInterrupt` traceback.
- **Company PDF:** the file is `dynamic-methods.pdf`, exported from the Dynamic Methods: Company Information document. Export the document again as PDF whenever it changes, replace the file in `data/`, and rebuild.

## Project files, settings and the model

The chatbot uses HuggingFace embeddings that run on your own machine, FAISS for the index, a Groq-hosted language model for answers, and Streamlit for the web page.

| File or folder | Purpose |
| --- | --- |
| `data/` | The PDFs the bot answers from |
| `vectorstore/db_faiss/` | The saved index built from those PDFs |
| `create_memory_for_llm.py` | Builds the index from the PDFs |
| `medibot.py` | The Streamlit web app (`streamlit run medibot.py`) |
| `connect_memory_with_llm.py` | Connects the index to the language model; the repo's terminal chat script (role inferred from the file name) |
| `.env` | Your keys, `HF_TOKEN` and `GROQ_API_KEY`. Never share or commit it |
| `run.sh` and `setup.sh` | Helper scripts for running and first-time setup |
| `requirements.txt` and `Pipfile` | Package lists |
| `venv/` | The Python 3.12 virtual environment |

### Language model

The model in use is `openai/gpt-oss-120b` on Groq. The original code asked for `meta-llama/llama-4-maverick-17b-128e-instruct`, which Groq no longer serves, so it was replaced. Groq changes its model list over time. To see which models your key can use:

```bash
cd "/d/Yash Workspace/Projects/medical-chatbot"
source .env
curl -s https://api.groq.com/openai/v1/models -H "Authorization: Bearer $GROQ_API_KEY" | grep -o '"id": *"[^"]*"'
```

To switch to another model, for example the lighter `openai/gpt-oss-20b`, change it in both files and restart:

```bash
sed -i 's#openai/gpt-oss-120b#openai/gpt-oss-20b#g' medibot.py connect_memory_with_llm.py
grep -n "gpt-oss" *.py
```

### Costs and limits

HuggingFace and Groq both have free tiers. If you hit a rate limit (error 429), wait a few minutes and try again.

## Troubleshooting

These are the problems that came up during setup, with the fix for each.

| What you see | Cause | Fix |
| --- | --- | --- |
| `venvScriptsactivate: command not found` | Git Bash treats backslashes as escapes | Use `source venv/Scripts/activate` |
| `pip: command not found` | The venv is not active | Activate it first, or use `python -m pip` |
| `No matching distribution found for faiss-cpu==1.11.0` | Python 3.14 is too new for the pinned packages | Create the venv with Python 3.12 (see First-time setup) |
| `py: command not found` | The Python launcher is not on the Git Bash path | Call Python 3.12 by its full path |
| `winget` not recognized | winget is not installed | Install Python from python.org |
| `ModuleNotFoundError: No module named 'langchain_community'` | The venv is not active, so the global Python ran | Run `source venv/Scripts/activate` and check for `(venv)` in the prompt |
| `KeyboardInterrupt` while building the index | You stopped the build with `Ctrl+C` | Wait for it to finish, or remove the big PDF from `data/` first |
| `Error: 'GROQ_API_KEY'` | The key is not set or not loaded | Add it to `.env` and restart with `bash run.sh` |
| Invalid API key (401) | The `.env` still has the placeholder text | Paste your real key after `GROQ_API_KEY=` and restart |
| `model_not_found` (404) | Groq no longer serves that model | List models with the curl command above and change the model name |
| "I don't know" with Source Docs listed | The answer is not in your PDFs | Ask a question the documents cover, or add the right PDF and rebuild |
| Wrong or old answers after changing a PDF | The index was not rebuilt | Run `python create_memory_for_llm.py`, then restart |

### If nothing works

Close all Git Bash windows, open a new one, and run the two commands from the Run it again section. Check that the prompt shows `(venv)` and that `python --version` says 3.12.x. If an error remains, copy the full error text and bring it to Claude with your operating system.
