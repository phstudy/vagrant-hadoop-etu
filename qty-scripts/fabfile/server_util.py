import re
from fabric.api import *

class hosts(object):
    def __init__(self, hosts_entries=[]):
        self.hosts_entries = hosts_entries

    def update(self, ip, name):
        result = []
        replace = False

        for line in self.hosts_entries:
            if line and line.strip().startswith("#"):
                result += [line]
                continue

            entry = re.split("[ \t]+", line.strip())
            (origin_ip, names) = entry[0], entry[1:]

            if name not in names:
                result += [line]
                continue
            else:
                replace = True
                if len(names) == 1:
                    result += ["%s\t%s" % (ip, name)]
                else:
                    for n in names:
                        if n == name:
                            result += ["%s\t%s" % (ip, n)]
                        else:
                            result += ["%s\t%s" % (origin_ip, n)]

        if not replace:
            result += ["%s\t%s" % (ip, name)]

        self.hosts_entries = [ x.strip() for x in result]
        return "\n".join(self.hosts_entries)

class hosts_allow(object):
    def __init__(self, hosts_entries=[]):
        self.hosts_entries = hosts_entries

    def drop(self, ip):
        result = []

        for line in self.hosts_entries:
            if line and not (line.strip().startswith("sshd:") and line.strip().endswith(":allow")):
                result += [line]
                continue

            if ip not in line:
                result += [line]
                continue
            else:
                data = re.split("[ \t]+", line.strip().replace('sshd:', '').replace(':allow', ''))
                data.remove(ip)
                if data:
                    result += ["sshd:%s:allow" % " ".join(data)]

        self.hosts_entries = [ x.strip() for x in result]
        return "\n".join(self.hosts_entries)

    def add(self, ip):
        self.drop(ip)
        result = []
        deny = []

        for line in self.hosts_entries:
            if line and line.strip().startswith("#"):
                result += [line]
                continue
            if line and "deny" in line and not line.strip().startswith("#"):
                deny += [line]
            else:
                result += [line]

        result += ["sshd:%s:allow" % ip]
        result = result + deny + ["\n"]

        self.hosts_entries = [ x.strip() for x in result]
        return "\n".join(self.hosts_entries)

def _empty_tmp():
    import os
    import tempfile
    tmp = tempfile.mkstemp()[1]
    os.remove(tmp)
    return tmp

def _get(remote_file):
    return get(remote_file, _empty_tmp())[0]

def get_lines(remote_file):
    with open(_get(remote_file)) as f:
        return f.readlines()

def tmp(text):
    import tempfile
    tmp = tempfile.mkstemp()[1]
    with open(tmp, "w") as f:
        f.write(text)
    return tmp

if __name__ == "__main__":
    pass
