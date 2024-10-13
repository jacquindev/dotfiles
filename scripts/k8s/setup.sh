#!/bin/sh

set -e

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

for file in "$DOTFILES/scripts/k8s/tools/"*.sh; do \. "$file"; done

setup_color

case "$1" in
'docker')
    case "$2" in
    '--install' | '-i')
        install_docker
        ;;
    '--purge' | '-p' | 'rm')
        purge_docker
        ;;
    '--enable')
        docker_enable
        ;;
    '--status')
        docker_status
        ;;
    '--cri' | '-c')
        install_dockerd
        ;;
    '--enable-cri')
        dockerd_enable
        ;;
    '--status-cri')
        dockerd_status
        ;;
    '--help' | '-h')
        docker_help
        ;;
    esac
    ;;
'helm')
    case "$2" in
    '--install' | '-i')
        install_helm
        ;;
    '--plugin' | '-p')
        install_helm_plugins
        ;;
    '--helmfile' | '-f')
        install_helmfile
        ;;
    '--helmsman' | '-m')
        install_helmsman
        ;;
    '--help' | '-h')
        helm_help
        ;;
    esac
    ;;
'kube')
    case "$2" in
    '--install' | '-i')
        install_kubectl
        ;;
    '--agg' | '--aggregator')
        install_kube_aggregator
        ;;
    '--api' | 'apiserver')
        install_kube_apiserver
        ;;
    '--control' | '--controller')
        install_kube_controller
        ;;
    '--convert' | '-c')
        install_kubectl_convert
        ;;
    '--kubectx' | '-x')
        install_kubectx
        ;;
    '--krew' | '-w')
        install_krew
        ;;
    '--log' | '--logrunner')
        install_kube_logrunner
        ;;
    '--proxy')
        install_kube_proxy
        ;;
    '--schedule' | 'scheduler' | '--sch')
        install_kube_scheduler
        ;;
    '--help' | '-h')
        kube_help
        ;;
    esac
    ;;
'minikube')
    case "$2" in
    '--install' | 'i')
        install_minikube
        ;;
    '--start' | '-s')
        start_minikube
        ;;
    '--purge' | 'rm' | '-p')
        purge_minikube
        ;;
    '--addons' | '-a')
        mini_addons
        ;;
    '--status' | 'st')
        mini_status
        ;;
    '--help' | '-h')
        mini_help
        ;;
    esac
    ;;
'help' | 'h' | '*')
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Available Commands: "
    echo " $(tput bold)$(tput setaf 208)docker:"
    echo "      $(tput setaf 4)docker --install$(tput sgr0)     install Docker Engine"
    echo "      $(tput setaf 4)docker --enable-cri$(tput sgr0)  enable Docker service"
    echo "      $(tput setaf 4)docker --status-cri$(tput sgr0)  show Docker status"
    echo "      $(tput setaf 4)docker --purge$(tput sgr0)       uninstall Docker Engine and its packages"
    echo "      $(tput setaf 4)docker --cri$(tput sgr0)         install cri-dockerd"
    echo "      $(tput setaf 4)docker --enable-cri$(tput sgr0)  enable cri-dockerd.service"
    echo "      $(tput setaf 4)docker --status-cri$(tput sgr0)  show cri-dockerd status"
    echo "      $(tput setaf 4)docker --help$(tput sgr0)        show help of docker options"
    echo
    echo " $(tput bold)$(tput setaf 208)helm:"
    echo "      $(tput setaf 4)helm --install$(tput sgr0)      install Helm"
    echo "      $(tput setaf 4)helm --plugin$(tput sgr0)       install Helm plugins"
    echo "      $(tput setaf 4)helm --helmfile$(tput sgr0)     install Helmfile command"
    echo "      $(tput setaf 4)helm --helmsman$(tput sgr0)     install Helmsman command"
    echo "      $(tput setaf 4)helm --help$(tput sgr0)         show help of helm options"
    echo
    echo " $(tput bold)$(tput setaf 208)kube:"
    echo "      $(tput setaf 4)kube --install$(tput sgr0)      install Kubectl"
    echo "      $(tput setaf 4)kube --api$(tput sgr0)          install Kube-Apiserver plugin"
    echo "      $(tput setaf 4)kube --agg$(tput sgr0)          install Kube-Aggregator plugin"
    echo "      $(tput setaf 4)kube --control$(tput sgr0)      install Kube-Controller-Manager plugin"
    echo "      $(tput setaf 4)kube --convert$(tput sgr0)      install Kubectl-Convert plugin"
    echo "      $(tput setaf 4)kube --kubectx$(tput sgr0)      install Kubectx and Kubens"
    echo "      $(tput setaf 4)kube --krew$(tput sgr0)         install Krew (Kubectl Plugin Manager)"
    echo "      $(tput setaf 4)kube --log$(tput sgr0)          install Kube-Log-Runner plugin"
    echo "      $(tput setaf 4)kube --proxy$(tput sgr0)        install Kube-Proxy plugin"
    echo "      $(tput setaf 4)kube --schedule$(tput sgr0)     install Kube-Scheduler plugin"
    echo "      $(tput setaf 4)kube --help$(tput sgr0)         show help of kube options"
    echo
    echo " $(tput bold)$(tput setaf 208)minikube:"
    echo "      $(tput setaf 4)minikube --install$(tput sgr0)  install Minikube"
    echo "      $(tput setaf 4)minikube --start$(tput sgr0)    start Minikube and add basic addons"
    echo "      $(tput setaf 4)minikube --purge$(tput sgr0)    remove Minikube and uninstall Minikube"
    echo "      $(tput setaf 4)minikube --addons$(tput sgr0)   show enabled Minikube addons"
    echo "      $(tput setaf 4)minikube --status$(tput sgr0)   show current Minikube status"
    echo "      $(tput setaf 4)minikube --help$(tput sgr0)     show help of minikube options"
    echo
    ;;
esac
