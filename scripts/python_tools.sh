#!/bin/bash

export PADDING="0"

py_title() {
	echo ''
	tool=$(gum style " $1" --border="none" --bold --italic --foreground="#eba0ac")
	msg=$(gum style "PYTHON TOOL SETUP:" --bold --border="none" --foreground="#74c7ec")
	gum join --align left "$msg" "$tool"
}

py_msg_ok() {
	tool=$(gum style "$1" --border="none" --bold --italic --foreground="#fab387")
	msg=$(gum style " installed successfully." --border="none" --foreground="#a6e3a")
	gum join --align left "$tool" "$msg"
}

py_msg_err() {
	tool=$(gum style "$1" --border="none" --bold --italic --foreground="#fab387")
	msg=$(gum style " failed to install." --border="none" --foreground="#f38ba8")
	gum join --align left "$tool" "$msg"
	return
}

py_msg_installed() {
	tool=$(gum style "$1" --border="none" --bold --italic --foreground="#fab387")
	msg=$(gum style " already installed." --border="none" --italic --foreground="#f9e2af")
	gum join --align left "$tool" "$msg"
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

#############################################################################################
if command_exists python; then python_c=python; else python_c=python3; fi
$python_c -m pip install --upgrade --user pip --force
$python_c -m pip install --upgrade --user pipupgrade --force

py_managers=$(gum choose --no-limit --header="Choose pip alternative(s) / Python Project Manager(s) to install:" {pipx,pipenv,pdm,poetry,rye,uv})

setup_pipx() {
	py_title pipx
	if ! command_exists pipx || [[ "$(command -v pipx)" == */pyenv-win/* && "$(uname -r)" == *icrosoft* ]]; then
		$python_c -m pip install --user pipx
		$python_c -m pipx ensurepath
		py_msg_ok pipx || py_msg_err pipx
	else
		py_msg_installed pipx
	fi
}

setup_pipenv() {
	py_title pipenv
	if ! command_exists pipenv || [[ "$(command -v pipenv)" == */pyenv-win/* && "$(uname -r)" == *icrosoft* ]]; then
		$python_c -m pip install --user pipenv
		py_msg_ok pipenv || py_msg_err pipenv
	else
		py_msg_installed pipenv
	fi
}

setup_pdm() {
	py_title pdm
	if ! command_exists pdm; then
		curl -sSL https://pdm-project.org/install-pdm.py | $python_c -
		py_msg_ok pdm || py_msg_err pdm
	else
		py_msg_installed pdm
	fi
}

setup_poetry() {
	py_title poetry
	if ! command_exists poetry; then
		curl -sSL https://install.python-poetry.org | $python_c -
		py_msg_ok poetry || py_msg_err poetry
	else
		py_msg_installed poetry
	fi
}

setup_rye() {
	py_title rye
	if ! command_exists rye; then
		curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash
		py_msg_ok rye || py_msg_err rye
	else
		py_msg_installed rye
	fi
}

setup_uv() {
	py_title uv
	if ! command_exists uv; then
		curl -LsSf https://astral.sh/uv/install.sh | sh
		py_msg_ok uv || py_msg_err uv
	else
		py_msg_installed uv
	fi
}

if [[ " ${py_managers[*]} " =~ [[:space:]]pipx[[:space:]] ]]; then setup_pipx; fi
if [[ " ${py_managers[*]} " =~ [[:space:]]pipenv[[:space:]] ]]; then setup_pipenv; fi
if [[ " ${py_managers[*]} " =~ [[:space:]]pdm[[:space:]] ]]; then setup_pdm; fi
if [[ " ${py_managers[*]} " =~ [[:space:]]poetry[[:space:]] ]]; then setup_poetry; fi
if [[ " ${py_managers[*]} " =~ [[:space:]]rye[[:space:]] ]]; then setup_rye; fi
if [[ " ${py_managers[*]} " =~ [[:space:]]uv[[:space:]] ]]; then setup_uv; fi
