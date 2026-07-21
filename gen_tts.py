from gtts import gTTS
import os

os.makedirs('assets/sounds', exist_ok=True)

def generate_tts(text, filename):
    tts = gTTS(text=text, lang='id', slow=False)
    tts.save(f'assets/sounds/{filename}')
    print(f"Generated {filename}")

generate_tts("Mantap! Pengeluaran berhasil dicatat", "success.mp3")
generate_tts("Asik! Cuan masuk boss", "income.mp3")
generate_tts("Yahh, gagal. Coba cek lagi datanya", "error.mp3")
# We'll keep the click and notif as wav, or generate them too.
# For click, we leave the existing wav.
