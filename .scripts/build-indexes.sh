
#!/usr/bin/env bash
set -eu # exit on error, error on undefined variable usage

# Inspired by https://www.askapache.com/s/u.askapache.com/2013/04/gnu-mirror-index-creator.txt

ROOT="${1:-$(pwd)}" # use argument 1, default to current directory if not set

echo "Starting from '${ROOT}'"

mapfile -t DIRS < <(find $ROOT -not -path '*/[@.]*' -type d)

echo "Directories: ${#DIRS[@]}"

F=index.html
P="/alpine-apks"

for D in "${DIRS[@]}"; do
    SUBDIR="${D/$ROOT/$P}"
    echo "Indexing '${SUBDIR}'"
    cd $D || exit 2;
    touch $F && test -w $F || exit 2;
    (
        echo -e "<html>\n  <head>\n    <title>Index of ${SUBDIR}</title>\n  </head>\n  <body>\n    <h1>Index of ${SUBDIR}</h1>\n    <pre>"
        if [ $SUBDIR != $P ]; then
            echo -e "  <a href="../">../</a>"
        fi
        (
            # change IFS locally within subshell so the for loop saves line correctly to L var
            IFS=$'\n';

            # pretty sweet, will mimick the normal apache output
            for L in $(find -L . -mount -depth -maxdepth 1 -type f ! -name 'index.html' -printf "  <a href=\"%f\">%-44f@_@%Td-%Tb-%TY %Tk:%TM  @%f@\n"|sort|sed 's,\([\ ]\+\)@_@,</a>\1,g');
            do
                # file
                F=$(sed -e 's,^.*@\([^@]\+\)@.*$,\1,g'<<<"$L");

                # file with file size
                F=$(du -bh $F | cut -f1);

                # output with correct format
                sed -e 's,\ @.*$, '"$F"',g'<<<"$L";
            done;
        )
        # now output a list of all directories in this dir (maxdepth 1) other than '.' outputting in a sorted manner exactly like apache
        find -L . -mount -depth -maxdepth 1 -type d ! -name '.*' -printf "  <a href=\"%f\">%-43f@_@%Td-%Tb-%TY %Tk:%TM  -\n"|sort -d|sed 's,\([\ ]\+\)@_@,/</a>\1,g'

        echo -e "    </pre>\n  </body>\n</html"
    ) > $F;
done