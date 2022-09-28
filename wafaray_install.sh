#!/bin/bash
#------------------------------------------
# AUTHOR:
# - Alejandro Hernandez Flores aka alt3kx
# - Jesus Huerta Martinez aka mindhack03d
# - Israel Zeron Medina aka spk08
#------------------------------------------

# Banner
wafaray_banner="
 cat  /et  c/h  osts..  wget.htt  p://ma  lware/s   cript.  sh. ...
 web  she  ll. tro  jan ran      son  war e..  vir us.  mal war e..
 @!!  !!@  @!@ @!@!@!@! @!!!:!   @!@!@!@! @!@!!@!  @!@!@!@!  !@!@!
  !:  !!:  !!  !!:  !!! !!:      !!:  !!! !!: :!!  !!:  !!!   !!:
   ::.:  :::    :   : :  :        :   : :  :   : :  :   : :   .:
.....................................................................
.virus.rat.trojan.malware.ransomware.worm.boom.malware.detection.....
.....................................................................
........................-=[wafaray v.1.0]=-..........................
...............BY:.alt3kx,.mindhack03d,.spk08........................
\n
"

echo -ne "$wafaray_banner"
#----------------------------------------
# GLOBAL VARIABLES
wafaray_path=$(pwd)
#----------------------------------------
# YARA Paths
yara_path="/YaraRules"
yara_script_path="$yara_path/YaraScripts"
yara_script_yaracompile="$yara_script_path/YaraCompile.py"
yara_compile_path="$yara_path/Compiled"
#----------------------------------------
# Temporal Paths
temporal_path="/temporal"
#----------------------------------------
# Apache paths
www_main="/var/www/html"
www_path="$www_main/upload"
apache_path="/etc/apache2"
apache_logs_path="/var/log/apache2"
modsecurity_path="/etc/modsecurity"
#----------------------------------------
# Compress Files
pkg_yara="YaraScripts.tar"
pkg_vhosts="vhosts.tar"
upload_page="upload.php"
upload_img="wafaray_image.png"
#----------------------------------------
# GIT REPOS / URL
wafaray_repo="https://github.com/alt3kx/wafaray"
yara_repo="https://github.com/Yara-Rules/rules"
crs_url="https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip"

# FUNCTIONS
msg_all(){
        echo "[!][$(date)][$1] $2"
        echo ""
        sleep 1
}

# INSTALL PROCESS
# - DEBIAN libraries
msg_all "install" "Debian package"
apt-get update
apt-get install -y
apt-get upgrade -y && apt-get dist-upgrade -y
apt-get install build-essential -y
apt-get install automake libtool make gcc pkg-config -y
apt-get install flex bison curl vim net-tools zip unzip -y

# - Create folders
msg_all "create" "folder: $temporal_path, $yara_compile_path, $www_path"
mkdir $temporal_path && chmod 1777 -R $temporal_path
mkdir -p $yara_compile_path && mkdir -p $www_path

# - Install WAF-MI YARA
msg_all "install" "Yara Libraries"
apt-get install libyara-dev libyara4 yara yara-doc libyara-dev python3-yara python3 python3-pip python3-venv python3-plyara -y

msg_all "install" "Perl libraries"
apt-get install libdigest-md5-file-perl libdigest-sha-perl libmldbm-perl libdbm-deep-perl libswitch-perl -y

msg_all "deploy" "WAFARAY YaraScripts"
cp $pkg_yara $yara_path
cd $yara_path
tar -xf $pkg_yara

msg_all "clone" "GitHut Yara Rules Repo"
cd $yara_path
git clone $yara_repo

msg_all "compile" "Yara rules"
cd $yara_compile_path
python3 $yara_script_yaracompile

# - Install ModSecurity
msg_all "install" "ModSecurity"
apt-get install apache2 libapache2-mod-security2 -y
cd $apache_path
ln -s $apache_logs_path logs

# - Configure ModSecurity
msg_all "Configure" "ModSecurity"
systemctl stop apache2
cp $modsecurity_path/modsecurity.conf-recommended $modsecurity_path/modsecurity.conf
sed -i "s,^SecRuleEngine .*,SecRuleEngine On,g" $modsecurity_path/modsecurity.conf
systemctl start apache2

# - Install CRS
msg_all "install" "ModSecurity CRS"
cd $wafaray_path
wget $crs_url
unzip v3.3.2.zip
mv coreruleset-3.3.2/crs-setup.conf.example $modsecurity_path/crs/crs-setup.conf
mv coreruleset-3.3.2/rules/ $modsecurity_path/crs/
cp $apache_path/mods-enabled/security2.conf $apache_path/mods-enabled/security2.conf_backup
echo "
<IfModule security2_module>
        SecDataDir /var/cache/modsecurity
        IncludeOptional /etc/modsecurity/crs-setup.conf
        IncludeOptional /etc/modsecurity/rules/*.conf
</IfModule>
" > $apache_path/mods-enabled/security2.conf

msg_all "update" "Apache apache2.conf"
sed -E -i "s,^(\s*)?Include(\s+)ports.conf,Include ports.conf\n\n# ModSecurity Includes\nInclude /etc/modsecurity/modsecurity\.conf\nInclude \/etc\/modsecurity\/crs\/crs\-setup\.conf\nInclude \/etc\/modsecurity\/crs/rules\/\*\.conf\n,g" $apache_path/apache2.conf

msg_all "add" "Apache libraries"
cd $apache_path
cp mods-available/proxy_http.load mods-enabled
cp mods-available/proxy.load mods-enabled/
cp mods-available/rewrite.load mods-enabled/
systemctl restart apache2

# - VIRTUAL HOST INSTALL
msg_all "install" "php"
apt-get install php -y

msg_all "update" "Apache ports.conf"
sed -E -i "s,^(\s*)?Listen(\s+)80,Listen 80\n\n# MOC ports\nListen 8080\nListen 18080\n,g" $apache_path/ports.conf

msg_all "deploy" "Apache vhosts"
cd $wafaray_path
cp $pkg_vhosts $apache_path
cd $apache_path/
tar -cf sites_enable_def.tar sites-enabled/
rm -fr sites-enabled/
tar -xf $pkg_vhosts

# - Upload PHP Page
msg_all "deploy" "PHP Upload page"
cd $wafaray_path
cp $upload_page $www_main
cp $upload_img $www_main

msg_all "Restart" "Apache"
service apache2 stop
service apache2 start
