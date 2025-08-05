---
# this_file: src_docs/md/03-cli-usage.md
title: Command Line Interface
description: Complete CLI reference with examples
---

# Command Line Interface

The AudioStretchy CLI provides a powerful command-line interface for audio time-stretching. This guide covers all available options and practical usage examples.

## Basic Syntax

```bash
audiostretchy INPUT_FILE OUTPUT_FILE [OPTIONS]
```

### Required Arguments

- **`INPUT_FILE`**: Path to the input audio file
- **`OUTPUT_FILE`**: Path where the processed audio will be saved

### Simple Example

```bash
audiostretchy input.mp3 output.wav --ratio 1.2
```

## Core Parameters

### Stretch Ratio

The most important parameter controlling time-stretching behavior.

```bash
--ratio FLOAT, -r FLOAT
```

- **Default**: `1.0` (no change)
- **Range**: `0.5 - 2.0` (normal), `0.25 - 4.0` (with `--double_range`)
- **> 1.0**: Slower playback (longer duration)
- **< 1.0**: Faster playback (shorter duration)

!!! example "Ratio Examples"
    ```bash
    # 20% slower
    audiostretchy input.wav output.wav --ratio 1.2
    
    # 25% faster  
    audiostretchy input.wav output.wav --ratio 0.75
    
    # Double speed (2x faster)
    audiostretchy input.wav output.wav --ratio 0.5
    ```

### Gap Ratio

Separate stretching ratio for silence/gaps in audio.

```bash
--gap_ratio FLOAT, -g FLOAT
```

- **Default**: `0.0` (uses main ratio for gaps)
- **Usage**: Set different ratio for silent portions

!!! note "Gap Ratio Limitation"
    Current Python implementation doesn't pre-segment audio. The C library may use this parameter internally, but effectiveness depends on the library's silence detection.

```bash
# Different gap handling
audiostretchy speech.wav output.wav --ratio 1.3 --gap_ratio 1.0
```

## Frequency Detection Parameters

Control how the algorithm detects audio periods and fundamental frequencies.

### Upper Frequency Limit

```bash
--upper_freq INT, -u INT
```

- **Default**: `333` Hz
- **Range**: Typically `200-500` Hz
- **Purpose**: Upper limit for period detection

### Lower Frequency Limit

```bash
--lower_freq INT, -l INT
```

- **Default**: `55` Hz  
- **Range**: Typically `50-100` Hz
- **Purpose**: Lower limit for period detection

!!! tip "Frequency Optimization"
    - **Speech**: `--upper_freq 300 --lower_freq 80`
    - **Music**: `--upper_freq 400 --lower_freq 50`
    - **Bass-heavy**: `--lower_freq 30`

```bash
# Optimize for speech
audiostretchy speech.wav output.wav --ratio 1.2 --upper_freq 300 --lower_freq 80

# Optimize for music with wide frequency range
audiostretchy music.wav output.wav --ratio 1.1 --upper_freq 450 --lower_freq 40
```

## Advanced Algorithm Options

### Double Range Mode

```bash
--double_range BOOL, -d BOOL
```

- **Default**: `False`
- **Effect**: Extends ratio range to `0.25-4.0` instead of `0.5-2.0`
- **Values**: `True` or `False`

```bash
# Enable extreme stretching
audiostretchy input.wav output.wav --ratio 0.3 --double_range True
```

### Fast Detection

```bash
--fast_detection BOOL, -f BOOL
```

- **Default**: `False`
- **Effect**: Faster but potentially lower quality processing
- **Trade-off**: Speed vs. quality

```bash
# Quick processing for tests
audiostretchy large_file.wav test_output.wav --ratio 1.1 --fast_detection True
```

### Normal Detection

```bash
--normal_detection BOOL, -n BOOL
```

- **Default**: `False`
- **Effect**: Forces normal detection method
- **Usage**: Override automatic detection selection

```bash
# Force high-quality detection
audiostretchy input.wav output.wav --ratio 1.2 --normal_detection True
```

## Audio Processing Options

### Sample Rate

```bash
--sample_rate INT, -s INT
```

- **Default**: `0` (preserve original)
- **Effect**: Resamples output to specified rate
- **Common rates**: `22050`, `44100`, `48000`, `96000`

```bash
# Resample to CD quality
audiostretchy input.wav output.wav --ratio 1.1 --sample_rate 44100

# Upsample to professional rate
audiostretchy input.wav output.wav --ratio 1.0 --sample_rate 96000
```

## Advanced Parameters

### Buffer Size

```bash
--buffer_ms FLOAT, -b FLOAT
```

- **Default**: `25` ms
- **Purpose**: Buffer size for internal processing
- **Impact**: Affects memory usage and processing behavior

### Threshold Gap Detection

```bash
--threshold_gap_db FLOAT, -t FLOAT
```

- **Default**: `-40` dB
- **Purpose**: Silence detection threshold
- **Usage**: Lower values detect more silence

```bash
# Sensitive gap detection
audiostretchy speech.wav output.wav --ratio 1.2 --threshold_gap_db -35

# Less sensitive (quieter sounds treated as non-silence)
audiostretchy noisy_audio.wav output.wav --ratio 1.1 --threshold_gap_db -50
```

## Practical Examples

### Podcast Processing

Speed up podcast for faster listening:

```bash
# Standard speedup
audiostretchy podcast.mp3 faster_podcast.mp3 --ratio 0.8

# Aggressive speedup with speech optimization
audiostretchy podcast.mp3 very_fast.mp3 --ratio 0.7 --upper_freq 300 --fast_detection True
```

### Music Practice

Slow down music for learning:

```bash
# Guitar practice version
audiostretchy song.mp3 practice.wav --ratio 1.4 --upper_freq 400

# Very slow for difficult passages
audiostretchy complex_piece.wav super_slow.wav --ratio 2.0 --double_range True
```

### Voice Analysis

Detailed speech analysis:

```bash
# Slow, high-quality speech analysis
audiostretchy speech.wav analysis.wav --ratio 1.6 --upper_freq 350 --lower_freq 75 --normal_detection True
```

### Format Conversion

Combine stretching with format conversion:

```bash
# MP3 to WAV with slight speedup
audiostretchy input.mp3 output.wav --ratio 0.95 --sample_rate 44100

# Multi-format workflow
audiostretchy source.flac intermediate.wav --ratio 1.1
audiostretchy intermediate.wav final.mp3 --ratio 1.0 --sample_rate 48000
```

## Batch Processing Scripts

### Bash Script Example

```bash
#!/bin/bash
# Process all MP3 files in a directory

RATIO=1.2
INPUT_DIR="./input"
OUTPUT_DIR="./output"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.mp3; do
    filename=$(basename "$file" .mp3)
    audiostretchy "$file" "$OUTPUT_DIR/${filename}_stretched.wav" --ratio $RATIO
    echo "Processed: $filename"
done
```

### PowerShell Script Example

```powershell
# PowerShell batch processing
$ratio = 1.2
$inputDir = ".\input"
$outputDir = ".\output"

New-Item -ItemType Directory -Force -Path $outputDir

Get-ChildItem -Path $inputDir -Filter "*.mp3" | ForEach-Object {
    $outputFile = Join-Path $outputDir ($_.BaseName + "_stretched.wav")
    audiostretchy $_.FullName $outputFile --ratio $ratio
    Write-Host "Processed: $($_.Name)"
}
```

## Error Handling and Troubleshooting

### Common Error Messages

**File not found:**
```
Error: Could not open input file
```
Check file path and permissions.

**Unsupported format:**
```
Error: Could not determine file format
```
Ensure FFmpeg is installed for compressed formats.

**Invalid ratio:**
```
Error: Ratio out of range
```
Use `--double_range True` for extreme ratios.

### Debugging Tips

1. **Test with WAV files** first (no FFmpeg dependency)
2. **Start with default parameters** before customizing
3. **Use `--fast_detection True`** for quick tests
4. **Check file permissions** for both input and output

### Verbose Output

For debugging, you can capture detailed information:

```bash
# Redirect output for logging
audiostretchy input.wav output.wav --ratio 1.2 2>&1 | tee process.log
```

## Performance Considerations

### File Size vs. Processing Time

| Input Size | Typical Processing Time | Memory Usage |
|------------|------------------------|--------------|
| < 1 MB | < 1 second | Low |
| 1-10 MB | 1-10 seconds | Moderate |
| 10-100 MB | 10-60 seconds | Moderate |
| > 100 MB | 1+ minutes | Higher |

### Optimization Tips

1. **Use `--fast_detection True`** for large files during testing
2. **Process in batches** rather than individually for many files
3. **Choose appropriate output formats** (WAV for quality, MP3 for size)
4. **Consider sample rate** (lower rates process faster)

## Integration with Other Tools

### FFmpeg Pipeline

```bash
# Extract audio, stretch, then encode
ffmpeg -i video.mp4 -vn audio.wav
audiostretchy audio.wav stretched.wav --ratio 1.2
ffmpeg -i stretched.wav -i video.mp4 -c:v copy -map 1:v -map 0:a output.mp4
```

### SoX Integration

```bash
# Apply additional effects after stretching
audiostretchy input.wav stretched.wav --ratio 1.1
sox stretched.wav final.wav norm reverb
```

## Next Steps

- **Python Integration**: Learn [Python API](04-python-api.md) for programmatic control
- **Understanding Internals**: Read [How It Works](05-how-it-works.md)
- **Parameter Tuning**: Check [Parameters Reference](07-parameters-reference.md) for detailed explanations