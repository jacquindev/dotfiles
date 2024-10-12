#!/bin/zsh

if [[ "$NVM_AUTO_USE" == true ]]; then
    autoload -U add-zsh-hook
    _nvm_auto_use() {
        type "nvm_find_nvmrc" > /dev/null 2>&1 || return
        local node_version="$(nvm version)"
        local nvmrc_path="$(nvm_find_nvmrc)"

        if [[ -n "$nvmrc_path" ]]; then
            local nvmrc_node_version="$(nvm version $(cat "${nvmrc_path}"))"

            if [[ "$nvmrc_node_version" = "N/A" ]]; then
                nvm install && export NVM_AUTO_USE_ACTIVE=true
            elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
                nvm use && export NVM_AUTO_USE_ACTIVE=true
            fi
        elif [[ "$node_version" != "$(nvm version default)" ]] && [[ "$NVM_AUTO_USE_ACTIVE" = true ]]; then
            echo "${FMT_PINK}Reverting to nvm default version${FMT_RESET}"
            nvm use default
        fi
    }

    add-zsh-hook chpwd _nvm_auto_use
    _nvm_auto_use
fi

true