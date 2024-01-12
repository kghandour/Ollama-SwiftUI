# Changelog
## Version 1.1.1 (2023-01-12)
1.1.1 brings some bug fixes and quality of life adjustments
### New
1. Added Request timeout option in the settings. Some local environments might be too slow that the default 60 seconds
timeout is not enough. Now you can adjust it in the settings.
2. Added Resource timeout option in the settings.

### Fixed
1. Fixes #26 Opening the application without having any models downloaded does not result in a crash anymore. 

### Improved
1. After downloading a model it forces a refresh.
2. Better errors visualization especially in the manage models view.

## Version 1.1 (2023-12-30)
Happy New Year! 
New version of Ollama Swift is here. Major contribution by @HiRoS-neko
### New
1. Now using "Chat" option from Ollama.ai. Now the chat understands previous messages when answering the questions.

### Improved
1. Changed chat bubbles to rounded rectangles
2. Changed colors to fit iMessage experience more
3. Now the status and the model selection is in the toolbar at the top of the window
4. Changed server status to green circle or red triangle
5. Changed markdown to highlight code blocks for better visuals.

## Version 1.0 Initial Release
1. Chatting with local Large Language Models.
2. Ability to change model mid conversation.
3. Restart Conversation at anytime.
4. New Tabs for different conversations.
5. Ability to download models using the GUI (Check https://ollama.ai/library for list of model names to download)
6. Ability to delete models
7. Ability to duplicate models
8. Light and Dark Mode
9. Localizable interface. Currently Localized in: English and Arabic