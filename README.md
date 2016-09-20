nginxLuaGmFastdfs
===

说明
===
nginx + lua + gm + fastdfs 实现图片自动代理生成缩放、优化功能（类似淘宝的图片cdn服务）

目录
===
* [说明](#说明)
* [目录](#目录)
* [相关服务介绍](#相关服务介绍)
	* [Nginx](#Nginx)
	* [Lua](#Lua)
	* [Gm](#Gm)
	* [Fastdfs](#Fastdfs) 
* [安装部署与配置](#安装部署与配置)
	* [Nginx部署及配置](#nginx-config)
	* [Lua部署及配置](#lua-config)
	* [Gm部署及配置](#gm-config)
	* [Fastdfs部署及配置](#fastdfs-config)

相关服务
==========

nginx config
------------

lua config
----------
* 注意事项
	* 为确保lua+gm顺利生成图片，请确保 fdfs所在的storage/data拥有足够的权限进行写操作！

gm config
---------

Fastdfs config
--------------

安装、部署及配置
============

nginx
-------------
* 给已安装的nginx增加新模块

	1. 先查看原有nginx编译参数，具体方法：
	
			/opt/nginx/sbin/nginx -V

	2. 在编译（configure && make ）nginx的目录下，进行重新编译: 
	
			./configure --prefix=/opt/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-pcre --add-module=/home/yangyue/ngx_devel_kit-0.2.18/ --add-module=/home/yangyue/lua-nginx-module-0.10.2/ --add-module=/home/yangyue/fdfsSetup/fastdfs-nginx-module-master/src/
			
	3. 停止现有的nginx服务
	
	4. 拷贝编译目录下 cp objs/nginx 覆盖已安装nginx中的sbin/nginx (记得提前备份)
	
			cp objs/nginx /opt/nginx/sbin/nginx
	
	5. 重启nginx服务即可

lua
------------
## 安装说明
* [相关参考](http://www.cnblogs.com/yjf512/archive/2012/03/27/2419577.html)

gm
----------
## 安装说明
1. 相关资料
	* [graphicsmagick官网安装手册](http://www.graphicsmagick.org/INSTALL-unix.html)
	* [graphicsmagick下载页面](https://sourceforge.net/projects/graphicsmagick/files/)
	* [graphicsmagick下载连接](http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.25/GraphicsMagick-1.3.25.tar.gz)
	* [graphicsmagick安装帖子](http://www.jb51.net/LINUXjishu/120332.html)
	* 其他
		* [ImageMagick官网Git](http://git.imagemagick.org/repos/ImageMagick)
		* [ImageMagick下载地址](http://www.imagemagick.org/script/binary-releases.php)
		* [imagemagick安装帖子](http://www.lifeba.org/arch/imagemagick.html)
2. 准备工作
	* centos 
	
	* 安装流程
		1. 准备安装环境
		
				yum install -y gcc gcc-c++ make cmake autoconf automake
				
				yum install -y libpng-devel libjpeg-devel libtiff-devel jasper-devel freetype-devel
				
				yum install libtool-ltdl libtool-ltdl-devel freetype freetype-devel fontconfig-devel （可省略，此处安装的应是ImageMagic相关依赖）
				
				启用 EPEL repo 源：

				wget http://centos.ustc.edu.cn/epel/5/x86_64/epel-release-5-4.noarch.rpm
				
				rpm -Uvh epel-release-5-4.noarch.rpm
				
				yum --enablerepo=epel install jasper jasper-libs jasper-devel
				
				导入key
				rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
				
				安装GraphicsMagick （如果报错，请使用源码编译安装）				yum -y install GraphicsMagick GraphicsMagick-devel
			
			* 问题及解决
				* yum报错：'UnicodeDecodeError: 'ascii' codec can't decode byte 0xbc'
					* 解决办法：
					
							（自测有效）
					
							cd /var/lib/rpm/
							rm -i __db.*
							yum clean all
							yum history new
							
						使用以上方法后有的系统可以解决，有的却不可以。
						终极解决方案：
						在 /usr/share/yum-cli/yummain.py和 /usr/lib64/python2.4/encodings/utf_8.py中加入三行：
						
							import sys
							reload(sys)
							sys.setdefaultencoding('gbk')
		2.	[下载GraphicsMagick](http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.25/GraphicsMagick-1.3.25.tar.gz)，并解压，源码编译安装
					
					./configure
					
					make
					
					make install
					
					将会默认在一下目录中安装相应文件：
					
					/usr/local/bin
					/usr/local/include
					/usr/local/lib
					/usr/local/share
				
				
3. 测试安装
	* 可以通过wget方式从网络上下载一张图片，然后使用如下命令进行测试：
	
			wget http://www.baidu.com/img/bd_logo1.png #下载图片
			
			gm identify bd_logo1.png #查看文件信息
			
			gm convert bd_logo1.png -thumbnail '100x100' output.png #生成缩略图
 				

fastdfs
-------------
## 安装说明

1. 准备工作
	* 相关资料
		* [FastDFS Git仓库](https://github.com/happyfish100/fastdfs)
		* [最新版本的FastDFS下载](http://sourceforge.net/projects/fastdfs/)
		* [参考资料](http://www.blogjava.net/Alpha/archive/2016/04/07/430008.html)

2. 下载安装libfastcommon
		
			git clone https://github.com/happyfish100/libfastcommon.git
			cd libfastcommon/
			./make.sh
			./make.sh install 
			
	确认make没有错误后，执行安装，64位系统默认会复制到/usr/lib64下。

	这时候需要设置环境变量或者创建软链接
		
			export LD_LIBRARY_PATH=/usr/lib64/
			ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
		
3. 下载安装fastdfs

	* [FastDFS_v5.08.tar.gz](http://downloads.sourceforge.net/project/fastdfs/FastDFS%20Server%20Source%20Code/FastDFS%20Server%20with%20PHP%20Extension%20Source%20Code%20V5.08/FastDFS_v5.08.tar.gz)	
			
			tar xzf FastDFS.tar.gz
			cd FastDFS/
			./make.sh
			./make.sh install

	确认make没有错误后，执行安装，默认会安装到/usr/bin中，并在/etc/fdfs中添加三个配置文件。

4. 修改配置文件

	首先将三个文件的名字去掉sample，暂时只修改以下几点，先让fastdfs跑起来，其余参数调优的时候再考虑。
	
	* tracker.conf 中修改
	
			base_path=/home/fastdfs #用于存放日志。
			http.server_port=8090 
			
	* storage.conf 中修改
		
			tracker_server=192.168.1.181:22122 #指定tracker服务器地址。
			base_path=/home/fastdfs #用于存放日志。
			store_path0=/home/fastdfs/storage #存放数据，若不设置默认为前面那个。
			
			http.server_port=80 
			group_name=group1 
			
	* client.conf 中同样要修改
	
			base_path=/home/fastdfs #用于存放日志。
			tracker_server=192.168.1.181:22122 #指定tracker服务器地址。
			http.tracker_server_port=80
			
			#include http.conf 
			#其它保持默认，注意上面那个是1个#，默认是2个#，去掉1个就行
	
	* 问题及解决：
		* `外网访问 出现net.ConnectException: Connection refused: connect`
			* 解决办法：storage的tracker_server地址必须是外网地址，重启FastDFS就好了。

5. 启动tracker和storage
		
			/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
			/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
			
			# netstat –lnp –tcp 参看端口是否起来，默认如果显示22122和8090,23000,80说明服务正常起来
	
6. 检查进程
	
			root@ubuntu:~# ps -ef |grep fdfs
			root       7819      1  0 15:24 ?        00:00:00 /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
			root       8046      1  0 15:36 ?        00:00:01 fdfs_storaged /etc/fdfs/storage.conf start
		
	表示启动ok了，若有错误，可以在/home/fastdfs目录下检查日志。

7. 上传/删除测试

	使用自带的fdfs_test来测试，使用格式如下：
		
			root@ubuntu:~# fdfs_test /etc/fdfs/client.conf upload /home/steven/01.jpg 
			...
			group_name=group1, ip_addr=192.168.1.181, port=23000
			storage_upload_by_filename
			group_name=group1, remote_filename=M00/00/00/wKgdhFTV0ZmAP3AZAPk-Io7D4w8580.jpg
			...
			example file url: http://192.168.1.181/group1/M00/00/00/wKgdhFTV0ZmAP3AZAPk-Io7D4w8580.jpg
			storage_upload_slave_by_filename
			group_name=group1, remote_filename=M00/00/00/wKgdhFTV0ZmAP3AZAPk-Io7D4w8580_big.jpg
			...
			example file url: http://192.168.1.181/group1/M00/00/00/wKgdhFTV0ZmAP3AZAPk-Io7D4w8580_big.jpg

	使用fdfs_delete_file来删除文件，格式如下：
	
			fdfs_delete_file /etc/fdfs/client.conf group1/M00/00/00/wKgdhFTV11uAXgKWAPk-Io7D4w8667.jpg

	可以看到，上传ok了，这里会生成两个文件，这是fastdfs的主/从文件特性，以后再介绍。example file url是不能在浏览器中直接打开的，除非配合nginx使用。删除文件需要完整的group_name和remote_filename。
	
8. 安装fastdfs-nginx-module模块

	

## FastDFS相关命令

* 注意：
	* 先重启storage服务，然后再启动nginx，注意顺序，否则会报端口占用的错误
	* 注意， 千万不要使用-9强行杀死进程 。
	* [相关资料](http://www.blogjava.net/Alpha/archive/2016/04/07/430008.html)

* 重启服务

	* 重启storage
    		
    		/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart    		
	* 重启tracker 
    	
    	/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart

* 关闭服务
	* 关闭storage
    		
    		killall fdfs_storaged
    		
	* 关闭tracker
   			
   			killall fdfs_trackered

* 查看集群状态
	
			/usr/bin/fdfs_monitor /etc/fdfs/storage.conf

* 上传/删除测试
	* 上传
   			
   			fdfs_test  /etc/fdfs/client.conf  upload  /home/website/platform/public/images/uploader/loading.gif
	
	* 删除
    	
    		fdfs_delete_file  /etc/fdfs/client.conf  group1/M00/00/00/ZciEZlepkl6Abj28AAAPOSSdASU225_big.gif





	啊实打实的