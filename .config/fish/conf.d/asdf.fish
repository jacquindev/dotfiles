if type -q asdf
	# ASDF configuration code
	if test -z $ASDF_DATA_DIR
		set _asdf_shims $HOME/.asdf/shims
	else
		set _asdf_shims $ASDF_DATA_DIR/shims
	end

	# Do not use fish_add_path (added in Fish 3.2) because it
	# potentially changes the order of items in PATH
	if not contains $_asdf_shims $PATH
		set -gx --prepend PATH $_asdf_shims
	end
	set --erase _asdf_shims

	set -gx ASDF_DATA_DIR $HOME/.asdf

	# Custom files location
	set asdf_config_dir $HOME/.config/asdf

	set -gx ASDF_CONFIG_FILE $asdf_config_dir/asdfrc
	set -gx ASDF_GOLANG_DEFAULT_PACKAGES_FILE $asdf_config_dir/go-packages
	set -gx ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY latest_available
	set -gx ASDF_NPM_DEFAULT_PACKAGES_FILE $asdf_config_dir/npm-packages

	# asdf-java
	if test -e $ASDF_DATA_DIR/plugins/java/set-java-home.fish
		. $ASDF_DATA_DIR/plugins/java/set-java-home.fish
	end

	# asdf-golang
	if test -e $ASDF_DATA_DIR/plugins/golang/set-env.fish
		. $ASDF_DATA_DIR/plugins/golang/set-env.fish
	end

	set --erase asdf_config_dir
end
