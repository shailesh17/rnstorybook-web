#!/usr/bin/env bash
MY_DIR=$(pwd)
export GEM_HOME="${MY_DIR}/.bundle/gems"
export PATH="${GEM_HOME}/bin:${PATH}"

function usage {
    cat <<- EOF
Usage:
    ${0} <clean|setup|updatedeps>"
where:
    clean:       removes all build & dependency artifacts"
    setup:       installs all dependencies using exact versions defined in project
                 lock files (Gemfile.lock, Podfile.lock, package-lock.json)
    updatedeps:  cleans, installs & updates all dependencies to latest versions 
                 does not use existing lock files.
EOF
}

function log() {
    local msg="$*"
    echo "##  ${msg}"
    echo "############################################"
}

function clean() {
    log "clean"
    rm -rf ./android/build ./android/app/build ./android/.gradle
    rm -rf "~/Library/Developer/Xcode/DerivedData"
    rm -rf ./ios/Pods
    rm -rf ./node_modules
    rm -rf ./.bundle
}

function setup() {
    log "setup: using GEM_HOME = ${GEM_HOME}"
    mkdir -p "${GEM_HOME}"

    gem uninstall --all --ignore-dependencies --executables --install-dir ${GEM_HOME}
    gem install --install-dir ${GEM_HOME} bundler
    bundle config set --local path ${GEM_HOME}
    bundle config set --local deployment 'false'
    bundle install

    npm cache clean --force
    npm ci

    cd ./ios
    bundle exec pod cache clean --all
    bundle exec pod install --clean-install --repo-update 
    cd ..
}

function updatedeps() {
    log "updatedeps"
    clean
    rm -f ./ios/Podfile.lock ./Gemfile.lock ./package-lock.json ./ios/Podfile.lock
    log "setup: using GEM_HOME = ${GEM_HOME}"
    mkdir -p "${GEM_HOME}"

    gem uninstall --all --ignore-dependencies --executables
    gem install --install-dir ${GEM_HOME} bundler
    bundle config set --local path ${GEM_HOME}
    bundle config set --local deployment 'false'
    bundle install --path ${GEM_HOME}
    npm cache clean --force
    npm install

    cd ./ios
    bundle exec pod cache clean --all
    bundle exec pod install --clean-install --repo-update
    cd ..
}


if [[ $# -ne 1 ]]; then
    usage
    exit 0
fi

ACTION="${1}"
case "${ACTION}" in
    "clean")
        clean
    ;;
    "setup")
        setup
    ;;
    "updatedeps")
        updatedeps
    ;;
    *)
        log "unknown option: ${ACTION}"
        usage
        exit 1
    ;;
esac
log "$0 ${ACTION}: completed"
exit 0
