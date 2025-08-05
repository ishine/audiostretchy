---
# this_file: src_docs/md/07-parameters-reference.md
title: Parameters Reference
description: Detailed parameter explanations and tuning
---

# Parameters Reference

This comprehensive guide explains every AudioStretchy parameter, their interactions, and how to optimize them for different use cases.

## Core Parameters

### Stretch Ratio

The fundamental parameter controlling time-stretching behavior.

#### `ratio` (float)

**Default**: `1.0`  
**Range**: `0.5 - 2.0` (normal), `0.25 - 4.0` (with `double_range=True`)  
**CLI**: `--ratio`, `-r`

Controls the time-stretching factor:

- **`ratio = 1.0`**: No change (original duration)
- **`ratio > 1.0`**: Slower playback (longer duration)  
- **`ratio < 1.0`**: Faster playback (shorter duration)

!!! example "Ratio Examples"
    ```python
    # 20% slower (duration × 1.2)
    stretch_audio("input.wav", "output.wav", ratio=1.2)
    
    # 25% faster (duration × 0.75)  
    stretch_audio("input.wav", "output.wav", ratio=0.75)
    
    # Double speed (half duration)
    stretch_audio("input.wav", "output.wav", ratio=0.5)
    ```

**Quality Considerations**:

| Ratio Range | Quality | Use Cases |
|-------------|---------|-----------|
| 0.8 - 1.25 | Excellent | General use, subtle adjustments |
| 0.5 - 0.8, 1.25 - 2.0 | Good | Podcasts, practice material |
| 0.25 - 0.5, 2.0 - 4.0 | Fair | Special effects, analysis |

#### `gap_ratio` (float)

**Default**: `0.0` (use main ratio)  
**Range**: `0.0 - 4.0`  
**CLI**: `--gap_ratio`, `-g`

Separate stretching ratio for silence/gaps in audio.

```python
# Stretch speech 1.3x but keep silence at normal speed
stretch_audio("speech.wav", "output.wav", ratio=1.3, gap_ratio=1.0)

# Compress gaps more aggressively than speech
stretch_audio("podcast.wav", "output.wav", ratio=0.9, gap_ratio=0.5)
```

!!! warning "Current Limitation"
    The Python wrapper doesn't pre-segment audio for gap detection. Effectiveness depends on the C library's internal silence detection capabilities.

**When to Use**:
- Podcasts with long pauses
- Speech with significant silence
- Presentations with gaps between sections

## Frequency Detection Parameters

These parameters control how the algorithm identifies audio periods and fundamental frequencies.

### `upper_freq` (int)

**Default**: `333` Hz  
**Range**: `50 - 1000` Hz (typical)  
**CLI**: `--upper_freq`, `-u`

Upper frequency limit for period detection.

**Content Optimization**:

=== "Speech"

    ```python
    # Human speech fundamentals rarely exceed 300Hz
    stretch_audio("speech.wav", "output.wav", 
                 ratio=1.2, upper_freq=300)
    ```

=== "Music"

    ```python
    # Instruments can have higher fundamentals
    stretch_audio("music.wav", "output.wav", 
                 ratio=1.1, upper_freq=400)
    ```

=== "Male Speech"

    ```python
    # Male voices typically lower
    stretch_audio("male_voice.wav", "output.wav", 
                 ratio=1.3, upper_freq=250)
    ```

=== "Female Speech"

    ```python
    # Female voices can be higher
    stretch_audio("female_voice.wav", "output.wav", 
                 ratio=1.3, upper_freq=350)
    ```

**Quality Impact**:
- **Too low**: May miss higher-pitched content
- **Too high**: May detect false periods in noise
- **Optimal**: Match the fundamental frequency range of your content

### `lower_freq` (int)

**Default**: `55` Hz  
**Range**: `20 - 200` Hz (typical)  
**CLI**: `--lower_freq`, `-l`

Lower frequency limit for period detection.

**Content Optimization**:

```python
# Bass-heavy music
stretch_audio("bass_music.wav", "output.wav", 
             ratio=1.1, lower_freq=30)

# Speech (no very low fundamentals needed)  
stretch_audio("speech.wav", "output.wav", 
             ratio=1.2, lower_freq=80)

# Full-range music
stretch_audio("orchestral.wav", "output.wav", 
             ratio=1.15, lower_freq=40)
```

**Frequency Range Guidelines**:

| Content Type | Lower Freq | Upper Freq | Reasoning |
|--------------|------------|------------|-----------|
| Male Speech | 80 Hz | 250 Hz | Typical male fundamental range |
| Female Speech | 80 Hz | 350 Hz | Higher female fundamentals |
| Mixed Speech | 80 Hz | 300 Hz | Safe range for both genders |
| Pop Music | 50 Hz | 400 Hz | Vocals + most instruments |
| Classical | 40 Hz | 450 Hz | Full orchestral range |
| Electronic | 30 Hz | 500 Hz | Synthetic sounds, wide range |

## Algorithm Control Parameters

### `double_range` (bool)

**Default**: `False`  
**Range**: `True` or `False`  
**CLI**: `--double_range`, `-d`

Enables extended ratio range (0.25 - 4.0 instead of 0.5 - 2.0).

```python
# Enable extreme stretching
stretch_audio("input.wav", "output.wav", 
             ratio=0.3, double_range=True)

# 4x slower for detailed analysis
stretch_audio("complex_audio.wav", "analysis.wav", 
             ratio=4.0, double_range=True)
```

**When to Enable**:
- Extreme time compression (< 0.5x)
- Very slow analysis (> 2.0x)
- Special effects processing
- Transcription aid (very slow speech)

**Quality Trade-offs**:
- Ratios outside 0.5-2.0 may introduce more artifacts
- Use with caution for production audio
- Test thoroughly for acceptable quality

### `fast_detection` (bool)

**Default**: `False`  
**Range**: `True` or `False`  
**CLI**: `--fast_detection`, `-f`

Enables faster but potentially lower quality period detection.

```python
# Quick processing for testing
stretch_audio("test_file.wav", "quick_test.wav", 
             ratio=1.2, fast_detection=True)

# Batch processing with speed priority
for file in audio_files:
    stretch_audio(file, f"fast_{file}", 
                 ratio=0.8, fast_detection=True)
```

**Use Cases**:
- **Development/Testing**: Quick iterations during development
- **Batch Processing**: When processing many files
- **Real-time Applications**: Reduced latency requirements
- **Preview Generation**: Quick previews before final processing

**Quality Considerations**:
- Generally produces acceptable quality for most content
- May struggle with complex harmonic content
- Always test critical applications with `fast_detection=False`

### `normal_detection` (bool)

**Default**: `False`  
**Range**: `True` or `False`  
**CLI**: `--normal_detection`, `-n`

Forces normal (high-quality) period detection method.

```python
# Force highest quality for critical audio
stretch_audio("master_recording.wav", "stretched_master.wav", 
             ratio=1.1, normal_detection=True)

# Override automatic detection selection
stretch_audio("complex_music.wav", "output.wav", 
             ratio=1.3, normal_detection=True)
```

**When to Use**:
- Critical/production audio
- Complex musical content
- When automatic detection isn't optimal
- Final masters and releases

## Audio Processing Parameters

### `sample_rate` (int)

**Default**: `0` (preserve original)  
**Range**: `8000 - 192000` Hz (typical)  
**CLI**: `--sample_rate`, `-s`

Target sample rate for output resampling.

```python
# Downsample to reduce file size
stretch_audio("hd_audio.wav", "compressed.wav", 
             ratio=1.1, sample_rate=44100)

# Upsample for high-quality processing
stretch_audio("input.wav", "hq_output.wav", 
             ratio=1.2, sample_rate=96000)

# Match target system requirements
stretch_audio("source.flac", "phone_optimized.mp3", 
             ratio=0.9, sample_rate=22050)
```

**Common Sample Rates**:

| Rate | Quality | Use Case |
|------|---------|----------|
| 22050 Hz | Low | Voice, podcasts, mobile |
| 44100 Hz | CD Quality | General music, streaming |
| 48000 Hz | Professional | Video, broadcast |
| 96000 Hz | High-res | Mastering, archival |

**Resampling Guidelines**:
- **Upsampling**: Generally safe, slight quality improvement possible
- **Downsampling**: May lose high-frequency content
- **Matching**: Use target system's native rate when possible

## Advanced Parameters

### `buffer_ms` (float)

**Default**: `25.0` ms  
**Range**: `5.0 - 100.0` ms (typical)  
**CLI**: `--buffer_ms`, `-b`

Buffer size for internal processing, potentially affecting silence detection.

```python
# Smaller buffer for responsive processing
stretch_audio("speech.wav", "output.wav", 
             ratio=1.2, buffer_ms=10.0)

# Larger buffer for complex audio
stretch_audio("dense_music.wav", "output.wav", 
             ratio=1.1, buffer_ms=50.0)
```

**Impact**:
- **Smaller buffers**: More responsive, potentially less smooth
- **Larger buffers**: Smoother processing, higher latency
- **Memory usage**: Larger buffers use more memory

### `threshold_gap_db` (float)

**Default**: `-40.0` dB  
**Range**: `-60.0` to `-20.0` dB (typical)  
**CLI**: `--threshold_gap_db`, `-t`

Silence detection threshold for gap handling.

```python
# Sensitive gap detection (quiet passages as silence)
stretch_audio("classical.wav", "output.wav", 
             ratio=1.2, threshold_gap_db=-35.0)

# Less sensitive (only true silence detected)
stretch_audio("noisy_recording.wav", "output.wav", 
             ratio=1.1, threshold_gap_db=-50.0)
```

**Threshold Guidelines**:

| Content Type | Threshold | Reasoning |
|--------------|-----------|-----------|
| Studio Recording | -45 dB | Clean, low noise floor |
| Live Recording | -35 dB | Higher noise floor |
| Compressed Audio | -40 dB | General purpose |
| Noisy Source | -30 dB | Only detect obvious silence |

## Parameter Combinations

### Optimized Presets

#### Speech Processing

```python
speech_params = {
    'upper_freq': 300,
    'lower_freq': 80,
    'normal_detection': True,
    'threshold_gap_db': -40.0
}

stretch_audio("speech.wav", "output.wav", 
             ratio=1.3, **speech_params)
```

#### Music Processing

```python
music_params = {
    'upper_freq': 400,
    'lower_freq': 50,
    'normal_detection': True,
    'buffer_ms': 30.0
}

stretch_audio("song.flac", "practice.wav", 
             ratio=1.5, **music_params)
```

#### Fast Processing

```python
fast_params = {
    'fast_detection': True,
    'buffer_ms': 15.0,
    'sample_rate': 44100
}

stretch_audio("large_file.wav", "quick_result.mp3", 
             ratio=0.8, **fast_params)
```

#### High Quality

```python
hq_params = {
    'normal_detection': True,
    'buffer_ms': 40.0,
    'sample_rate': 96000,
    'upper_freq': 450,
    'lower_freq': 40
}

stretch_audio("master.wav", "hq_stretched.wav", 
             ratio=1.1, **hq_params)
```

## Parameter Validation

### Automatic Validation

AudioStretchy automatically validates parameters:

```python
# These will raise ValueError
stretch_audio("input.wav", "output.wav", ratio=-1.0)     # Negative ratio
stretch_audio("input.wav", "output.wav", ratio=5.0)      # Ratio too large
stretch_audio("input.wav", "output.wav", upper_freq=0)   # Invalid frequency
```

### Custom Validation

```python
def validate_parameters(**params):
    """Custom parameter validation"""
    
    ratio = params.get('ratio', 1.0)
    upper_freq = params.get('upper_freq', 333)
    lower_freq = params.get('lower_freq', 55)
    
    # Ratio validation
    if ratio <= 0:
        raise ValueError("Ratio must be positive")
    
    if ratio > 2.0 and not params.get('double_range', False):
        raise ValueError("Ratio > 2.0 requires double_range=True")
    
    # Frequency validation  
    if upper_freq <= lower_freq:
        raise ValueError("upper_freq must be greater than lower_freq")
    
    if lower_freq < 20:
        raise ValueError("lower_freq too low (< 20 Hz)")
    
    return True

# Usage
params = {'ratio': 1.5, 'upper_freq': 350, 'lower_freq': 80}
validate_parameters(**params)
stretch_audio("input.wav", "output.wav", **params)
```

## Performance vs. Quality Trade-offs

### Processing Speed Factors

| Parameter | Speed Impact | Quality Impact |
|-----------|--------------|----------------|
| `fast_detection=True` | +50% faster | -10% quality |
| `buffer_ms=10` | +20% faster | -5% quality |
| `sample_rate=22050` | +30% faster | -variable |
| `normal_detection=True` | -30% slower | +15% quality |

### Optimization Strategies

#### Speed-Optimized

```python
speed_config = {
    'fast_detection': True,
    'buffer_ms': 10.0,
    'sample_rate': 22050
}
```

#### Quality-Optimized

```python
quality_config = {
    'normal_detection': True,
    'buffer_ms': 40.0,
    'sample_rate': 96000
}
```

#### Balanced

```python
balanced_config = {
    'buffer_ms': 25.0,
    'sample_rate': 48000,
    # Use defaults for detection
}
```

## Troubleshooting Parameters

### Common Issues and Solutions

#### Poor Quality Output

**Symptoms**: Robotic sound, artifacts, distortion

**Solutions**:
```python
# Try these improvements
improved_params = {
    'normal_detection': True,      # Higher quality detection
    'buffer_ms': 35.0,            # Larger buffer
    'upper_freq': 350,            # Adjust frequency range
    'lower_freq': 60              # Match content better
}
```

#### Processing Too Slow

**Symptoms**: Long processing times

**Solutions**:
```python
# Speed optimizations
fast_params = {
    'fast_detection': True,       # Faster algorithm
    'buffer_ms': 15.0,           # Smaller buffer
    'sample_rate': 44100         # Reduce sample rate
}
```

#### Artifacts in Speech

**Symptoms**: Unnatural speech, choppy delivery

**Solutions**:
```python
# Speech-specific tuning
speech_fix = {
    'upper_freq': 250,           # Lower for male speech
    'lower_freq': 85,            # Remove very low frequencies
    'threshold_gap_db': -35.0,   # Better gap detection
    'normal_detection': True     # High quality
}
```

#### Silent Gaps Not Handled Well

**Symptoms**: Gaps stretched incorrectly

**Solutions**:
```python
# Better gap handling
gap_fix = {
    'gap_ratio': 1.0,            # Don't stretch silence
    'threshold_gap_db': -40.0,   # Adjust sensitivity
    'buffer_ms': 30.0            # Larger buffer for detection
}
```

## Future Parameter Enhancements

### Planned Additions

- **`quality_mode`**: Automatic quality/speed selection
- **`content_type`**: Automatic parameter optimization
- **`real_time`**: Streaming processing parameters
- **`noise_reduction`**: Integrated noise handling

### Advanced Features

- **Adaptive parameters**: Automatic adjustment based on content analysis
- **Perceptual optimization**: Parameters based on psychoacoustic models
- **Multi-band processing**: Different parameters for frequency bands

Next: [Contributing](08-contributing.md) for development guidelines