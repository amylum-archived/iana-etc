#!/usr/bin/gawk -f
BEGIN {
    print "# Full data: /usr/share/iana-etc/protocol-numbers.iana\n"
    FS="[<>]"
}

{
    if (/<record/) { v=n=0 }
    if (/<value/) v=$3
    if (/<name/ && !($3~/ /)) n=$3
    if (/<\/record/ && (v || n=="HOPOPT") && n) printf "%-12s %3i %s\n", tolower(n),v,n
}
