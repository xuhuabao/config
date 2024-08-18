#!/bin/bash

apt-get update
apt-get install jq

# ssh端口
# sed -i '/^Port/c\Port 188' /etc/ssh/sshd_config
# systemctl restart sshd
# ss -tuln

# 终端提示符颜色
#cat << EOF > /root/.bashrc
#PS1='[\[\e[31m\]\u@\h\[\e[0m\]|\[\e[34m\]\w \[\e[0m\]]#: '
#EOF
#source /root/.bashrc

# 安装
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 卸载
# bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove

xray uuid > myuuid
xray x25519 > mykey
echo -e "uuid: \n" && cat myuuid
echo -e "key: \n" && cat mykey

echo "修改配置文件"
echo "/usr/local/etc/xray/config.json"
jq -C '.inbounds[0]' /usr/local/etc/xray/config.json

UUID=$(cat myuuid)
Private_Key=$(grep "Private key:" mykey | awk -F"Private key: " '{print $2}')
json_origin="./xray_server_config.json"

jq --arg id "$UUID" --arg key "$Private_Key" \
   '.inbounds[0].settings.clients[0].id = $id |
    .inbounds[0].streamSettings.realitySettings.privateKey = $key' \
   "$json_origin" > /usr/local/etc/xray/config.json

jq -C '.inbounds[0]' /usr/local/etc/xray/config.json

systemctl enable xray
systemctl status xray
# cp ./vpn/xray_server_config.json /usr/local/etc/xray/config.json
 systemctl restart xray