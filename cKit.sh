#!/bin/bash
#######################################/Color variables/#######################################
green='\e[32m'
blue='\e[34m'
clear='\e[0m'
###############################################################################################
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

#######################################/Functions/############################################

function access_and_ip_logs() {
for i in $(cat '/etc/userdomains' | grep -v '*' | awk -F":" '{print $1}'); do
                domains=${i};
                username="$(grep ${domains} /etc/userdomains | awk -F": " '{print $2 }' | tail -1)";
                echo "$domains access logs" #>> GETPOST.txt
                cat /home/$username/access-logs/$domains* | awk '{print $6 " " $7}' | sort | uniq -c | sort -rn | head #2>/dev/null 
                echo "$domains IP" #>> GETPOST.txt
                cat /home/$username/access-logs/$domains* | awk '{print $1}' | sort | uniq -c | sort -rn | head #2>/dev/null
        done
MenuAcess
}

function OnlyAccessLogs {
for i in $(cat '/etc/userdomains' | grep -v '*' | awk -F":" '{print $1}'); do
                domains=${i};
                username="$(grep ${domains} /etc/userdomains | awk -F": " '{print $2 }' | tail -1)";
                echo "$domains access logs" 
                cat /home/$username/access-logs/$domains* | awk '{print $6 " " $7}' | sort | uniq -c | sort -rn | head #2>/dev/null
        done
}

function SpecificDomainAccessLogs {
for i in $(grep $responsedomain '/etc/userdomains' | grep -v '*' | awk -F":" '{print $1}'); do
                domains=${i};
                username="$(grep ${domains} /etc/userdomains | awk -F": " '{print $2 }' | tail -1)";
                echo "$domains access logs"
                cat /home/$username/access-logs/$domains* | awk '{print $6 " " $7}' | sort | uniq -c | sort -rn | head #2>/dev/null
        done
}
function showexim(){
        exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort -n | uniq -c | sort -n
EmailsMenu
}


function originate(){
        grep "cwd=/home" /var/log/exim_mainlog | awk '{for(i=1;i<=10;i++){print $i}}' | sort | uniq -c | grep cwd | sort -n
EmailsMenu
}


function originate2(){
	egrep -R "X-PHP-Script"  /var/spool/exim/input/*
EmailsMenu
}


function whichphpscript(){
        grep 'cwd=/home' /var/log/exim_mainlog | awk '{print $3}' | cut -d / -f 3 | sort -bg | uniq -c | sort -bg
EmailsMenu
}

function getnetstat(){
        netstat -plan | grep :25 | awk {'print $5'} | cut -d: -f 1 | sort | uniq -c | sort -nk 1
EmailsMenu
}


function nobodyspam(){
       	ps -C exim -fH ewww | awk '{for(i=1;i<=40;i++){print $i}}' | sort | uniq -c | grep PWD | sort -n
EmailsMenu
}


function nobodyspamafter(){
       	grep "cwd=" /var/log/exim_mainlog | awk '{for(i=1;i<=10;i++){print $i}}' | sort | uniq -c | grep cwd | sort -n
EmailsMenu
}

function showeximsum(){
        exim -bpr | exiqsumm -c | head
EmailsMenu
}

##
# Function that lists all of the sleeping MySQL processes
# In many cases the sleeping processes could be causing high CPU load
##
function list_sleeping_mysql() {
    sleepingProc=$(mysqladmin proc | grep Sleep)
    if [ -z "$sleepingProc" ]; then
        echo "No Sleeping MySQL Proccesses ATM";
    else {
        mysqladmin proc | head -3
        mysqladmin proc | grep Sleep
    }
    fi
MySQLMenu
}

##
# Function that kills all of the sleeping MySQL processes
# In case you need to reduce the CPU load or free up some RAM you could use this function
##
function kill_mysql_sleeping_proc() {
    sleepingProc=$(mysqladmin proc | grep Sleep)
        if [ -z "$sleepingProc" ]; then
        echo "No Sleeping MySQL Proccesses ATM";
    else {
             for i in $(mysql -e 'show processlist' | grep 'Sleep' | awk '{print $1}'); do
                        echo Killed proccess: ${i}; mysql -e "kill ${i}";
                 done
    }
    fi
MySQLMenu
}
##
# Function that lists all MySQL proccesses
##
function show_full_processlist() {
    mysqladmin processlist status
MySQLMenu
}
##
# Function that shows the MySQL status and uptime
##
function mysql_status(){
    service mysql status
    mysqladmin status | grep -v "show processlist"
}

function is_extension(){
wget -O IsExtension.php https://raw.githubusercontent.com/bobbyiliev/cpanel-toolkit/master/dev/IsExtension.txt

echo "Enter extension:"
read a
if [ -f "IsExtension.php" ]; then
        sed -i "s/extensionExists/$a/g" IsExtension.php
fi
php IsExtension.php
rm IsExtension.php
ToolsMenu
}

function is_function(){
wget -O IsFunction.php https://raw.githubusercontent.com/bobbyiliev/cpanel-toolkit/master/dev/IsFunction.txt


echo "Enter function:"
read a
if [ -f "IsFunction.php" ]; then
        sed -i "s/functionExists/$a/g" IsFunction.php
fi
php IsFunction.php
rm IsFunction.php
ToolsMenu
}


###########################
###  Qucik Accsess Menu ###
###########################
MenuAcess(){

            	ColorGreen "        "
echo -ne "
Choose the information you need regardin Access Logs

$(ColorGreen '1)') GET/POST Requests + IP addresses for every website on the VPS
$(ColorGreen '2)') GET/POST Requests for every website on the VPS
$(ColorGreen '3)') GET/POST Requests for a specific website
$(ColorGreen '0)') Back to Main Menu

$(ColorBlue 'Choose an option:') "
                read a
                case $a in
                1) access_and_ip_logs;;
                2) OnlyAccessLogs;;
		3) MenuAcessDomain;;
		0) MainMenu;;
        esac
}

MenuAcessDomain(){

	echo -ne "
Please type the domain (example.com)"
                read responsedomain
		SpecificDomainAccessLogs
#if [[ $responsedomain != '*.*' ]]; then
#	echo "There is no such domain"
#	MenuAcessDomain
#fi
}

EmailsMenu(){

            	ColorGreen "        "
echo -ne "
Choose the information you need regarding Email Logs

$(ColorGreen '1)') Receive a sorted list of all the email senders in the exim mail queue.
$(ColorGreen '2)') The following script will check the script that will originate spam mails..
$(ColorGreen '3)') The following script will check for emails sent via php script.
$(ColorGreen '4)') See which script is being used to send the spam emails. If it is from php then use.
$(ColorGreen '5)') It shows the IPs which are connected to server through port number 25.
$(ColorGreen '6)') In order to find “nobody” spamming, issue the following command.
$(ColorGreen '7)') The above command is valid only if the spamming is currently in progress.
$(ColorGreen '8)') The following script will give the summary of mails in the mail queue.
$(ColorGreen '0)') Back to Main Menu.

$(ColorBlue 'Choose an option:') "
                read a
                case $a in
                1) showexim ;;
                2) originate;;
                3) originate2;;
                4) whichphpscript;;
                5) getnetstat;;
                6) nobodyspam;;
                7) nobodyspamafter;;
                8) showeximsum;;
                0) MainMenu;;
        esac
}

##
# The MySQL Menu
##
MySQLMenu(){
                ColorGreen "        "
echo -ne "

Choose the information you need regarding MySQL

$(ColorGreen '1)') List MySQL sleeping Processes.
$(ColorGreen '2)') Kill all MySQL sleeping Processes.
$(ColorGreen '3)') Show full processlist.
$(ColorGreen '4)') Show MySQL status and Uptime
$(ColorGreen '0)') Back To Main Menu.

$(ColorBlue 'Choose an option:') "
                read a
                case $a in
                1) list_sleeping_mysql;;
                2) kill_mysql_sleeping_proc;;
                3) show_full_processlist;;
 	        4) mysql_status;;
                0) MainMenu;;
        esac
}

ToolsMenu(){
                ColorGreen "        "
echo -ne "

Cool Tools

$(ColorGreen '1)') Check if an extension is enabled on the server.
$(ColorGreen '2)') Check if a function is enabled on the server.
$(ColorGreen '0)') Back To Main Menu.

$(ColorBlue 'Choose an option:') "
                read a
                case $a in
                1) is_extension;;
                2) is_function;;
                0) MainMenu;;
        esac
}

#################
# The Main Menu #
#################
MainMenu(){
clear
                ColorGreen "        "
echo -ne "
Main Menu
$(ColorGreen '1)') Access Logs Menu
$(ColorGreen '2)') SPAM Scan Menu
$(ColorGreen '3)') MySqL Menu
$(ColorGreen '4)') Handy Tools

$(ColorBlue 'Choose an option:') "
                read a
                case $a in
                1) MenuAcess;;
		2) EmailsMenu;;
		3) MySQLMenu;;
		4) ToolsMenu;;
        esac
}
clear
MainMenu
