DATA_URL=s3-ap-southeast-1.amazonaws.com/qrtt1.codedata

function dl {
  curl -L "http://$DATA_URL/$1" > $1
}

function adl {
  echo "axel downloading: http://$DATA_URL/$1"
  axel -n 30 "http://$DATA_URL/$1" -o $1
}

# install axel
dl axel-2.4-1.el6.rf.x86_64.rpm
sudo rpm -ivh axel-2.4-1.el6.rf.x86_64.rpm


# install jvm to /usr/java/jdk1.7.0_45
adl "jdk-7u45-linux-x64.rpm"
sudo rpm -ivh jdk-7u45-linux-x64.rpm

# downalod hadoop software
adl "etu-hadoop.tar"
tar xvf etu-hadoop.tar
