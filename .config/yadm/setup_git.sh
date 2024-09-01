#!/bin/bash

known_hosts_file="$HOME/.ssh/known_hosts"

initialize_known_hosts() {
    echo "Creating empty file: ${known_hosts_file}"
    if [[ -f $known_hosts_file ]]; then
        echo "  Already exists"
    else
        ssh_directory=$(dirname ${known_hosts_file})
        mkdir -p ${ssh_directory}
        touch ${known_hosts_file}
        echo "  Done"
    fi
}

setup_ssh() {
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    echo "Adding ${1} hosts to: ${known_hosts_file}"
    hosts=$(cat ${known_hosts_file} | grep ${1})
    if [[ -z "${hosts}" ]]; then
        ssh-keyscan ${1} >> ${known_hosts_file}
        echo "  Done"
    else
        echo "  Already added"
    fi

    # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
    ssh_file="$HOME/.ssh/${2}"
    echo "Generating SSH key: ${ssh_file}"
    if [[ -f $ssh_file ]]; then
        echo "  Already exists"
    else
        ssh-keygen -f ${ssh_file} -t ed25519 -C "andperks6@gmail.com"
        eval "$(ssh-agent -s)"
        echo "  Done"
    fi

    # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
    echo "Command to copy to clipboard: ${1}"
    if [[ "${system_type}" == "Darwin" ]]; then
        echo "  cat ${ssh_file}.pub | pbcopy"
    elif [[ "${system_type}" == "Linux" ]]; then
        echo "  cat ${ssh_file}.pub | wl-copy"
    else
        echo "  Error: unhandled system type"
        exit 1
    fi
}

setup_git() {
    # https://formulae.brew.sh/formula/git
    # brew_install "git"

    # Setup SSH keys for each git host
    initialize_known_hosts
    setup_ssh "github.com" "id_ed25519"
    # setup_ssh "gitlab.com" "id_ed25519_lab"
    # setup_ssh "bitbucket.org" "id_ed25519_bit"
}
