#Title: Getting the help information

Import "checks"

mtmodt --help >help.txt

exec <help.txt
IFS=""
Expected=$'Usage:\tmtmodt option'
CheckLine "option usage"
