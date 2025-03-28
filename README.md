<h3>
<div align="center">
<img src="./assets/banner.png" alt="banner" width="640" height="160">

<br>

🌿 A WSL / Linux Virtual Machine Dotfiles Repo 🌿

</div>
</h3>

<hr>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/dotfiles?style=for-the-badge&logo=github&logoColor=eba0ac&label=Last%20Commit&labelColor=302D41&color=eba0ac"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/"><img src="https://img.shields.io/github/repo-size/jacquindev/dotfiles?style=for-the-badge&logo=hyprland&logoColor=f9e2af&label=Size&labelColor=302D41&color=f9e2af" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/dotfiles?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/dotfiles/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/dotfiles?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
</p>
</div>

> [!NOTE]
> Windows 11 Dotfiles Repository is maintained here ⇒ **[windots](https://github.com/jacquindev/windots.git)**

## 🌼 Preview

![btop](./assets/btop.png)

![nvim](./assets/nvim.png)

![yazi](./assets/yazi.png)

## 🔧 Setup

This repository is meant to use with my **[ansible automated repo](https://github.com/jacquindev/automated-wsl2-setup)**

### Option 1: (Recommended) With Ansible

Rather than cloned this repository, please check out my [automated-wsl2-setup](https://github.com/jacquindev/automated-wsl2-setup) repository for instructions.

### Option 2: Without Ansible

- Clone this repo locally:

  ```bash
  git clone https://github.com/jacquindev/dotfiles.git ~/.dotfiles
  ```

- Ensure `stow` is installed and run:

  ```bash
  cd ~/.dotfiles && stow .
  ```

- To install all [Homebrew](https://brew.sh/)'s packages listed in [`Brewfile`](./Brewfile), in your terminal run the following command:

  ```bash
  # Install Homebrew if you do not install it yet:
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install all Homebrew packages listed in Brewfile:
  brew bundle
  ```

## Development Tools (optional)

### Step 1: Install [`mise`](https://mise.jdx.dev/)

`mise` can be installed via [Homebrew](https://brew.sh/) (`brew install mise`) or by enter the command `curl https://mise.run | sh` in your terminal. By default, if you `bundle` this repository `Brewfile`, then you are already packed with `mise`.

If that not your case, please visit [Installing Mise](https://mise.jdx.dev/installing-mise.html) for more ways to install `mise` on your system.

### Step 2: Install global tools using `mise install` command

To install all global tools listed in [`config.toml`](./.config/mise/config.toml) file, simply run:

```bash
mise install
```

## License

Licensed under the [MIT License](./LICENSE).

## Author

This project was written by [Jacquin Moon](https://github.com/jacquindev/).
