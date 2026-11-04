# Preserve all text around each PEM record, including a missing final newline.
BEGIN {
    RS = "-----BEGIN (TRUSTED )?CERTIFICATE-----"
    count = 0
}

NR == 1 {
    printf "%s", $0 > (directory "/prefix")
    close(directory "/prefix")
    header = RT
    next
}

{
    if (!match($0, /-----END (TRUSTED )?CERTIFICATE-----/)) {
        print "Unterminated PEM certificate" > "/dev/stderr"
        failed = 1
        exit 1
    }
    terminator = substr($0, RSTART, RLENGTH)
    expected = header
    sub("BEGIN", "END", expected)
    if (terminator != expected) {
        print "Mismatched PEM certificate markers" > "/dev/stderr"
        failed = 1
        exit 1
    }
    count++
    name = sprintf("%s/%06d", directory, count)
    printf "%s%s", header, substr($0, 1, RSTART + RLENGTH - 1) > (name ".pem")
    close(name ".pem")
    printf "%s", substr($0, RSTART + RLENGTH) > (name ".tail")
    close(name ".tail")
    header = RT
}

END {
    if (failed) exit 1
    if (header != "") {
        print "Unterminated PEM certificate" > "/dev/stderr"
        exit 1
    }
    print count > (directory "/count")
}
