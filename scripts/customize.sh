CONFIG_FILE=$1
scripts/config --file $CONFIG_FILE --enable CONFIG_BINFMT_MISC
scripts/config --file $CONFIG_FILE --set-str CONFIG_LOCALVERSION "-Marisa"

for script in $(dirname "$(realpath "$0")")/customize/*.sh; do
    . "$script"
done
