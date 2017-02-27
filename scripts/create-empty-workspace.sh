#expand aliases (gap might be called via an alias)
GAP_BIN=gap
WORKSPACE_FILE=${HOME}"/.gap/emptyWorkspace"

#does the file exist already?
mkdir -p ${HOME}/.gap

if [ -e $WORKSPACE_FILE ]; then
    >&2 echo "Error. File $WORKSPACE_FILE exists!"
    exit 0
fi

#file does not exist. create it!
$GAP_BIN -b -q  << EOI
SaveWorkspace("$WORKSPACE_FILE");
EOI

