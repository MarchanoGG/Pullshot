# Pullshot

Pullshot is a minimal, fault-tolerant CLI tool for Linux-based systems that automates pulling Git repositories and executing post-deploy commands defined in a JSON config.

Ideal for deployment pipelines, Raspberry Pi projects, or managing infrastructure scripts, Pullshot offers a plug-and-play experience with predictable results.

Terminal - Exmaple Deploying project            |  JSON Example Settings file
:-------------------------:|:-------------------------:
![pullshot-cli](https://github.com/user-attachments/assets/d8494f51-87a2-4082-a716-258e19b9618c) |  ![pullshot-json](https://github.com/user-attachments/assets/6636e772-d526-45df-822e-f85aecf52a62)

---

## Features

- Pull (clone or update) any Git repository via SSH or HTTPS
- Automatically execute post-install commands (e.g. `pip install`, `npm install`)
- JSON-based configuration
- Clear output and error handling
- Works entirely from the command line
- Designed for Linux environments (e.g. Ubuntu Server, Raspberry Pi)
- Portable and extensible

---

## Requirements

- `bash` (tested on Bash 5.2+)
- `git`
- `jq` (JSON CLI processor)
- SSH key configured if using private repos via `git@github.com`

Install requirements on Ubuntu/Debian:

```bash
sudo apt update
sudo apt install git jq -y
```

---

## Directory Structure

```
/opt/pullshot/
├── pullshot.sh               # Main script
├── pullshot.json             # Local config (ignored by Git)
├── pullshot.json.example     # Example config for others
├── .gitignore
└── README.md
```

You should symlink the `pullshot.sh` file to make it globally available via terminal as `pullshot`.

---

## Installation

Clone the repository (using your configured SSH key if private):

```bash
git clone git@github.com:MarchanoGG/Pullshot.git ~/Pullshot
sudo mv ~/Pullshot /opt/pullshot
```

Make the script executable:

```bash
sudo chmod +x /opt/pullshot/pullshot.sh
```

Create a global symlink:

```bash
sudo ln -s /opt/pullshot/pullshot.sh /usr/local/bin/pullshot
```

Now you can call `pullshot` from anywhere on your system.

---

## Configuration

Copy the example config and modify:

```bash
sudo cp /opt/pullshot/pullshot.json.example /opt/pullshot/pullshot.json
sudo nano /opt/pullshot/pullshot.json
```

### Example config:

```json
{
  "myProject": {
    "repo": "git@github.com:YourUsername/YourRepo.git",
    "path": "/home/youruser/projects/myProject",
    "post_install": [
      "pip3 install -r requirements.txt",
      "python3 setup.py"
    ]
  },
  "website": {
    "repo": "https://github.com/YourUser/Website.git",
    "path": "/var/www/html/mywebsite",
    "post_install": [
      "npm install",
      "npm run build"
    ]
  }
}
```

---

## Usage

```bash
pullshot <project-name>
```

For example:

```bash
pullshot myProject
```

This will:

1. Read the config from `/opt/pullshot/pullshot.json`
2. Check if the repo exists at the path
3. If yes: pull latest changes
4. If not: clone it fresh
5. Run all post-install commands sequentially
6. Show success or error messages

---

## Example Output

```
[*] Using repo: git@github.com:MarchanoGG/myProject.git
[*] Target path: /home/pi/projects/myProject
[*] Directory exists, pulling latest changes...
[*] Running post-install commands...
[CMD] pip3 install -r requirements.txt
[CMD] python3 setup.py
[✓] Done.
```
