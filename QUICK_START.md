# Quick Start - AlgoSonar Chatbot

## 30-Second Setup

### Step 1: Install Ollama
Download from https://ollama.ai and install

### Step 2: Get a Model
```bash
ollama pull llama2
```

### Step 3: Run Ollama
```bash
ollama serve
```

### Step 4: Run Flutter App
```bash
cd algosonar
flutter pub get
flutter run
```

**Done!** The app will automatically connect to Ollama at `http://localhost:11434`

---

## Common Issues

| Issue | Fix |
|-------|-----|
| "Server disconnected" | Run `ollama serve` in terminal |
| "No models available" | Run `ollama pull llama2` |
| Model response slow | Try `ollama pull orca-mini` (smaller model) |

---

## Settings

Tap ⚙️ to configure:
- **Ollama URL**: `http://localhost:11434` (or your server IP)
- **Model**: Select any installed model
- **System Prompt**: Customize AI behavior

---

## Available Models

**Fast & Good:**
```bash
ollama pull orca-mini        # 1.3GB - Very fast
ollama pull mistral          # 4GB - Fast & capable
```

**Balanced:**
```bash
ollama pull llama2           # 4GB - Popular & reliable
ollama pull neural-chat      # 4GB - Chat optimized
```

**Powerful (Slow):**
```bash
ollama pull dolphin-mixtral  # 90GB - Very capable
```

---

## Remote Server

To use Ollama from another machine:

1. On Ollama machine:
   ```bash
   OLLAMA_HOST=0.0.0.0:11434 ollama serve
   ```

2. In app settings:
   ```
   URL: http://YOUR_SERVER_IP:11434
   ```

Done! 🚀
