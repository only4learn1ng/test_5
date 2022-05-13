echo "Deployment Started"


sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p
echo "BBR Enabled"
check_bbr=`sudo lsmod | grep bbr`
echo $check_bbr


arch=$(uname -m)
if [[ $arch == "x86_64" ]]; then
	nknsoftwareURL="https://software.hidandelion.com/nkn/modified/nknd-amd64"
	filename="nknd-amd64"
elif [[ $arch == "armv7l" ]] || [[ $arch == "aarch64" ]] || [[ $arch == "armv8b" ]] || [[ $arch == "armv8l" ]] || [[ $arch == "aarch64_be" ]]; then
	nknsoftwareURL="https://software.hidandelion.com/nkn/modified/nknd-armv7"
	filename="nknd-armv7"
fi

if [[ ! -d "/home/admin" ]]; then
	mkdir /home/admin
fi

mkdir /home/admin/nkn
cd /home/admin/nkn
echo "Downloading NKN Software..."
wget $nknsoftwareURL > /dev/null 2>&1
mv /home/admin/nkn/$filename /home/admin/nkn/nknd
sudo echo -e $1 >> ./wallet.json
sudo echo -e $2 >> ./wallet.pswd
wget "https://software.hidandelion.com/nkn/modified/config.json" > /dev/null 2>&1
echo "Downloading Chain Database..."
wget -O - $4 -q --no-check-certificate | sudo tar -xzf - || { echo -e "\e[31mCannot Get Chain Database\e[0m"; }
sudo echo -e "[Unit]\nDescription=nknd\n\n[Service]\nUser=root\nWorkingDirectory=/home/admin/nkn\nExecStart=/home/admin/nkn/nknd --beneficiaryaddr $3 --config config.json --password-file wallet.pswd --no-nat\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" >> ./nkn.service
sudo chmod -R 777 /home/admin/nkn
sudo cp ./nkn.service /etc/systemd/system/
sudo systemctl start nkn
echo "NKN Software Started"





sudo echo > /var/log/wtmp
sudo echo > /var/log/btmp
history -c


echo "Completed"


