"""Génère les bruitages provisoires du prototype (sons synthétiques, aucun fichier externe).

Usage : python3 tools/generate_sfx.py  ->  écrit assets/sfx/*.wav
Ils seront remplacés par de vrais sons plus tard.
"""
import os
import wave

import numpy as np

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")
rng = np.random.default_rng(7)


def t(duration):
    return np.arange(int(RATE * duration)) / RATE


def env(n, attack=0.005, release=None):
    """Enveloppe attaque rapide + décroissance exponentielle."""
    x = np.arange(n) / RATE
    a = np.clip(x / max(attack, 1e-4), 0, 1)
    rel = release if release else len(x) / RATE
    return a * np.exp(-x / (rel / 4.0))


def tone(freqs, duration, wave_type="sine", attack=0.005, release=None):
    x = t(duration)
    if np.isscalar(freqs):
        phase = 2 * np.pi * freqs * x
    else:
        f = np.interp(x, np.linspace(0, duration, len(freqs)), freqs)
        phase = 2 * np.pi * np.cumsum(f) / RATE
    if wave_type == "square":
        sig = np.sign(np.sin(phase)) * 0.6
    elif wave_type == "triangle":
        sig = 2 / np.pi * np.arcsin(np.sin(phase))
    else:
        sig = np.sin(phase)
    return sig * env(len(x), attack, release)


def noise(duration, lowpass=0.2, attack=0.002, release=None):
    n = int(RATE * duration)
    raw = rng.uniform(-1, 1, n)
    out = np.zeros(n)
    acc = 0.0
    for i in range(n):
        acc += lowpass * (raw[i] - acc)
        out[i] = acc
    out /= max(np.abs(out).max(), 1e-6)
    return out * env(n, attack, release)


def seq(*parts, gap=0.0):
    pieces = []
    for p in parts:
        pieces.append(p)
        if gap:
            pieces.append(np.zeros(int(RATE * gap)))
    return np.concatenate(pieces)


def mix(*sigs):
    n = max(len(s) for s in sigs)
    out = np.zeros(n)
    for s in sigs:
        out[: len(s)] += s
    return out


def save(name, sig, volume=0.6):
    sig = sig / max(np.abs(sig).max(), 1e-6) * volume
    data = (sig * 32767).astype(np.int16)
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(data.tobytes())


def main():
    os.makedirs(OUT, exist_ok=True)
    save("clic", tone(1400, 0.05, "triangle", release=0.04), 0.35)
    save("tic", tone(1000, 0.04, "square", release=0.03), 0.25)
    save("coup", mix(noise(0.12, 0.35, release=0.1), tone([180, 70], 0.12, release=0.1) * 0.8), 0.55)
    save("gros_coup", mix(noise(0.3, 0.2, release=0.28), tone([140, 40], 0.3, release=0.3)), 0.75)
    save("soin", seq(tone(660, 0.09, release=0.12), tone(880, 0.09, release=0.12), tone(1175, 0.16, release=0.2)), 0.4)
    save("bloque", mix(tone(1500, 0.25, release=0.2), tone(2370, 0.25, release=0.15) * 0.6, noise(0.03, 0.6) * 0.4), 0.45)
    save("ko", mix(tone([420, 60], 0.45, "square", release=0.45), noise(0.2, 0.15) * 0.4), 0.55)
    save("synergie", mix(
        seq(tone(523, 0.08), tone(659, 0.08), tone(784, 0.08), tone(1047, 0.35, release=0.5)),
        seq(np.zeros(int(RATE * 0.24)), tone(1568, 0.35, "triangle", release=0.5) * 0.4)), 0.55)
    save("forte", mix(noise(0.45, 0.08, attack=0.15, release=0.45), tone([90, 45], 0.5, release=0.5)), 0.7)
    save("tour", tone([500, 750], 0.12, "triangle", release=0.15), 0.3)
    save("releve", seq(tone(523, 0.07), tone(784, 0.07), tone(1047, 0.07), tone(1568, 0.3, "triangle", release=0.4)), 0.45)
    save("victoire", seq(tone(523, 0.12, "square"), tone(659, 0.12, "square"), tone(784, 0.12, "square"),
                         tone(1047, 0.5, "square", release=0.6)), 0.4)
    save("defaite", seq(tone(392, 0.2, "triangle"), tone(330, 0.2, "triangle"), tone(262, 0.6, "triangle", release=0.7)), 0.45)


if __name__ == "__main__":
    main()
