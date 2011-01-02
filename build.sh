#!/bin/bash

SOURCESROOT="/home/ajnasz/src";
PREFIX='/usr/local';
BUILDCMD="make -j2";
CLEANCMD="make clean";
INSTALLCMD='sudo make install';
POSTINSTALL='';
SRCDIR='';
CONFIGUREOPTS="--prefix=$PREFIX";
NOSOURCE=0;
NOCONF=0;
NOINSTALL=0;
NOBUILD=0;
PATCH='';
BUILD_ENVS=''
VCS='';
VCS_REMOTE=''
GIT_CVS_PARS='';
function help {
  echo "Usage:"
  echo "$ ./build [arguments] \$project"
  echo "Arguments"
  printf "\t-i\tuse it to get informations about the build\n"
  printf "\t-b\tuse it to build predefined projects. You can use: 'mpd', 'mpdas', 'libmpdclient', 'ncmpcpp', 'fluxbox', 'vim', 'mplayer', 'rtorrent', 'libtorrent', 'urxvt', 'kernel', 'irssi', 'git', 'tmux', 'mc', 'conky', 'xvid'\n"
  printf "\t-p\tuse it to set the path to the project. This option should be defined if you don't specifiy a project\n"
  printf "\t-v\tuse it to set the version control system type: value could be: 'git', 'svn', 'hg'\n"
  printf "\t-o\tuse it to to specify custom configure options\n"
  printf "\t-s\tuse it if you don't want to update the source\n"
  printf "\t-c\tuse it if you don't want to run the configure script\n"
  printf "\t-n\tuse it if you don't want to install the stuff after compile\n"
  printf "\t-m\tuse it if you don't want to run the make command\n"
  printf "\t-h\tprints this help\n"
}

function getSource {
echo "soruce type: $1";
case $1 in
  'git')
    if [ -z "$VCS_REMOTE" ];
    then
      git pull;
    else
      git pull $VCS_REMOTE;
    fi
    ;;
  'git-cvs') git cvsimport $GIT_CVS_PARS;;
  'hg') hg pull;hg update;;
  'svn') svn up;;
  'cvs') cvs up;;
  '*')
    echo "ERROR: invalid VCS"
    echo
    help
    exit 4
  ;;
esac
}
function setConfig {
  case $1 in
        'mpd')
          SRCDIR="$SOURCESROOT/mpd"
          VCS="git"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-lastfm --enable-mms --enable-http-output --enable-fifo --enable-alsa --enable-lame-encoder --enable-mpg123 --enable-curl --with-mpc"
        ;;

        'libmpdclient')
          SRCDIR="$SOURCESROOT/libmpdclient"
          VCS="git"
        ;;

        'mpdas')
          SRCDIR="$SOURCESROOT/mpdas"
          VCS="git"
          NOCONF=1
        ;;

        'ncmpcpp')
          SRCDIR="$SOURCESROOT/ncmpcpp"
          VCS="git"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-clock --enable-outputs --enable-visualizer --with-taglib"
        ;;

        'fluxbox')
          SRCDIR="$SOURCESROOT/fluxbox"
          VCS="git"
          VCS_REMOTE="origin master"
        ;;

        'vim')
          SRCDIR="$SOURCESROOT/vim"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-rubyinterp --enable-perlinterp --enable-pythoninterp --with-compiledby=ajnasz --enable-gui=gtk2"
          VCS="hg"
        ;;

        'mplayer')
          SRCDIR="$SOURCESROOT/mplayer"
          VCS="svn"
        ;;

        'rtorrent')
          SRCDIR="$SOURCESROOT/rtorrent"
          VCS="svn"
        ;;

        'libtorrent')
          SRCDIR="$SOURCESROOT/libtorrent"
          VCS="svn"
          POSTINSTALL="sudo ldconfig";
        ;;

        'urxvt')
          SRCDIR="$SOURCESROOT/urxvt.git"
          VCS="git-cvs"
          GIT_CVS_PARS='-p x -v -d :pserver:anonymous@cvs.schmorp.de:/schmorpforge rxvt-unicode'

          CONFIGUREOPTS="$CONFIGUREOPTS --enable-xft --enable-font-styles --enable-fading --enable-transparency --enable-unicode3 --enable-perl --enable-256-color"
          # PATCH="patch -p1 < doc/urxvt-8.2-256color.patch"
        ;;

        'qemu')
          SRCDIR="$SOURCESROOT/qemu-0.10.5"
          NOSOURCE=1
        ;;

        'mutt')
          # DEBIAN CONF:
          # -DOMAIN
          # +DEBUG
          # -HOMESPOOL  +USE_SETGID  +USE_DOTLOCK  +DL_STANDALONE
          # +USE_FCNTL  -USE_FLOCK
          # +USE_POP  +USE_IMAP  +USE_SMTP  +USE_GSS  -USE_SSL_OPENSSL  +USE_SSL_GNUTLS  +USE_SASL  +HAVE_GETADDRINFO
          # +HAVE_REGCOMP  -USE_GNU_REGEX
          # +HAVE_COLOR  +HAVE_START_COLOR  +HAVE_TYPEAHEAD  +HAVE_BKGDSET
          # +HAVE_CURS_SET  +HAVE_META  +HAVE_RESIZETERM
          # +CRYPT_BACKEND_CLASSIC_PGP  +CRYPT_BACKEND_CLASSIC_SMIME  -CRYPT_BACKEND_GPGME
          # -EXACT_ADDRESS  -SUN_ATTACHMENT
          # +ENABLE_NLS  -LOCALES_HACK  +COMPRESSED  +HAVE_WC_FUNCS  +HAVE_LANGINFO_CODESET  +HAVE_LANGINFO_YESEXPR
          # +HAVE_ICONV  -ICONV_NONTRANS  +HAVE_LIBIDN  +HAVE_GETSID  +USE_HCACHE
          # -ISPELL

          SRCDIR="$SOURCESROOT/mutt"
          VCS="hg"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-external-dotlock"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-debug"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-external-dotlock"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-pop --enable-imap --enable-smtp --with-gss --with-gnutls --with-sasl"
          CONFIGUREOPTS="$CONFIGUREOPTS --with-idn"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-hcache"
        ;;

        'kernel')
          VCS='none'
          SRCDIR="$SOURCESROOT/kernel/latest"
          NOSOURCE=1
          NOCONF=1
          CONCURRENCY_LEVEL=2
          CLEANCMD="make-kpkg clean"
          BUILDCMD="time fakeroot make-kpkg --append-to-version=-ajnasz kernel_image kernel_headers"
          NOINSTALL=1
        ;;


        'irssi')
          VCS='svn';
          SRCDIR="$SOURCESROOT/irssi"
        ;;

        'git')
          VCS='git';
          SRCDIR="$SOURCESROOT/git";
          BUILDCMD="make all html -j2";
          INSTALLCMD="sudo make install install-html quick-install-man";
          POSTINSTALL="sudo cp contrib/completion/git-completion.bash /etc/bash_completion.d/git";
        ;;

        'tmux')
          VCS='git-cvs'
          GIT_CVS_PARS='-p x -v -d :pserver:anonymous@tmux.cvs.sourceforge.net:/cvsroot/tmux tmux'
          SRCDIR="$SOURCESROOT/tmux.git"
          # NOCONF=1
        ;;

        'mc')
          VCS='git'
          SRCDIR="$SOURCESROOT/mc"
        ;;

        'conky')
          VCS='none'
          SRCDIR="$SOURCESROOT/conky"
          CONFIGUREOPTS="$CONFIGUREOPTS --enable-wlan --enable-ibm"
        ;;

        'xvid')
          VCS='git'
          SRCDIR="$SOURCESROOT/xvidcore"
          NOCONF=1
          BUILDCMD="dpkg-buildpackage"
        ;;

      'libev')
          VCS='git-cvs'

          GIT_CVS_PARS='-p x -v -d :pserver:anonymous@cvs.schmorp.de/schmorpforge libev'
          SRCDIR="$SOURCESROOT/libev"
          # NOCONF=1
      ;;

  esac
}

function get_build_info {
  setConfig $1;
  printf "project: $1\n";
  printf "\tvcs: $VCS\n";
  if [ "$VCS" == "git-cvs" ];then
    printf "\tgit-cvs-pars: $GIT_CVS_PARS\n";
  fi;
  printf "\tsrcdir: $SRCDIR\n";
  printf "\tconfigure: $CONFIGUREOPTS\n";
  printf "\tbuildcmd: $BUILDCMD\n";
  printf "\tcleancmd: $CLEANCMD\n";
  if [ $PATCH -ne 0 ];then
    printf "\tpatch: $PATCH\n";
  fi;
  if [ $NOCONF -ne 0 ];then
    printf "\tnoconf: $NOCONF\n";
  fi;
  if [ $NOSOURCE -ne 0 ];then
    printf "\tnosource: $NOSOURCE\n";
  fi;
}


n=1
while [ $# -gt 0 ]
do
  case $1 in
    -*) break;;
    *) eval "arg_$n=\$1"; n=$(( $n + 1 )) ;;
  esac
  shift
done

if [ $arg_1 ];
then
  setConfig $arg_1;
fi;

while getopts "p:v:b:o:i:nmhsc" Option; do
  case $Option in
    'p') # path

      if [ -z "$SRCDIR" ];
      then
        SRCDIR="$OPTARG";
      fi
    ;;

    'v') # VCS
      if [ -z "$VCS" ];
      then
        case "$OPTARG" in
          'git')VCS='git';;
          'svn')VCS='svn';;
          'hg')VCS='hg';;
          'cvs')VCS='cvs';;
        esac
      fi
    ;;

    'b') # predefined project
      setConfig $OPTARG;
    ;;

    'o')
      CONFIGUREOPTS="$OPTARG"
    ;;

    's')
      NOSOURCE=1
    ;;

    'c') # no configure
      NOCONF=1
    ;;

    'n') # no install
      NOINSTALL=1
    ;;

    'm') # no build
      NOBUILD=1
    ;;

    'i') # get info about the build
      get_build_info $OPTARG;
      exit 0;
    ;;

    'h') # help
      help;
      exit 0;
    ;;
  esac
done


if [ -z "$SRCDIR" ];
then
  echo "ERROR: source dir not configured"
  echo
  help
  exit 1
elif ! [ -e "$SRCDIR" ]; then
  echo "ERROR: source dir does not exists"
  echo
  help
  exit 2
elif ! [ -d "$SRCDIR" ]; then
  echo "ERROR: source dir is not a directory"
  echo
  help
  exit 3
fi


cd $SRCDIR

if [ $NOSOURCE -eq 0 ];
then
  echo "get source"
  sleep 2
  getSource $VCS
else
  echo "skip getting source"
fi

if [ $NOBUILD -eq 0 ];
then
  echo $CLEANCMD;
  if ! $CLEANCMD;
  then
    echo "$CLEANCMD failed";
    exit 1;
  fi
else
  echo "skip clean"
fi

if [ $NOCONF -eq 0 ];
then
  if [ -z "$CONFIGUREOPTS" ];
  then
    echo "configure"
    sleep 2
    if ! ./configure;
    then
      exit 1;
    fi
  else
    echo "configure with options $CONFIGUREOPTS"
    sleep 2
    if ! ./configure $CONFIGUREOPTS;
    then
      exit 1
    fi
  fi
else
  echo "skip configuring"
fi

if [ ! -z "$PATCH" ];
then
  echo 'apply patches';
  $PATCH;
fi;

if [ $NOBUILD -eq 0 ];
then
  echo $BUILDCMD;
  if ! $BUILDCMD;
  then
    exit 1;
  fi
else
  echo "skip building"
fi

if [ $NOINSTALL -eq 0 ];
then
  echo "do you want to install?"
  read INSTALLE
  case "$INSTALLE" in
    'y' | 'yes' | 'i' | 'igen' | 'I' | 'Y')
      if ! $INSTALLCMD;
      then
        exit 1;
      fi
    ;;
    *)
      echo "bad answer"
      echo "exit"
      exit 5
  esac
else
  echo "skip install"
fi

if [ ! -z "$POSTINSTALL" ];
then
    echo "post install: $POSTINSTALL";
    if ! $POSTINSTALL;
    then
      exit 1;
    fi;
fi;
