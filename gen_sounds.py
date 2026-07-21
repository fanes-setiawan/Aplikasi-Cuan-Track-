import wave
import math
import struct
import os

def generate_wave(filename, frequencies, durations, waveform='sine', volume=0.5):
    sample_rate = 44100
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        
        for freq, duration in zip(frequencies, durations):
            num_samples = int(sample_rate * duration)
            for i in range(num_samples):
                t = float(i) / sample_rate
                if waveform == 'sine':
                    value = math.sin(2.0 * math.pi * freq * t)
                elif waveform == 'square':
                    value = 1.0 if math.sin(2.0 * math.pi * freq * t) > 0 else -1.0
                elif waveform == 'triangle':
                    value = 2.0 * abs(2.0 * (freq * t - math.floor(freq * t + 0.5))) - 1.0
                
                # apply simple envelope (fade out at the end)
                envelope = 1.0
                if i > num_samples - int(0.05 * sample_rate): # fade out last 50ms
                    envelope = (num_samples - i) / int(0.05 * sample_rate)
                if i < int(0.01 * sample_rate): # fade in first 10ms
                    envelope = i / int(0.01 * sample_rate)
                    
                sample = int(value * envelope * volume * 32767.0)
                wf.writeframes(struct.pack('<h', sample))

# Generate simple pleasant UI sounds
generate_wave('assets/sounds/success.wav', [523.25, 659.25, 783.99], [0.1, 0.1, 0.2], 'sine', 0.4) # C5, E5, G5
generate_wave('assets/sounds/error.wav', [250.0, 200.0], [0.15, 0.25], 'square', 0.2) # Low discordant
generate_wave('assets/sounds/click.wav', [1000.0], [0.03], 'sine', 0.2) # Short pop
generate_wave('assets/sounds/notification.wav', [659.25, 880.0], [0.15, 0.3], 'sine', 0.4) # E5, A5
generate_wave('assets/sounds/income.wav', [1500.0, 2000.0, 2500.0], [0.05, 0.05, 0.15], 'sine', 0.4) # Fast high pitched "coin" sound
print("Sound assets generated successfully.")
