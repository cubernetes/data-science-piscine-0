#!/bin/sh -eu

die () {
    printf '\033\133;31m%s\033\133m' "$*"
    exit 1
}
warn () {
    printf '\033\133;33m%s\033\133m\n' "$*"
}
info () {
    printf '\033\133;32m%s\033\133m\n' "$*"
}

1>/dev/null 2>&1 command -v git || die 'Install `git`'

git_top_level=$(git rev-parse --show-toplevel) || die 'Not in a git repo, make sure you'\''ve ran `git init` at the root of the repo'

cd -- "$git_top_level" || die "Failed to \`cd\` into \"$git_top_level\""

[ ! -d ./data/ ] || die 'There is a directory "data" already, run `./cleanup_data.sh` first if you want to re-setup everything'

while :; do
    printf 'URL for subject.zip or eval.zip: '
    read -r url
    case "$url" in
        http*.zip) break ;;
        *.zip) warn 'The URL must start with "http". Try again' ;;
        http*) warn 'The URL must end with ".zip". Try again' ;;
        *) warn 'The URL must start with "http" and end with ".zip". Try again' ;;
    esac
done

info "Downloading URL \"$url\" as data.zip..."
curl -o ./data.zip -sfkSL "$url" || die "Failed to download URL \"$url\""

[ ! -d ./eval/ ] || {
    warn 'There is a directory "eval" already, removing it just in case "data.zip" unpacks to it'
    rm -rf ./eval/
}

[ ! -d ./subject/ ] || {
    warn 'There is a directory "subject" already, removing it just in case "data.zip" unpacks to it'
    rm -rf ./subject/
}

info 'Unzipping "data.zip"...'
unzip ./data.zip || die 'Failed to unzip "data.zip"'

rm -rf ./data.zip

if [ -d ./eval/ ]; then
    data_dir=eval
elif [ -d ./subject/ ]; then
    data_dir=subject
else
    die '"data.zip" should unpack to either a directory called "eval" or "subject"'
fi

cd -- "$data_dir"

[ -d ./item/ ] || die 'Inside the data directory, there should be a directory called "item"'
[ -d ./customer/ ] || die 'Inside the data directory, there should be a directory called "customer"'

[ -f ./item/item.csv ] || die 'Inside the item subdirectory, there should be a file called "item.csv"'
[ -f ./customer/data_2022_oct.csv ] || die 'Inside the customer subdirectory, there should be a file called "data_2022_oct.csv"'
[ -f ./customer/data_2022_nov.csv ] || die 'Inside the customer subdirectory, there should be a file called "data_2022_nov.csv"'
[ -f ./customer/data_2022_dec.csv ] || die 'Inside the customer subdirectory, there should be a file called "data_2022_dec.csv"'
[ -f ./customer/data_2023_jan.csv ] || die 'Inside the customer subdirectory, there should be a file called "data_2023_jan.csv"'
[ -f ./customer/data_2023_feb.csv ] || warn 'Inside the customer subdirectory, there should be a file called "data_2023_feb.csv" IF you downloaded "eval.zip". Continuing anyway'

cd ..

mv -T -- "$data_dir" ./data/

info 'Done! Everything seemed to have worked'
