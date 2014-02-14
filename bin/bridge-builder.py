#!usr/bin/env python

import csv
import os
import sys
import getopt
import re

user = os.getlogin()


def main(argv):
    if not argv:
        print_usage()
        sys.exit(2)
    else:
        mapfile = argv[0]

        print "# map file: " + mapfile
        generate_bridges(mapfile)


def print_usage():
    print """

    bridge-builder.py <path to mapfile>

    where the mapfile is a comma delimited list of tap/bridge/vlan
    mappings. in the following order:

    bridge id, tap intf, tap intf

    """

def generate_bridges(mapfile):
    # TODO make this more generic to support multiple taps as opposed to my
    # simple 2 tap application
    with open(mapfile, 'rb') as csvfile:
        intflist = csv.reader(csvfile, delimiter=',', quotechar='"')
        for row in intflist:
            c = re.compile('^\#')
            res = c.match(row[0])  # make sure this isn't a comment line
            if res:
                pass
            else:
                print "/usr/bin/sudo tunctl -u %s -t tap%s" % (user, row[1])
                print "/usr/bin/sudo ifconfig tap%s up" % (row[1])
                print "/usr/bin/sudo tunctl -u %s -t tap%s" % (user, row[2])
                print "/usr/bin/sudo ifconfig tap%s up" % (row[2])
                print "/usr/bin/sudo ovs-vsctl add-br %s" % (row[0])
                print "/usr/bin/sudo ovs-vsctl add-port %s tap%s" % (row[0], row[1])
                print "/usr/bin/sudo ovs-vsctl add-port %s tap%s" % (row[0], row[2])
                print ""

if __name__ == "__main__":
    main(sys.argv[1:])
