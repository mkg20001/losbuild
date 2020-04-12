{ pkgs ? import <nixpkgs> {} }:

let
  fhs = pkgs.buildFHSUserEnv {
    name = "lineageos";

    targetPkgs = pkgs: with pkgs; [
      gitRepo

      androidenv.androidPkgs_9_0.platform-tools

      bc
      binutils
      bison
      ccache
      curl
      flex
      freetype
      gcc
      git
      gitRepo
      git-lfs
      gnumake
      gnupg
      gperf
      imagemagick
      jdk
      libxml2
      lz4
      lzop
      m4
      nettools
      openssl
      perl
      pngcrush
      procps
      python2
      rsync
      schedtool
      SDL
      squashfsTools
      unzip
      utillinux
      which
      wxGTK30
      xml2
      xorg.libXext
      zip
      xorg.libXinerama
      xorg.libXcursor
      fontconfig
    ];

    multiPkgs = pkgs: with pkgs; [
      zlib
      ncurses5
      libcxx
      readline
    ];

    runScript = "bash";

    profile = ''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.jdk.home}
      ccache -M 50G
      export TMPDIR=/tmp
      export PS1='(lineageos) \[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };

in fhs.env
