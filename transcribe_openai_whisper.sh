#!/bin/bash

# === EINSTELLUNGEN - HIER ANPASSEN ===
AUDIO_DIR="/mnt/c/Users/peerh/Downloads"
OUTPUT_DIR="/mnt/c/Users/peerh/Transcripts"

# Markennamen für bessere Erkennung
BRAND_PROMPT="In dieser Aufnahme werden folgende Markennamen erwähnt: jonastone, stonenaturelle"

# === AB HIER NICHTS ÄNDERN ===
# Log-Datei erstellen
LOG_FILE="$OUTPUT_DIR/transcription_log.txt"
SUMMARY_FILE="$OUTPUT_DIR/transcription_summary.txt"

echo "🎵 Whisper Audio Transcription gestartet"
echo "Audio-Dateien von: $AUDIO_DIR"
echo "Ausgabe nach: $OUTPUT_DIR"
echo "⚙️  Optimiert für Videos mit Musikintros"
echo "Log-Datei: $LOG_FILE"
echo "=================================="

# Ordner erstellen
mkdir -p "$OUTPUT_DIR"

# Log-Datei initialisieren
cat > "$LOG_FILE" << EOF
WHISPER TRANSCRIPTION LOG
========================
Start: $(date)
Audio-Verzeichnis: $AUDIO_DIR
Ausgabe-Verzeichnis: $OUTPUT_DIR
Markennamen: jonastone, stonenaturelle
Optimiert für: Videos mit Musikintros

EOF

# Whisper aktivieren
source ~/whisper-env/bin/activate

# Zähler für Statistiken
total_audios=$(ls "$AUDIO_DIR"/*.{m4a,mp3,wav,M4A,MP3,WAV,mp4,avi,mkv,mov} 2>/dev/null | wc -l)
current=0
success_count=0
low_word_count=0
error_count=0

echo "📊 Gefundene Audio/Video-Dateien: $total_audios"
echo ""

# Arrays für Statistiken
declare -a low_word_files
declare -a error_files
declare -a good_files

# Alle Audio/Video-Dateien verarbeiten
for audio in "$AUDIO_DIR"/*.{m4a,mp3,wav,M4A,MP3,WAV,mp4,avi,mkv,mov}; do
    if [[ -f "$audio" ]]; then
        current=$((current + 1))
        filename=$(basename "$audio")
        base_name=$(basename "$audio" | cut -d. -f1)
        
        echo "🎵 [$current/$total_audios] Verarbeite: $filename"
        echo "[$current/$total_audios] START: $filename" >> "$LOG_FILE"
        
        start_time=$(date)
        echo "⏳ Verarbeitung läuft (kann bei langen Musikintros dauern)..."
        
        # Whisper mit erweiterten Parametern für bessere Musik/Sprache-Trennung
        if timeout 600 whisper "$audio" \
            --model large \
            --output_dir "$OUTPUT_DIR" \
            --output_format txt \
            --initial_prompt "$BRAND_PROMPT" \
            --condition_on_previous_text True \
            --no_speech_threshold 0.6 \
            --logprob_threshold -1.0 \
            --compression_ratio_threshold 2.4 \
            --verbose True >> "$LOG_FILE" 2>&1; then
            
            # Prüfen ob Transkript erstellt wurde
            transcript_file="$OUTPUT_DIR/$base_name.txt"
            if [[ -f "$transcript_file" ]]; then
                # Wörter und Zeichen zählen
                word_count=$(wc -w < "$transcript_file" 2>/dev/null || echo "0")
                char_count=$(wc -c < "$transcript_file" 2>/dev/null || echo "0")
                end_time=$(date)
                
                # Transkript-Inhalt analysieren
                content=$(cat "$transcript_file" 2>/dev/null)
                
                # Bessere Bewertung für Musikintros
                if [[ $word_count -lt 3 ]] || [[ $char_count -lt 10 ]]; then
                    echo "⚠️  Sehr wenig Text: $filename ($word_count Wörter) - wahrscheinlich nur Musik"
                    echo "WENIG TEXT: $filename - $word_count Wörter, $char_count Zeichen" >> "$LOG_FILE"
                    low_word_files+=("$filename ($word_count Wörter)")
                    ((low_word_count++))
                elif [[ $word_count -lt 10 ]]; then
                    echo "⚠️  Kurzer Text: $filename ($word_count Wörter) - möglicherweise hauptsächlich Musik"
                    echo "KURZ: $filename - $word_count Wörter erkannt" >> "$LOG_FILE"
                    low_word_files+=("$filename ($word_count Wörter - kurz)")
                    ((low_word_count++))
                else
                    echo "✅ Sprache erkannt: $filename ($word_count Wörter)"
                    echo "ERFOLG: $filename - $word_count Wörter erkannt" >> "$LOG_FILE"
                    good_files+=("$filename ($word_count Wörter)")
                    ((success_count++))
                fi
                
                # Erste 100 Zeichen des Transkripts ins Log
                echo "Inhalt (Anfang): ${content:0:100}..." >> "$LOG_FILE"
                echo "Zeit: $start_time bis $end_time" >> "$LOG_FILE"
            else
                echo "❌ Fehler: Keine Transkription erstellt für $filename"
                echo "FEHLER: $filename - Keine Ausgabedatei erstellt" >> "$LOG_FILE"
                error_files+=("$filename")
                ((error_count++))
            fi
        else
            echo "❌ Timeout (10 Min) oder Fehler bei $filename"
            echo "FEHLER: $filename - Timeout oder Verarbeitungsfehler" >> "$LOG_FILE"
            error_files+=("$filename (Timeout)")
            ((error_count++))
        fi
        
        echo "--------------------------------" >> "$LOG_FILE"
        echo "--------------------------------"
    fi
done

# Erweiterte Zusammenfassung erstellen
cat > "$SUMMARY_FILE" << EOF
WHISPER TRANSCRIPTION ZUSAMMENFASSUNG
===================================
Datum: $(date)
Gesamte Dateien: $total_audios
✅ Mit Sprache erkannt: $success_count
⚠️  Wenig/kein Text: $low_word_count
❌ Fehler: $error_count

DATEIEN MIT ERKANNTER SPRACHE:
EOF

if [[ ${#good_files[@]} -gt 0 ]]; then
    for file in "${good_files[@]}"; do
        echo "✅ $file" >> "$SUMMARY_FILE"
    done
else
    echo "- Keine" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "DATEIEN MIT WENIG/KEINEM TEXT (wahrscheinlich nur Musik):" >> "$SUMMARY_FILE"

if [[ ${#low_word_files[@]} -gt 0 ]]; then
    for file in "${low_word_files[@]}"; do
        echo "⚠️  $file" >> "$SUMMARY_FILE"
    done
else
    echo "- Keine" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "FEHLERHAFTE DATEIEN:" >> "$SUMMARY_FILE"

if [[ ${#error_files[@]} -gt 0 ]]; then
    for file in "${error_files[@]}"; do
        echo "❌ $file" >> "$SUMMARY_FILE"
    done
else
    echo "- Keine" >> "$SUMMARY_FILE"
fi

# Auch in die Haupt-Log schreiben
cat "$SUMMARY_FILE" >> "$LOG_FILE"

echo ""
echo "🎉 ALLE DATEIEN VERARBEITET!"
echo "Transkripte gespeichert in: $OUTPUT_DIR"
echo "📋 Detailliertes Log: $LOG_FILE"
echo "📊 Zusammenfassung: $SUMMARY_FILE"
echo ""
echo "📈 FINALE STATISTIK:"
echo "   ✅ Mit Sprache: $success_count"
echo "   ⚠️  Wenig Text: $low_word_count" 
echo "   ❌ Fehler: $error_count"

# Zusammenfassung anzeigen
echo ""
echo "📋 ERGEBNIS-ÜBERSICHT:"
cat "$SUMMARY_FILE"