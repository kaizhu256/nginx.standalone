#!/bin/sh

shEval () {
  ## this function evals $1
  echo $1
  eval "$1"
}

shMain () {
  ## this function is the main program
  ## cwd
  local CWD=$(pwd)
  ## nginx_standalone's root directory
  local DIR=$( cd "$( dirname "$0" )" && pwd )
  ## nginx version
  local NGINX_VERSION=1.5.12
  ## nginx executable
  local NGINX=.install/nginx.$NGINX_VERSION.$(uname).$(uname -m)
  ## nginx executable with prefix
  local NGINX_P="$NGINX -p '$CWD/nginx'"
  local SCRIPT=":"
  echo $DIR
  case $1 in

  ## build userland nginx
  build)
    SCRIPT="$SCRIPT; cd '$DIR'"
    SCRIPT="$SCRIPT; echo && echo 'building $NGINX ...'"

    ## os specific parameters
    local CONFIGURE_OPENSSL="\.\/config "
    local CFLAGS
    local LDFLAGS
    case $(uname) in
    Darwin)
      CONFIGURE_OPENSSL="\.\/Configure darwin64-x86_64-cc "
      CFLAGS="-arch x86_64"
      LDFLAGS="-arch x86_64"
      ;;
    esac

    ## get source code
    SCRIPT="$SCRIPT; [ -d .src ] || mkdir .src"
    SCRIPT="$SCRIPT; cd .src"
    ## get nginx source code
    SCRIPT="$SCRIPT; if [ ! -d nginx ]; then"
    SCRIPT="$SCRIPT curl -sL https://github.com/nginx/nginx/archive/v$NGINX_VERSION.tar.gz"
    SCRIPT="$SCRIPT | tar -xzvf - && mv nginx-$NGINX_VERSION nginx"
    SCRIPT="$SCRIPT; fi"
    ## get openssl source code
    SCRIPT="$SCRIPT; if [ ! -d openssl ]; then"
    SCRIPT="$SCRIPT curl -sL https://github.com/openssl/openssl/archive/OpenSSL_1_0_1g.tar.gz"
    SCRIPT="$SCRIPT | tar -xzvf - && mv openssl-OpenSSL_1_0_1g openssl"
    SCRIPT="$SCRIPT; fi"
    ## get pcre source code
    SCRIPT="$SCRIPT; if [ ! -d pcre ]; then"
    SCRIPT="$SCRIPT curl -sL http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.gz"
    SCRIPT="$SCRIPT | tar -xzvf - && mv pcre-8.33 pcre"
    SCRIPT="$SCRIPT; fi"
    ## get zlib source code
    SCRIPT="$SCRIPT; if [ ! -d zlib ]; then"
    SCRIPT="$SCRIPT curl -sL https://github.com/madler/zlib/archive/v1.2.8.tar.gz"
    SCRIPT="$SCRIPT | tar -xzvf - && mv zlib-1.2.8 zlib"
    SCRIPT="$SCRIPT; fi"

    ## create build dir
    SCRIPT="$SCRIPT; cd $DIR"
    SCRIPT="$SCRIPT; if [ ! -d .build ]; then cp -a .src .build; fi"

    ## configure nginx
    SCRIPT="$SCRIPT; cd $DIR/.build/nginx"
    SCRIPT="$SCRIPT; [ -f Makefile ] || ./configure "

    ## http://wiki.nginx.org/Modules
    ## Addition - Append text to pages.
    SCRIPT="$SCRIPT --with-http_addition_module"
    ## Auth Request - Implements client authorization based on the result of a subrequest. 1.5.4
    SCRIPT="$SCRIPT --with-http_auth_request_module"
    ## Degradation - Allow to return 204 or 444 code for some locations on low memory condition. 0.8.25
    SCRIPT="$SCRIPT --with-http_degradation_module"
    ## Embedded Perl - Use Perl in Nginx config files. 0.3.21
    # SCRIPT="$SCRIPT --with-http_perl_module"
    ## FLV - Flash Streaming Video 0.4.7
    SCRIPT="$SCRIPT --with-http_flv_module"
    ## GeoIP - Creates variables with information from the MaxMind GeoIP binary files. 0.8.6, 0.7.63
    # SCRIPT="$SCRIPT --with-http_geoip_module"
    ## Google Perftools - Google Performance Tools support. 0.6.29
    # SCRIPT="$SCRIPT --with-google_perftools_module"
    ## Gzip Precompression - Serves precompressed versions of static files. 0.6.23
    SCRIPT="$SCRIPT --with-http_gzip_static_module"
    ## Gunzip - On-the-fly decompressing of gzipped responses. 1.3.6
    SCRIPT="$SCRIPT --with-http_gunzip_module"
    ## Image Filter - Transform images with Libgd 0.7.54
    # SCRIPT="$SCRIPT --with-http_image_filter_module"
    ## MP4 - Enables mp4 streaming with seeking ability. 1.1.3, 1.0.7
    SCRIPT="$SCRIPT --with-http_mp4_module"
    ## Random Index - Randomize directory indexes. 0.7.15
    SCRIPT="$SCRIPT --with-http_random_index_module"
    ## Real IP - For using nginx as backend 0.3.8
    SCRIPT="$SCRIPT --with-http_realip_module"
    ## Secure Link - Protect pages with a secret key. 0.7.18
    SCRIPT="$SCRIPT --with-http_secure_link_module"
    ## SSL - HTTPS/SSL support.
    SCRIPT="$SCRIPT --with-http_ssl_module"
    ## Stub Status - View server statistics. 0.1.18
    SCRIPT="$SCRIPT --with-http_stub_status_module"
    ## Substitution - Replace text in pages
    SCRIPT="$SCRIPT --with-http_sub_module"
    ## WebDAV - WebDAV pass-through support. 0.3.38
    SCRIPT="$SCRIPT --with-http_dav_module"
    ## XSLT - Post-process pages with XSLT. 0.7.8
    # SCRIPT="$SCRIPT --with-http_xslt_module"
    ## Mail Core - Core parameters for mail module.
    SCRIPT="$SCRIPT --with-mail"
    ## POP3 - POP3 settings.
    # SCRIPT="$SCRIPT --without-mail_pop3_module"
    ## IMAP - IMAP settings.
    # SCRIPT="$SCRIPT --without-mail_imap_module"
    ## SMTP - SMTP settings.
    # SCRIPT="$SCRIPT --without-mail_smtp_module"
    ## SSL - This module ensures SSL/TLS support for POP3/IMAP/SMTP.
    SCRIPT="$SCRIPT --with-mail_ssl_module"

    ## http://wiki.nginx.org/InstallOptions
    ## Files and permissions
    ##  - defines a directory that will keep server files. This same directory will also be used for all relative paths set by configure (except for paths to libraries sources) and in the nginx.conf configuration file. It is set to the /usr/local/nginx directory by default.
    # SCRIPT="$SCRIPT --prefix=path"
    ##  - sets the name of an nginx executable file. This name is used only during installation. By default the file is named prefix/sbin/nginx.
    # SCRIPT="$SCRIPT --sbin-path=path"
    ##  — sets the name of an nginx.conf configuration file. If needs be, nginx can always be started with a different configuration file, by specifying it in the command-line parameter -c file. By default the file is named prefix/conf/nginx.conf.
    # SCRIPT="$SCRIPT --conf-path=path"
    ##  — sets the name of an nginx.pid file that will store the process ID of the main process. After installation, the file name can always be changed in the nginx.conf configuration file using the pid directive. By default the file is named prefix/logs/nginx.pid.
    # SCRIPT="$SCRIPT --pid-path=path"
    ##  — sets the name of the primary error, warnings, and diagnostic file. After installation, the file name can always be changed in the nginx.conf configuration file using the error_log directive. By default the file is named prefix/logs/error.log. The special "stderr" value tells nginx to log pre-configuration messages to the standard error.
    # SCRIPT="$SCRIPT --error-log-path=path"
    ##  — sets the name of the primary request log file of the HTTP server. After installation, the file name can always be changed in the nginx.conf configuration file using the access_log directive. By default the file is named prefix/logs/access.log.
    # SCRIPT="$SCRIPT --http-log-path=path"
    ##  — sets the name of an unprivileged user whose credentials will be used by worker processes. After installation, the name can always be changed in the nginx.conf configuration file using the user directive. The default user name is nobody.
    # SCRIPT="$SCRIPT --user=name"
    ##  — sets the name of a group whose credentials will be used by worker processes. After installation, the name can always be changed in the nginx.conf configuration file using the user directive. By default, a group name is set to the name of an unprivileged user.
    # SCRIPT="$SCRIPT --group=name"

    ## Event loop
    # SCRIPT="$SCRIPT --with-select_module"
    ##  — enables or disables building a module that allows the server to work with the select() method. This module is built automatically if the platform does not appear to support more appropriate methods such as kqueue, epoll, rtsig, or /dev/poll.
    # SCRIPT="$SCRIPT --with-poll_module"
    # SCRIPT="$SCRIPT --without-select_module"
    ##  — enables or disables building a module that allows the server to work with the poll() method. This module is built automatically if the platform does not appear to support more appropriate methods such as kqueue, epoll, rtsig, or /dev/poll.
    # SCRIPT="$SCRIPT --without-poll_module"

    ## Optional modules
    SCRIPT="$SCRIPT --with-openssl=../openssl"
    ## disables building a module that compresses responses of an HTTP server. The zlib library is required to build and run this module.
    # SCRIPT="$SCRIPT --without-http_gzip_module"
    ## disables building a module that allows an HTTP server to redirect requests and change URI of requests. The PCRE library is required to build and run this module. The module is experimental - its directives may change in the future.
    # SCRIPT="$SCRIPT --without-http_rewrite_module"
    ## disables building an HTTP server proxying module.
    # SCRIPT="$SCRIPT --without-http_proxy_module"
    ## enables building a module that adds the HTTPS protocol support to an HTTP server. This module is not built by default. The OpenSSL library is required to build and run this module.
    # SCRIPT="$SCRIPT --with-http_ssl_module"
    ## sets the path to the sources of the PCRE library. The library distribution (version 4.4 - 8.21) needs to be downloaded from the PCRE site and extracted. The rest is done by nginx's ./configure and make. The library is required for regular expressions support in the location directive and for the ngx_http_rewrite_module module. See notes below for using system PCRE on FreeBSD systems.
    SCRIPT="$SCRIPT --with-pcre=../pcre"
    ## builds the PCRE library with "just-in-time compilation" support.
    SCRIPT="$SCRIPT --with-pcre-jit"
    ## sets the path to the sources of the zlib library. The library distribution (version 1.1.3 - 1.2.5) needs to be downloaded from the zlib site and extracted. The rest is done by nginx's ./configure and make. The library is required for the ngx_http_gzip_module module.
    SCRIPT="$SCRIPT --with-zlib=../zlib"

    ## Compilation controls
    ## sets additional parameters that will be added to the CFLAGS variable.
    SCRIPT="$SCRIPT --with-cc-opt='$CFLAGS'"
    ## sets additional parameters that will be used during linking.
    SCRIPT="$SCRIPT --with-ld-opt='$LDFLAGS'"

    ## custom configure
    SCRIPT="$SCRIPT && perl -e 's/\.\/config /$CONFIGURE_OPENSSL/' -i -p objs/Makefile"

    ## make nginx
    SCRIPT="$SCRIPT && make"

    ## install nginx
    SCRIPT="$SCRIPT && cd '$DIR'"
    SCRIPT="$SCRIPT && [ -d .install ] || mkdir .install"
    SCRIPT="$SCRIPT && cp .build/nginx/objs/nginx $NGINX"
    SCRIPT="$SCRIPT && echo '... built $NGINX' && echo"
    shEval "$SCRIPT"
    ;;

  ## restart nginx
  nginxRestart)
    SCRIPT="$SCRIPT; echo 'stopping nginx ...'"
    SCRIPT="$SCRIPT; $NGINXP -s stop"
    SCRIPT="$SCRIPT && echo 'stopped nginx'"
    SCRIPT="$SCRIPT; echo 'starting nginx ...'"
    SCRIPT="$SCRIPT; $NGINXP"
    SCRIPT="$SCRIPT && echo 'started nginx'"
    shEval "$SCRIPT"
    ;;

  ## stop nginx
  nginxStop)
    SCRIPT="$SCRIPT; echo 'stopping nginx ...'"
    SCRIPT="$SCRIPT; $NGINXP -s stop"
    SCRIPT="$SCRIPT && echo 'stopped nginx'"
    shEval "$SCRIPT"
    ;;

  esac
}

shMain $1 $2 $3 $4
