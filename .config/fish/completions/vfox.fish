# Return immediately if `vfox` not exists
if not type -q vfox
  exit 0
end

# vfox fish completions
complete -c vfox -x -l debug -d "Show debug information"
complete -c vfox -x -l generate-bash-completion -d "Generate subcommands"
complete -c vfox -x -l help -s h -d "Show help"
complete -c vfox -x -l version -s V -s v -d "Print version"

complete -c vfox -x -n __fish_use_subcommand -a add -d "Add a plugin or plugins"
complete -c vfox -x -n __fish_use_subcommand -a available -d "Show all available plugins"
complete -c vfox -x -n __fish_use_subcommand -a cd -d "Launch a shell in the VFOX_HOME or SDK directory"
complete -c vfox -x -n __fish_use_subcommand -a config -d "Setup, view config"
complete -c vfox -x -n __fish_use_subcommand -a current -a c -d "Show current version of the target SDK"
complete -c vfox -x -n __fish_use_subcommand -a help -a h -d "Shows a list of commands or help for one command"
complete -c vfox -x -n __fish_use_subcommand -a info -d "Show plugin info"
complete -c vfox -x -n __fish_use_subcommand -a env
complete -c vfox -x -n __fish_use_subcommand -a install -a i -d "Install a version of the target SDK"
complete -c vfox -x -n __fish_use_subcommand -a list -a ls -d "List all versions of the target SDK"
complete -c vfox -x -n __fish_use_subcommand -a remove -d "Remove a plugin"
complete -c vfox -x -n __fish_use_subcommand -a search -d "Search a version of the target SDK"
complete -c vfox -x -n __fish_use_subcommand -a uninstall -a un -d "Uninstall a version of the target SDK"
complete -c vfox -x -n __fish_use_subcommand -a update -d "Show all available plugins"
complete -c vfox -x -n __fish_use_subcommand -a upgrade -d "Upgrade vfox to the latest version"
complete -c vfox -x -n __fish_use_subcommand -a use -a u -d "Use a version of the target SDK"

complete -c vfox -x -n "__fish_seen_subcommand_from config" -l list -s l -d "List all config"
complete -c vfox -x -n "__fish_seen_subcommand_from config" -l unset -s un -d "Remove a config"

complete -c vfox -x -n "__fish_seen_subcommand_from cd" -l plugin -s p -d "Launch a shell in the plugin directory"

complete -c vfox -x -n "__fish_seen_subcommand_from update" -l all -s a -d "Update all plugins"

complete -c vfox -x -n "__fish_seen_subcommand_from add" -l source -s s -d "Add plugin from source"
complete -c vfox -x -n "__fish_seen_subcommand_from add" -l alias -d "Add plugin alias"

complete -c vfox -x -n "__fish_seen_subcommand_from install i" -l all -s a -d "Install all SDK versions recorded in .tool-versions"

complete -c vfox -x -n "__fish_seen_subcommand_from use u" -l global -s g -d "Used with the global environment"
complete -c vfox -x -n "__fish_seen_subcommand_from use u" -l project -s p -d "Used with the current directory"
complete -c vfox -x -n "__fish_seen_subcommand_from use u" -l session -s s -d "Used with the current shell session"

complete -c vfox -x -n "__fish_seen_subcommand_from env" -l shell -s s -d "Shell name"
complete -c vfox -x -n "__fish_seen_subcommand_from env" -l cleanup -s c -d "Cleanup old temp files"
complete -c vfox -x -n "__fish_seen_subcommand_from env" -l json -s j -d "Output json format"
complete -c vfox -x -n "__fish_seen_subcommand_from env" -l full -d "Output full env"
