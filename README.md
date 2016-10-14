nginxLuaGmFastdfs
===

说明
===
nginx + lua + gm + fastdfs 实现图片自动代理生成缩放、优化功能（类似淘宝的图片cdn服务）

目录
===
* [说明](#说明)
* [目录](#目录)
* [安装部署与配置](#安装部署与配置)
	* [Gm部署及配置](#gm-config)
	* [Fastdfs部署及配置](#fastdfs-config)
	* [Lua部署及配置](#lua-config)
	* [Nginx部署及配置](#nginx-config)
	
相关服务
==========

gm  config
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
		1. 方法一（自测失败）
		
				yum install -y gcc gcc-c++ make cmake autoconf automake
				
				yum install -y libpng-devel libjpeg-devel libtiff-devel jasper-devel freetype-devel
				
				yum install libtool-ltdl libtool-ltdl-devel freetype freetype-devel fontconfig-devel （可省略，此处安装的应是ImageMagic相关依赖）
				
				启用 EPEL repo 源：

				wget http://centos.ustc.edu.cn/epel/5/x86_64/epel-release-5-4.noarch.rpm
				
				rpm -Uvh epel-release-5-4.noarch.rpm
				
				yum --enablerepo=epel install jasper jasper-libs jasper-devel
				
				导入key
				rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
				
				安装GraphicsMagick （如果报错，请使用源码编译安装）								
				yum -y install GraphicsMagick GraphicsMagick-devel
			
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
							
		2.	方法二（源码编译安装,自测成功！）：[下载GraphicsMagick](http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.25/GraphicsMagick-1.3.25.tar.gz)，并解压，源码编译安装
					
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
 				

Fastdfs config
--------------
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
			
			wget http://downloads.sourceforge.net/project/fastdfs/FastDFS%20Server%20Source%20Code/FastDFS%20Server%20with%20PHP%20Extension%20Source%20Code%20V5.08/FastDFS_v5.08.tar.gz
			
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
			
	* 其他——配置文件内容：
		
		`/etc/fdfs/mod_fastdfs.conf` (请自行从fastdfs-nginx-module-master/src目录中将此文件拷贝到/etc/fdfs/目录下,否则会导致nginx启动出现问题，具体可参考下文nginx安装部分)
		
			connect_timeout=2
			network_timeout=30
			base_path=/opt/fastdfs
			load_fdfs_parameters_from_tracker=true
			storage_sync_file_max_delay = 86400
			use_storage_id = false
			storage_ids_filename = storage_ids.conf
			tracker_server=192.168.23.216:22122
			tracker_server=192.168.23.217:22122
			storage_server_port=23000
			group_name=group1
			url_have_group_name = true
			store_path_count=1
			store_path0=/opt/fastdfs/storage
			log_level=info
			log_filename= /opt/fastdfs/logs/mod_fastdfs.log
			response_mode=proxy
			if_alias_prefix=
			#include http.conf
			flv_support = true
			flv_extension = flv
			group_count = 1
			[group1]
			group_name=group1
			storage_server_port=23000
			store_path_count=1
			store_path0=/opt/fastdfs/storage
			
		`/etc/fdfs/client.conf`
			
			connect_timeout=30
			network_timeout=60
			base_path=/opt/fastdfs
			tracker_server=192.168.23.216:22122
			tracker_server=192.168.23.217:22122
			log_level=info
			use_connection_pool = false
			connection_pool_max_idle_time = 3600
			load_fdfs_parameters_from_tracker=false
			use_storage_id = false
			storage_ids_filename = storage_ids.conf
			http.tracker_server_port=80
			#include http.conf
			
		`/etc/fdfs/storage.conf`	
		
			disabled=false
			group_name=group1
			bind_addr=
			client_bind=true
			port=23000
			connect_timeout=30
			network_timeout=60
			heart_beat_interval=30
			stat_report_interval=60
			base_path=/opt/fastdfs
			max_connections=256
			buff_size = 256KB
			accept_threads=1
			work_threads=4
			disk_rw_separated = true
			disk_reader_threads = 1
			disk_writer_threads = 1
			sync_wait_msec=50
			sync_interval=0
			sync_start_time=00:00
			sync_end_time=23:59
			write_mark_file_freq=500
			store_path_count=1
			store_path0=/opt/fastdfs/storage
			#store_path1=/home/yuqing/fastdfs2
			subdir_count_per_path=256
			tracker_server=192.168.23.216:22122
			tracker_server=192.168.23.217:22122
			log_level=info
			run_by_group=
			run_by_user=
			allow_hosts=*
			file_distribute_path_mode=0
			file_distribute_rotate_count=100
			fsync_after_written_bytes=0
			sync_log_buff_interval=10
			sync_binlog_buff_interval=10
			sync_stat_file_interval=300
			thread_stack_size=512KB
			upload_priority=10
			if_alias_prefix=
			check_file_duplicate=0
			file_signature_method=hash
			key_namespace=FastDFS
			keep_alive=0
			##include /home/yuqing/fastdht/conf/fdht_servers.conf
			use_access_log = false
			rotate_access_log = false
			access_log_rotate_time=00:00
			rotate_error_log = false
			error_log_rotate_time=00:00
			rotate_access_log_size = 0
			rotate_error_log_size = 0
			log_file_keep_days = 0
			file_sync_skip_invalid_record=false
			use_connection_pool = false
			connection_pool_max_idle_time = 3600
			http.domain_name=
			http.server_port=80

		`/etc/fdfs/tracker.conf`	
		
			disabled=false
			bind_addr=
			port=22122
			connect_timeout=30
			network_timeout=60
			base_path=/opt/fastdfs
			max_connections=256
			accept_threads=1
			work_threads=4
			store_lookup=2
			store_group=group2
			store_server=0
			store_path=0
			download_server=0
			reserved_storage_space = 10%
			log_level=info
			run_by_group=
			run_by_user=
			allow_hosts=*
			sync_log_buff_interval = 10
			check_active_interval = 120
			thread_stack_size = 64KB
			storage_ip_changed_auto_adjust = true
			storage_sync_file_max_delay = 86400
			storage_sync_file_max_time = 300
			use_trunk_file = false
			slot_min_size = 256
			slot_max_size = 16MB
			trunk_file_size = 64MB
			trunk_create_file_advance = false
			trunk_create_file_time_base = 02:00
			trunk_create_file_interval = 86400
			trunk_create_file_space_threshold = 20G
			trunk_init_check_occupying = false
			trunk_init_reload_from_binlog = false
			trunk_compress_binlog_min_interval = 0
			use_storage_id = false
			storage_ids_filename = storage_ids.conf
			id_type_in_filename = ip
			store_slave_file_use_link = false
			rotate_error_log = false
			error_log_rotate_time=00:00
			rotate_error_log_size = 0
			log_file_keep_days = 0
			use_connection_pool = false
			connection_pool_max_idle_time = 3600
			http.server_port=8090
			http.check_alive_interval=30
			http.check_alive_type=tcp
			http.check_alive_uri=/status.html
			
		'/etc/fdfs/mime.types'(请从fastdfs源码编译所在的conf目录下自行拷贝至此目录)
		
		'/etc/fdfs/storage_ids.conf'(请从fastdfs源码编译所在的conf目录下自行拷贝至此目录)

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
	
8. 安装fastdfs-nginx-module模块（后面配置安装Nginx时有具体说明）

	

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



lua config
----------
## 安装说明
* [相关参考](http://www.cnblogs.com/yjf512/archive/2012/03/27/2419577.html)
* 注意事项
	* 为确保lua+gm顺利生成图片，请确保 fdfs所在的storage/data拥有足够的权限进行写操作！

安装、部署及配置
============

nginx config
-------------

## nginx安装说明
1. 前提及相关资料
	* 请先确保fastdfs部署完成后在安装nginx（需要部分依赖、模块）
	* [Nginx官网](http://nginx.org)
2. 下载Nginx（当前稳定版是[nginx-1.10.1](http://nginx.org/download/nginx-1.10.1.tar.gz)）

			wget http://nginx.org/download/nginx-1.10.1.tar.gz
			tar -zxvf nginx-1.10.1.tar.gz

	* 1.1. 安装pcre (`建议版本：8.35`)
		1. 获取pcre编译安装包，在http://www.pcre.org/上可以获取当前最新的版本

		2. 解压缩pcre-xx.tar.gz包。

		3. 进入解压缩目录，执行./configure。

		4. make & make install

	* 1.2.安装openssl （`建议版本：1.0.1u`）
		1. 获取openssl编译安装包，在http://www.openssl.org/source/上可以获取当前最新的版本。

		2. 解压缩openssl-xx.tar.gz包。

		3. 进入解压缩目录，执行./config。

		4. make & make install

		1.3.安装zlib
		1. 获取zlib编译安装包，在http://www.zlib.net/上可以获取当前最新的版本。

		2. 解压缩openssl-xx.tar.gz包。

		3. 进入解压缩目录，执行./configure。

		4. make & make install

	* 1.4.安装nginx （`建议版本：1.10.1`）
		1. 获取nginx，在http://nginx.org/en/download.html上可以获取当前最新的版本。

		2. 解压缩nginx-xx.tar.gz包。

		3. 进入解压缩目录，执行./configure

		4. make & make install

		若安装时找不到上述依赖模块，使用--with-openssl=<openssl_dir>、--with-pcre=<pcre_dir>、--with-zlib=<zlib_dir>指定依赖的模块目录。如已安装过，此处的路径为安装目录；若未安装，则此路径为编译安装包路径，nginx将执行模块的默认编译安装。
			
3. 下载[fastdfs-nginx-module模块](https://github.com/happyfish100/fastdfs-nginx-module)
			
			wget https://github.com/happyfish100/fastdfs-nginx-module/archive/master.zip
			unzip master
			
	`需要拷贝fastdfs-nginx-module-master/src/mod_fastdfs.conf到/etc/fdfs/目录下,否则会导致nginx启动出现问题`(也可以直接用一下配置替换)
	
			vi /etc/fdfs/mod_fastdfs.conf
			
	`mod_fastdfs.conf`
	
			connect_timeout=2
			network_timeout=30
			base_path=/opt/fastdfs
			load_fdfs_parameters_from_tracker=true
			storage_sync_file_max_delay = 86400
			use_storage_id = false
			storage_ids_filename = storage_ids.conf
			tracker_server=192.168.23.216:22122
			tracker_server=192.168.23.217:22122
			storage_server_port=23000
			group_name=group1
			url_have_group_name = true
			store_path_count=1
			store_path0=/opt/fastdfs/storage
			log_level=info
			log_filename= /opt/fastdfs/logs/mod_fastdfs.log
			response_mode=proxy
			if_alias_prefix=
			#include http.conf
			flv_support = true
			flv_extension = flv
			group_count = 1
			[group1]
			group_name=group1
			storage_server_port=23000
			store_path_count=1
			store_path0=/opt/fastdfs/storage

4. 下载[nginx-lua-module模块](http://blog.csdn.net/qq_25551295/article/details/51744815)
	1. 下载安装LuaJIT 2.1
	
			wget http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz
			tar zxf LuaJIT-2.1.0-beta2.tar.gz
			cd LuaJIT-2.1.0-beta2
			make
			make install
			（默认安装在/usr/loacl下）
			
	2. 下载ngx_devel_kit（NDK）模块
	
			wget https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
			tar -xzvf v0.2.19.tar.gz
			
	3. 下载最新的lua-nginx-module模块
	
			wget https://github.com/openresty/lua-nginx-module/archive/v0.10.2.tar.gz
			tar -xzvf v0.10.2.tar.gz	

5. 创建www用户和www组

			groupadd www  # 创建www组
    		useradd -g www www # 创建www用户隶属于www组 ( useradd -g GroupName userName )
    		passwd www  # 给www用户设置密码
			
6. 编译安装(请正确设定相关模块所在目录)

			#./configure --prefix=/opt/nginx-1.10.1 --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-pcre --add-module=/home/long.yan/ngx_devel_kit-0.2.18/ --add-module=/home/long.yan/lua-nginx-module-0.10.2/ --add-module=/home/yue.yang/fastdfs-nginx-module-master/src

			./configure --prefix=/opt/nginx --user=www --group=www --with-http_stub_status_module --with-http_realip_module --with-pcre --with-openssl=/home/yangyue/setup/openssl-1.0.1u --with-http_ssl_module --with-stream --add-module=/home/yangyue/setup/ngx_devel_kit-0.2.19/ --add-module=/home/yangyue/setup/lua-nginx-module-0.10.2/  (线上使用此配置)

			make
			
			make install
			
	安装成功后nginx将会安装在/opt/nginx-1.10.1中

	* 错误处理：
		
		* 错误一、找不到LuaJIT路径：

				export LUAJIT_LIB=/usr/local/lib
				export LUAJIT_INC=/usr/local/include/luajit-2.1

		* 错误二、error while loading shared libraries: libluajit-5.1.so.2: cannot open shared 解决办法，errorloadingskin

			一般我们在Linux下执行某些外部程序的时候可能会提示找不到共享库的错误, 比如:
 
					tmux: error while loading shared libraries: libevent-1.4.so.2: cannot open shared object file: No such file or directory

			原因一般有两个, 一个是操作系统里确实没有包含该共享库(lib*.so.*文件)或者共享库版本不对, 遇到这种情况那就去网上下载并安装上即可. 

			另外一个原因就是已经安装了该共享库, 但执行需要调用该共享库的程序的时候, 程序按照默认共享库路径找不到该共享库文件. 

			所以安装共享库后要注意共享库路径设置问题, 如下:

			1. 如果共享库文件安装到了/lib或/usr/lib目录下, 那么需执行一下ldconfig命令

				ldconfig命令的用途, 主要是在默认搜寻目录(/lib和/usr/lib)以及动态库配置文件/etc/ld.so.conf内所列的目录下, 搜索出可共享的动态链接库(格式如lib*.so*), 进而创建出动态装入程序(ld.so)所需的连接和缓存文件. 缓存文件默认为/etc/ld.so.cache, 此文件保存已排好序的动态链接库名字列表. 

			2. 如果共享库文件安装到了/usr/local/lib(很多开源的共享库都会安装到该目录下)或其它"非/lib或/usr/lib"目录下, 那么在执行ldconfig命令前, 还要把新共享库目录加入到共享库配置文件/etc/ld.so.conf中, 如下:

					# cat /etc/ld.so.conf
					include ld.so.conf.d/*.conf
					# echo "/usr/local/lib" >> /etc/ld.so.conf
					# ldconfig

		* 错误三、PCRE依赖错误
			1. 请确保pcre-devel模块被正确安装
					
					yum install pcre-devel

			2. 请注意不要使用过高的pcre版本，推荐使用yum安装的pcre或者pcre8.35,否则会出现依赖问题

		* 错误四、 OPENSSL错误
			1. 请确保openssl版本不要太高，推荐使用openssl-1.0.1u

		* Nginx推荐使用1.10.1
	
6. 相关配置
	* nginx.conf文件

			vi /opt/nginx-1.10.1/conf/nginx.conf
			
		编辑`nginx.conf`文件
	
            user                www www;
            worker_processes    4;

            error_log           /opt/nginx-1.10.1/logs/nginx_error.log crit;
            pid                 /opt/nginx-1.10.1/logs/nginx.pid;
            worker_rlimit_nofile 655350;

            events {
                use                 epoll;
                worker_connections  655350;
            }

            http {
                include             mime.types;
                default_type        application/octet-stream;
                charset             utf-8;
                server_tokens       off;

                server_names_hash_bucket_size   128;
                client_header_buffer_size       128k;
                #client_header_buffer_size       128k;
                large_client_header_buffers     4 128k;
                #large_client_header_buffers     4 32k;
                client_max_body_size            50m;

                sendfile                on;
                tcp_nopush              on;
                keepalive_timeout       60;
                tcp_nodelay             on;

                proxy_connect_timeout   5;
                proxy_read_timeout      60;
                #proxy_read_timeout      240;
                proxy_send_timeout      5;
                #proxy_send_timeout      60;
                proxy_buffer_size       32k;
                proxy_buffers           4 64k;
                proxy_busy_buffers_size 128k;
                proxy_temp_file_write_size 128k;

                gzip                on;
                gzip_min_length     1k;
                gzip_buffers        4 16k;
                gzip_http_version   1.0;
                gzip_comp_level     2;
                gzip_types          text/plain application/x-javascript application/javascript  text/css application/xml image/jpeg image/gif image/png;
                gzip_vary           on;

                proxy_temp_path     /opt/nginx-1.10.1/cache_temp;
                proxy_cache_path    /opt/nginx-1.10.1/cache_dir levels=1:2 keys_zone=cache_one:200m inactive=1d max_size=30g;

                include     /opt/nginx-1.10.1/conf/vhosts/*_vhost.conf;

                log_format  access  '$remote_addr - $remote_user [$time_local] "$request" '
                                    '$status $body_bytes_sent "$http_referer" '
                                    '"$http_user_agent" $http_x_forwarded_for ';
                access_log  logs/access.log  access;
            }

	* 创建/vhosts文件夹及相关vhost配置文件
	
			mkdir /opt/nginx-1.10.1/conf/vhosts
			
			vi /opt/nginx-1.10.1/conf/vhosts/img.100credit.com_vhost.conf
			
		编辑`img.100credit.com_vhost.conf`文件
		
            server {
                listen       80;
                server_name  img.100credit.com;
                index  index.html index.htm login.html;

                access_log logs/img.100credit.com_access.log;
                error_log  logs/img.100credit.com_error.log;

                location /hello_lua {
                      default_type 'text/plain';
                      content_by_lua 'ngx.say("hello, lua")';
                }

                #location  / {
                #        proxy_set_header        Host  $host;
                #        proxy_set_header        X-Real-IP  $remote_addr;
                #        proxy_set_header        REMOTE-HOST $remote_addr;
                #        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                #        proxy_pass http://img.100credit.com;
                #    }
                #

                location /group1/M00 {
                    alias /opt/fastdfs/storage/data;

                    set $image_root "/opt/fastdfs/storage/data";
                    #if ($uri ~ "/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/(.*)") {
                    if ($uri ~ "/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/(.*)") {
                        set $image_dir "$image_root/$3/$4/";
                        set $image_name "$5";
                        set $file "$image_dir$image_name";
                    }
                    if ($image_name ~ "([a-zA-Z0-9_\-]+)_([0-9]+x[0-9]+)?(q[0-9]{1,2})?.([a-zA-Z0-9]+)") {
                            set $a  "$1";
                            set $b  "$2";
                            set $c  "$3";
                            set $d  "$4";
                            set $e  "$5";
                            set $f  "$6";
                    }

                    if (!-f $file) {
                        # 关闭lua代码缓存，方便调试lua脚本
                        #lua_code_cache off;
                        content_by_lua_file "/opt/nginx-1.10.1/conf/lua/thumbnail.lua";
                    }
                    #   if (-f $file) {
                    #     rewrite ^(.*) http://www.jd.com break;
                    #   }

                    ngx_fastdfs_module;
                }

            }		            
	
	* 建立lua文件夹及相关脚本
	
			mkdir /opt/nginx-1.10.1/conf/lua
			vi /opt/nginx-1.10.1/conf/lua/thumbnail.lua
			
		编辑`thumbnail.lua`文件	
			
            -- 解析形如http://img.100credit.com/group1/M00/00/00/wKgX2FfgoISAdnJpAAAexdAvMYY573_100x100q50.png的图片并生成
            local preName = ngx.var.a
            local whParam = ngx.var.b
            local qParams = ngx.var.c
            local qParam = string.sub(qParams,2)
            local suffix = ngx.var.d

            local command = "gm convert " .. ngx.var.image_dir .. preName .. "." ..  suffix

            if (whParam=="")
                then
                else
                    command = command .. " -thumbnail " .. whParam
            end

            if (qParams=="")
                then
                else
                    command = command .. " -quality " .. qParam
            end

            command = command .. " " .. ngx.var.file

            os.execute("echo preName=" .. preName .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")
            os.execute("echo whParam=" .. whParam .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")
            os.execute("echo qParams=" .. qParams .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")
            os.execute("echo qParam=" .. qParam .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")
            os.execute("echo suffix=" .. suffix .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")
            os.execute("echo command=" .. command .. " > /opt/nginx-1.10.1/conf/lua/luaLog.txt")

            os.execute(command)
            ngx.redirect(ngx.var.uri)
         
		创建luaLog.txt文件用于记录lua执行日志，并赋予755权限，及所有权www用户
			
			touch /opt/nginx-1.10.1/conf/lua/luaLog.txt
			chmod 755 /opt/nginx-1.10.1/conf/lua/luaLog.txt
			chown www /opt/nginx-1.10.1/conf/lua/luaLog.txt				
7. 启动、关闭、reload nginx

	* 启动nginx
		
			/opt/nginx-1.10.1/sbin/nginx 
			
	* 关闭nginx (有时候可能不能正常关闭服务)
		
			/opt/nginx-1.10.1/sbin/nginx -s stop
			
		有时候可能不能正常关闭服务，可用如下命令检测
			
			ps -ef | grep nginx
			ps aux | grep nginx
	
	* reload nginx
		
			/opt/nginx-1.10.1/sbin/nginx -s reload

		
8. 检测成功失败

	* 检测nginx-lua-module是否安装成功：直接访问服务器地址/hello_lua,如果出现 hello, lua 则表示成功！

	* 检测fastdfs-nginx-module是否安装成功：需要两台已配置好的fastdfs服务器集群，配置同样的nginx，在A服务器上传任意图片，使用B的ip进行访问（或看相应目录下是否同步生成了新文件）

9. 异常及处理

	* 多去观察 /opt/nginx-1.10.1/logs文件夹下的log文件，大部分错误是因为文件夹不存在、或者没有写入权限导致的。
	
	* 如果没有任何错误，仅仅是nginx_error.log中频繁出现`worker process exited with fatal code 2 and cannot be	respawn`,请删除当前nginx，重新下载fastdfs-nginx-module并重新进行nginx编译安装。

#
# 其他 
* 给已安装的nginx增加新模块

	1. 先查看原有nginx编译参数，具体方法：
	
			/opt/nginx/sbin/nginx -V

	2. 在编译（configure && make ）nginx的目录下，进行重新编译: 
	
			./configure --prefix=/opt/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-pcre --add-module=/home/yangyue/ngx_devel_kit-0.2.18/ --add-module=/home/yangyue/lua-nginx-module-0.10.2/ --add-module=/home/yangyue/fdfsSetup/fastdfs-nginx-module-master/src/
			
	3. 停止现有的nginx服务
	
	4. 拷贝编译目录下 cp objs/nginx 覆盖已安装nginx中的sbin/nginx (记得提前备份)
	
			cp objs/nginx /opt/nginx/sbin/nginx
	
	5. 重启nginx服务即可










	