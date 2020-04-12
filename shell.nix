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
      gcc
      git
      git-lfs
      gnumake
      gnupg
      gperf
      imagemagick
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
      zip
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
      ccache -M 50G
    '';
  };

in fhs.env
