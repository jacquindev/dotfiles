#!/bin/bash
cdnvm() {
    _bash_print() {
        local IFS=$' \t\n'
        printf '%s\n' "$*"
    }

    _nvm_find_up() {
        local path=$PWD
        while [[ $path && ! -e $path/$1 ]]; do
            path=${path%/*}
        done
        _bash_print "$path"
    }

    command cd "$@" || return "$?"
    local nvmrc_path=$(_nvm_find_up .nvmrc)

    # If there are no .nvmrc file, use the default nvm version
    if [[ $nvm_path != *[^[:space:]]* ]]; then

        local default_version
        default_version=$(nvm version default)

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default
        fi

    elif [[ -s "$nvm_path/.nvmrc" && -r "$nvm_path/.nvmrc" ]]; then
        local nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)
        local locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions.  If there are
        # multiple matching versions, take the latest one.  Remove the `->` and
        # `*` characters and spaces.  `locally_resolved_nvm_version` will be
        # `N/A` if no local versions are found.
        locally_resolved_nvm_version=$(nvm ls --no-colors $(<"./.nvmrc") | sed -n '${s/->//g;s/[*[:space:]]//g;p;}')

        # If it is not already installed, install it
        if [[ $locally_resolved_nvm_version == N/A ]]; then
            nvm install "$nvm_version"
        elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
            nvm use "$nvm_version"
        fi
    fi
}

if [[ "$NVM_NO_LOAD" != true ]]; then
    if [[ "$NVM_NO_USE" == true ]]; then
        alias cd='cdnvm'
        cdnvm "$PWD" || exit
    fi
fi

true
