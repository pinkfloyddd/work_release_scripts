#!/usr/bin/python
#-*- coding:UTF-8 -*-
import os,socket
import IPy,telnetlib,time,sys
File=open('/home/app/tmp/useriplist','rw')
print "检查是否存在公钥"
if os.path.exists("/home/app/.ssh/id_dsa.pub"):
	print "已存在公钥"
	print "################################"
else:
	print "公钥不存在，创建公钥"
	os.system("ssh-keygen -t dsa -f $HOME/.ssh/id_dsa -P ''")
	print "创建完成"
	print "###############################"
for line1 in File:
	line=line1.strip('\n')
	USER=line.split('@')[0]
	IP=line.split('@')[-1]
	print "检查%s防火墙连通"%IP
	try:
		TN=telnetlib.Telnet(IP,port=22,timeout=10)
	except:
		print('{}防火墙不通'.format(IP))
	else:
		print('防火墙通,发送公钥到{}'.format(IP)) 
		os.system("ssh-copy-id -i /home/app/.ssh/id_dsa.pub " + line + " 2>> /home/app/tmp/log.ssh ")	
		print('{}公钥发送成功'.format(IP))
File.close()
