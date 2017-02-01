#expand aliases (gap might be an alias)
GAP_BIN=/Users/goens/Development/gap/bin/gap.sh
WORKSPACE_FILE="~/.gap/emptyWorkspace"

#does the file exist already?
if [ ! -d ~/.gap/ ]; then 
    mkdir ~/.gap
fi

if [ -f $WORKSPACE_FILE ]; then
    exit 0
else
    if [ -e $WORKSPACE_FILE ]; then
        >&2 "Error. file $WORKSPACE_FILE exists but is not a regular file." 
        exit 1
    fi 
fi 

#file does not exist. create it!
$GAP_BIN -b -q  << EOI
SaveWorkspace("$WORKSPACE_FILE");
