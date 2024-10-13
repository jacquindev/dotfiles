# Install Docker on Linux (Ubuntu) Machine

## Usage

- `cd` into this folder and then `chmod 755 setup.sh` 

    ```sh
    # Show all available help:
    ./setup.sh help
    ```

## Example

    ```sh
    # To install Docker Engine:
    ./setup.sh docker --install

    # To install cri-dockerd
    ./setup.sh docker --cri

    # To install minikube
    ./setup.sh minikube --install

    # To uninstall minikube
    ./setup.sh minikube --purge

    # To install krew (kubectl plugin manager)
    ./setup.sh kube --krew
    ```