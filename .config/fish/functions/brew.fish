function brews
    set formulae "$(brew leaves | xargs brew deps --installed --for-each)"
    set casks "$(brew list --cask)"

    echo \=\=\> (set_color --bold red)Formulae
    echo (set_color normal)$formulae | sed "s/^\(.*\):\(.*\)\$/\1$(set_color blue)\2$(set_color normal)/"
    echo \n\=\=\> (set_color --bold red)Casks
    echo (set_color normal)$casks
end
