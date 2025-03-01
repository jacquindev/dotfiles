# golang
if [ -f "$ASDF_DATA_DIR/plugins/golang/set-env.zsh" ]; then
	source "$ASDF_DATA_DIR/plugins/golang/set-env.zsh"
fi

# java
if [ -f "$ASDF_DATA_DIR/plugins/java/set-java-home.zsh" ]; then
	source "$ASDF_DATA_DIR/plugins/java/set-java-home.zsh"
fi

# tomcat
if [ -f "$ASDF_DATA_DIR/plugins/tomcat/set-catalina-home.sh" ]; then
	source "$ASDF_DATA_DIR/plugins/tomcat/set-catalina-home.sh"
fi
