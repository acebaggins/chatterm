# Chatterm

Chat with your console! Because why not?

## Features

1. Chat messages are not sent to history
1. Chat session is tracked during the life of the `tty`
1. Ask your terminal to explain things! 
    * `"tell me about this direction $(ls -la)"`
    * `"explan this nonsense! $(cat nonsense.file)"`

## Installation

1. Download ollama
2. Set a model env `CHATTERM_MODEL=llama3.3`

### oh-my-zsh

1. `git clone https://github.com/acebaggins/chatterm.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/chatterm`
1. Add plugin to .zshrc (`plugins=(... chatterm)`)

## Chat!

Type `"`, then write your message. Add end quotes if you are feeling fancy. Hit enter, bam! Response.

### Functions

1. `show_chaterm_chat` - Show the chat history for this session.
1. `clear_chatterm_chat` - Clear the chat history for this session.