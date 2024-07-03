<img width="362" alt="Screenshot 2024-07-02 at 9 19 19 PM" src="https://github.com/rodneyg/JustTalk/assets/6868495/e49b2035-617c-4adb-9aa8-6f2ee6ba0254">

# JustTalk

JustTalk is a SwiftUI-based iOS application that allows users to record audio, transcribe the audio using OpenAI's Whisper model, and transform the transcribed text into various formats such as email, summary, story, and text messages.

## Features

- **Audio Recording**: Easily start, pause, and stop audio recordings.
- **Transcription**: Transcribe audio files to text using OpenAI's Whisper model.
- **Text Transformation**: Transform transcribed text into different formats such as casual text messages, emails, summaries, and stories.
- **Debug Information**: View debug information such as recording status and file details.

## Screenshots

To be added...

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.1+
- OpenAI API Key

## Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/yourusername/JustTalk.git
    cd JustTalk
    ```

2. **Open the project in Xcode**:

    ```bash
    open JustTalk.xcodeproj
    ```

3. **Install dependencies** (if any):
    - Ensure you have Swift Package Manager (SPM) configured. Dependencies are managed through SPM.

4. **Set up OpenAI API**:
    - Obtain your API key from [OpenAI](https://openai.com/).
    - Replace the placeholder `apiToken` in the `ContentView.swift`:

    ```swift
    let openAI = OpenAI(apiToken: "your_openai_api_token")
    ```

5. **Build and run the project**:
    - Select the target device or simulator.
    - Press `Cmd + R` to build and run the application.

## Usage

1. **Recording Audio**:
    - Tap the record button to start recording.
    - Use the pause/resume button to control the recording session.
    - Stop the recording by tapping the record button again.

2. **Transcription and Transformation**:
    - Select the desired transformation type from the segmented control.
    - Tap the "Transform Text" button to transcribe and transform the recorded audio.

3. **View Transformed Text**:
    - The transformed text will be displayed in the view below.

## Contributing

1. **Fork the repository**:

    Click on the "Fork" button on the top right of this repository page.

2. **Clone your fork**:

    ```bash
    git clone https://github.com/yourusername/JustTalk.git
    cd JustTalk
    ```

3. **Create a branch**:

    ```bash
    git checkout -b my-new-feature
    ```

4. **Make changes**:

    Make your changes to the codebase.

5. **Commit your changes**:

    ```bash
    git add .
    git commit -m 'Add some feature'
    ```

6. **Push to the branch**:

    ```bash
    git push origin my-new-feature
    ```

7. **Create a pull request**:

    Go to the repository on GitHub and create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Special thanks to [OpenAI](https://openai.com/) for providing the Whisper and GPT models that make this project possible.
- Icons provided by [SF Symbols](https://developer.apple.com/sf-symbols/).

## Contact

If you have any questions or feedback, feel free to reach out at [your-email@example.com](mailto:your-email@example.com).

---

Thank you for using JustTalk! Enjoy transforming your audio into meaningful text formats.

---
