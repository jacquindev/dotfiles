<h3>
<div align="center">
<img src="./assets/banner.png" alt="banner" width="640" height="160">

<br/>

🌿 A WSL (Ubuntu/Debian) Dotfiles 🌿

</div>
</h3>

<hr/>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/dotfiles?style=for-the-badge&logo=github&logoColor=eba0ac&label=Last%20Commit&labelColor=302D41&color=eba0ac"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/"><img src="https://img.shields.io/github/repo-size/jacquindev/dotfiles?style=for-the-badge&logo=hyprland&logoColor=f9e2af&label=Size&labelColor=302D41&color=f9e2af" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/dotfiles?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/dotfiles?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
</p>  
</div>

> [!NOTE]
> Windows 11 Dotfiles Repository is maintained here ⇒ [windots](https://github.com/jacquindev/windots.git)

<br/>

## 🔧 Setup

> [!WARNING]<br>
> For **BEST** result, please run: `sudo visudo` <br>
> Then add the following line at the **end** of the file: <br>
> *(This will disable password prompt of `sudo` command)*
> ```bash
> your_username ALL=(ALL) NOPASSWD:ALL
> ```

<hr>

1. **Install the Prerequisites**

   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Prerequisites packages
   sudo apt install -y curl file git lsb-release
   ```
   
2. **Clone this repository**

   ```bash
   git clone https://github.com/jacquindev/dotfiles.git
   cd dotfiles

   # Updating the submodule repo
   git submodule update --init --recursive
   ```

3. **Run setup script**

   ```bash
   . ./bootstrap.sh
   ```
