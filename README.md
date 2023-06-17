# Kubuntu Post-Install

My personal post-install script for [Kubuntu](https://kubuntu.org/) or Ubuntu-based distros using KDE user-interface (e.g [KDE neon](https://neon.kde.org/)).


## Running

```
sudo su
wget -O - https://raw.githubusercontent.com/allanpereira/kubuntu-post-install/main/post-install.sh | bash

```


## Content

### Development Stacks
- [NodeJS (18.16.0)](https://nodejs.org/) - An open-source, cross-platform JavaScript runtime environment.
- [Elixir (1.8.x)](https://elixir-lang.org/) - Dynamic, functional language for building scalable and maintainable applications.
- [Java (17)](https://www.java.com/) - Programming language and computing platform.
- [PHP (8.2.x)](https://www.php.net/) - A popular general-purpose scripting language that is especially suited to web development.

### Development Tools
- [Git](https://git-scm.com/) - Free and open source distributed version control system.
- [VSCode](https://code.visualstudio.com/) - A code editor redefined and optimized for building and debugging modern web and cloud applications.
- [WebStorm](https://www.jetbrains.com/webstorm/) - An integrated development environment for JavaScript and related technologies.
- [Vim](https://www.vim.org/) - Highly configurable text editor built to make creating and changing any kind of text very efficient.
- [Filezilla](https://filezilla-project.org/) - Open source FTP client.
- [Guake](http://guake-project.org/) - A top-down terminal for Gnome, and is highly inspirated by the famous terminal used in Quake.
- [Zsh](https://ohmyz.sh/) - An open source and community-driven framework for managing your Zsh configuration.
- [Google Cloud CLI](https://cloud.google.com/sdk/gcloud) - Set of tools to create and manage Google Cloud resources.

### CLI Tools
- [jq](https://github.com/jqlang/jq/) - Command-line JSON processor
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k/) - Theme for Zsh which emphasizes speed, flexibility and out-of-the-box experience.

### Drivers
- [DisplayLink USB TO DVI Driver](https://www.synaptics.com/products/displaylink-graphics/) - The driver of DisplayLink USB to DVI connector.

### Web
- [Brave Browser](https://brave.com/) - A privacy-first and free web browser.

### Media
- [Spotify](https://www.spotify.com/) - A digital music service that gives you access to millions of songs.

### Communication
- [Discord](https://discord.com/) - The easiest way to talk over voice, video, and text. Talk, chat, hang out, and stay close with your friends and communities.

### Fonts
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro) - Monospaced font family for user interface and coding environments.
- [Inconsolata](https://github.com/googlefonts/Inconsolata) - Monospace font, designed for printed code listings and the like.
- [Roboto](https://github.com/googlefonts/roboto) - Google’s signature family of fonts, the default font on Android and Chrome OS, and the recommended font for Material Design.


## Post-install actions
- Set the Global Theme (Global Theme > "Breeze")
- Set the Plasma Style (Plasma Style > "Breeze Dark")
- Set the Color Scheme (Colors > "Breeze Classic")
- Set the Cursor Theme (Cursors > Breeze Light - 48)
- Set the Icon Theme (Icons > Papirus-Light)
- Set the icon of Application Launcher (it was downloaded to `~/Pictures`)
- Replace "Peek at Desktop" widget by "Minimize All Windows"
- Configure System Tray entries (System Tray Settings > Entries)
- Configure Clock (Digital Clock Settings > Appearance)
  - Date Format: ISO Date
- Add widgets
  - Color Picker
  - Weather Report
- Set git user config:
```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
- Disable unused WebStorm plugins to improve performance (File > Settings... > Plugins > Installed)
- Install WebStorm plugins (File > Settings... > Plugins > Marketplace)
  - .env files support
  - .ignore
  - Bash Support
  - CSV Editor
  - Docker
  - GitToolBox
  - GraphQL
  - Kubernetes
  - Markdown
  - Material Theme UI
  - Node.js
  - OpenAPI Specifications
  - String Manipulation