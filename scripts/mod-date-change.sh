#! /usr/bin/bash

for FILE in **/* ; do
    touch -d "2 Jan 2000" "$FILE"
done


# Instead of taking the current time-stamp, you can explicitly specify the time using -t and -d options.

# The format for specifying -t is [[CC]YY]MMDDhhmm[.SS]

# $ touch -t [[CC]YY]MMDDhhmm[.SS]

# The following explains the above format:

#     CC – Specifies the first two digits of the year
#     YY – Specifies the last two digits of the year. If the value of the YY is between 70 and 99, the value of the CC digits is assumed to be 19. If the value of the YY is between 00 and 37, the value of the CC digits is assumed to be 20. It is not possible to set the date beyond January 18, 2038.
#     MM – Specifies the month
#     DD – Specifies the date
#     hh – Specifies the hour
#     mm – Specifies the minute
#     SS – Specifies the seconds

# For example:

# $ touch -a -m -t 203801181205.09 tgs.txt
# Another example:

# $ touch -d "2012-10-19 12:12:12.000000000 +0530" tgs.txt
# $ touch -d "2 hours ago" filename