#!/usr/bin/env python3
import os
import subprocess
import whisper
import sounddevice as sd
from scipy.io.wavfile import write
import requests
import json
import torch
from TTS.api import TTS  # Coqui TTS

# =====================
# 配置参数
# =====================
SAMPLERATE = 16000
RECORD_SECONDS = 5
LLAMA_API = "http://localhost:11434/api/generate"
AUDIO_FILE = "input.wav"
TTS_FILE = "out.wav"

# =====================
# 加载 Whisper 模型
# =====================
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🔊 正在加载 Whisper 模型（small）在 {device} 上...")
model = whisper.load_model("small", device=device)

# =====================
# TTS：Coqui TTS (GPU)
# =====================
print("🔊 正在加载 Coqui TTS 模型...")
# 使用中文 GPU 模型
tts = TTS(model_name="tts_models/zh-CN/baker/tacotron2-DDC", gpu=True, progress_bar=False)

def speak(text: str):
    try:
        # 生成语音到文件
        tts.tts_to_file(text=text, file_path=TTS_FILE)
        # 播放生成的音频
        subprocess.run(["aplay", TTS_FILE], check=True)
    except Exception as e:
        print(f"⚠️ TTS 失败: {e}")

# =====================
# 录音
# =====================
def record_audio(seconds=RECORD_SECONDS, path=AUDIO_FILE):
    print("🎙️ 正在录音...")
    try:
        data = sd.rec(int(SAMPLERATE * seconds), samplerate=SAMPLERATE, channels=1, dtype='int16')
        sd.wait()
        write(path, SAMPLERATE, data)
    except Exception as e:
        print(f"⚠️ 录音失败: {e}")
        return None
    print("✅ 录音完成。")
    return path

# =====================
# Whisper 中文识别
# =====================
def speech_to_text(audio_path):
    if not audio_path or not os.path.exists(audio_path):
        return ""
    try:
        result = model.transcribe(audio_path, language='zh')
        return result.get("text", "").strip()
    except Exception as e:
        print(f"⚠️ Whisper 识别失败: {e}")
        return ""

# =====================
# Ollama 中文聊天
# =====================
def query_llm(prompt):
    prompt = f"请用中文回答：{prompt}"
    try:
        resp = requests.post(LLAMA_API, json={"model": "qwen3:1.7b", "prompt": prompt}, stream=True, timeout=10)
        full_response = ""
        for line in resp.iter_lines():
            if not line:
                continue
            try:
                js = json.loads(line.decode("utf-8"))
                full_response += js.get("response", "")
            except json.JSONDecodeError:
                continue
        return full_response.strip() or "抱歉，我没有理解。"
    except Exception as e:
        print(f"⚠️ Ollama 调用失败: {e}")
        return "抱歉，无法获得回答"

# =====================
# 执行系统命令
# =====================
def execute_command(cmd):
    try:
        subprocess.Popen(cmd, shell=True)
        return f"已执行命令：{cmd}"
    except Exception as e:
        return f"执行失败：{e}"

# =====================
# 主循环（连续监听）
# =====================
def main():
    speak("你好，我是你的本地语音助手，已启动，请直接说话。")
    while True:
        audio_path = record_audio()
        text = speech_to_text(audio_path)
        print(f"🗣️ 识别结果: {text}")

        if not text:
            speak("我没有听清，请再说一遍。")
            continue

        # 退出命令
        if "退出" in text or "再见" in text:
            speak("好的，再见！")
            break
        # 打开应用
        elif "打开" in text:
            app = text.replace("打开", "").strip()
            reply = execute_command(app)
        # 默认聊天
        else:
            reply = query_llm(text)

        print(f"🤖：{reply}")
        speak(reply)

# =====================
# 启动
# =====================
if __name__ == "__main__":
    main()

