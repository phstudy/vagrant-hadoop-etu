yum install -y krb5-libs krb5-server krb5-workstation

rm -rf hostnames.txt
for n in `seq -f "%02g" 1 4`
do
    echo "hadoop${n}.mycompany.com" >> hostnames.txt
done

[ -r "hostnames.txt" ] || {
    echo "File hostnames.txt doesn't exist or isn't readable"
    exit 1
}

krb_realm=EXAMPLE.COM

for name in $(cat hostnames.txt)
do
    install -o root -g root -m 0700 -d ${name}

    kadmin.local << EOF
    addprinc -randkey host/${name}@${krb_realm}
    addprinc -randkey hdfs/${name}@${krb_realm}
    addprinc -randkey mapred/${name}@${krb_realm}

    ktadd -k ${name}/hdfs.keytab -norandkey \
        hdfs/${name}@${krb_realm} \
        host/${name}@${krb_realm}

    ktadd -k ${name}/mapred.keytab -norandkey \
        mapred/${name}@${krb_realm} \
        host/${name}@${krb_realm}

EOF

done
