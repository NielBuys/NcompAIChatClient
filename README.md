\# NComp AI Chat Client



A lightweight Windows GUI client to chat with AI models served by an Ollama API endpoint.



---



\## Overview



\*\*NComp AI Chat Client\*\* provides a simple interface to send messages and receive replies from AI models via Ollama’s API. It supports ongoing chat history display and message formatting including emojis and multiline replies.



---



\## Features



\- Connect to any Ollama URL with a chosen model.

\- Send messages and receive streamed AI responses.

\- Maintains chat history with formatted output.

\- Supports emojis and multiline text display.

\- New Chat button to reset conversation.

\- Simple and intuitive UI built with Lazarus.



---



\## Installation



Download the latest Windows installer executable from the \[Releases](https://github.com/NielBuys/NcompAIChatClient/releases) section:



\- `ncompaichatclientsetup.exe`



Run the installer and follow prompts to install the client on your system.



---



\## Usage



1\. Launch \*\*NComp AI Chat Client\*\*.

2\. Enter the Ollama API URL (e.g. `http://localhost:11434/api/chat` or your server IP).

3\. Enter the AI model name (e.g. `gemma3n:e4b`).

4\. Click \*\*Send\*\* after typing your message.

5\. View AI replies in the chat history window.

6\. Use \*\*New Chat\*\* to clear conversation and start fresh.



---



\## Requirements



\- Windows OS (tested on Windows 10/11).

\- Network access to an Ollama API endpoint.

\- Installed OpenSSL libraries (bundled or system-wide).



---



\## Development



This client is built with \[Lazarus IDE](https://www.lazarus-ide.org/) and \[Free Pascal Compiler](https://www.freepascal.org/).



The UI components include standard Lazarus controls such as `TMemo`, `TEdit`, `TButton`.



---



\## License



\[MIT License](LICENSE)



---



\## Screenshots



!\[NComp AI Chat Client Screenshot](./screenshot.png)



---



\## Feedback and Contributions



Feel free to open issues or submit pull requests to improve the client.



---



\*Made with ❤️ by Niel Buys\*





