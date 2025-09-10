# MacOS Cleanup for Developers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) ![GitHub last commit](https://img.shields.io/github/last-commit/notKeion/mac-dev-cleanup) ![GitHub issues](https://img.shields.io/github/issues/notKeion/mac-dev-cleanup) ![GitHub pull requests](https://img.shields.io/github/issues-pr/notKeion/mac-dev-cleanup)

A collection of shell commands and scripts to safely free up disk space on macOS for developers.  
Targets common heavy hitters like **Docker**, **Xcode**, **VS Code**, **npm**, **Multipass**, **Flutter**, and more.

## 🚀 Features
- Prune **Docker images, volumes, and build cache**
- Clear **Xcode DerivedData, Archives, Simulator caches**
- Clean **npm / yarn / pnpm** caches and node_modules
- Reset **Flutter / Gradle / Android SDK** caches
- Purge **Multipass VMs**
- Wipe **VS Code cache & workspaceStorage**
- Remove old **Homebrew** artifacts
- General macOS cache cleanup

## 📦 Usage
**Clone the repo:**
```bash
git clone https://github.com/notKeion/mac-dev-cleanup.git
cd mac-dev-cleanup
```
**Make the script executable:**
```bash 
chmod +x cleanup.sh
```
**Run the cleanup script:**
```bash
./cleanup.sh
```
**Or run with `curl` directly:**
```bash
curl -sSL https://raw.githubusercontent.com/notKeion/mac-dev-cleanup/main/cleanup.sh | bash
```
## 🔎 Examples
**Check Docker Usage**
```bash
docker system df -v
```
**Delete old Xcode DerivedData:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
**Clear npm cache:**
```bash
npm cache clean --force
```


## ⚠️ Caution
- Review the script before running to ensure it fits your needs.
- Some commands may require elevated permissions (`sudo`).
- Always back up important data before performing cleanup operations.
- The script is designed to be safe, but unintended data loss is possible.
- Use at your own risk!

## 🤝 Contributing
Contributions are welcome! If you'd like to improve this project, please follow these steps (or just make an issue if you're unsure or lazy like me):

1. **Fork the repository**  
    Click the "Fork" button at the top-right of this page to create your own copy of the repository.

2. **Clone your fork**  
    ```bash
    git clone https://github.com/your-username/mac-dev-cleanup.git
    cd mac-dev-cleanup
    ```

3. **Create a new branch**  
    ```bash
    git checkout -b feature/your-feature-name
    ```

4. **Make your changes**  
    Add or improve functionality, fix bugs, or update documentation.

5. **Test your changes**  
    Ensure your changes work as expected and do not break existing functionality.

6. **Commit your changes**  
    ```bash
    git add .
    git commit -m "Add your descriptive commit message here"
    ```

7. **Push your changes**  
    ```bash
    git push origin feature/your-feature-name
    ```

8. **Submit a pull request**  
    Open a pull request on the original repository and provide a clear description of your changes.

### Guidelines
- Follow the existing code style and structure.
- Write clear and concise commit messages.
- Update documentation if your changes affect usage.
- Be respectful and constructive in discussions.

Thank you for contributing! 🎉
