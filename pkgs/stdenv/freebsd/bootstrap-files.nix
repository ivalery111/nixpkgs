{ system }:
((import <nixpkgs> { }).callPackage (
  {
    stdenv,
    pkgsCross,
    runCommand,
    lib,
    buildPackages,
  }:
  let
    pkgs = pkgsCross.${system};
    pack-all =
      packCmd: name: pkgs: fixups:
      (runCommand name {
        requiredSystemFeatures = [ "recursive-nix" ];
      } ''
        nix_store=${lib.getBin buildPackages.nix}/bin/nix-store
        rsync=${lib.getExe buildPackages.rsync}
        base=$PWD
        requisites="$($nix_store --query --requisites ${lib.concatStringsSep " " pkgs} | tac)"

        rm -f $base/nix-support/propagated-build-inputs
        for f in $requisites; do
          cd $f
          $rsync --chmod="+w" -av . $base
        done
        cd $base

        rm -rf nix nix-support
        mkdir nix-support
        for dir in $requisites; do
          cd "$dir/nix-support" 2>/dev/null || continue
          for f in $(find . -type f); do
            mkdir -p "$base/nix-support/$(dirname $f)"
            cat $f >>"$base/nix-support/$f"
          done
        done
        cd $base

        ${fixups}

        rm .nix-socket
        ${packCmd}
      '');
    nar-all = pack-all "$nix_store --dump . | xz -9 -T $NIX_BUILD_CORES >$out";
    tar-all = pack-all "XZ_OPT=\"-9 -T $NIX_BUILD_CORES\" tar cJf $out .";
    coreutils-big = pkgs.coreutils.override { singleBinary = false; };
    mkdir = runCommand "mkdir" { coreutils = coreutils-big; } ''
      mkdir -p $out/bin
      cp $coreutils/bin/mkdir $out/bin
    '';
  in {
  bootstrap-files0 = nar-all "${system}-bootstrap-files0.nar.xz" (with pkgs; [bash mkdir xz gnutar]) ''
    rm -rf include lib/*.a lib/i18n lib/bash share
  '';
  bootstrap-files1 = tar-all "${system}-bootstrap-files1.tar.xz" (
    with pkgs;
    [
      (runCommand "bsdcp" { } "mkdir -p $out/bin; cp ${freebsd.cp}/bin/cp $out/bin/bsdcp")
      coreutils
      gnutar
      findutils
      gnumake
      gnused
      patchelf
      gnugrep
      gawk
      diffutils
      patch
      bash
      xz
      xz.dev
      gzip
      bzip2
      bzip2.dev
      curl
      expand-response-params
      binutils-unwrapped
      freebsd.libc
      llvmPackages.libcxx
      llvmPackages.libcxx.dev
      llvmPackages.compiler-rt
      llvmPackages.compiler-rt.dev
      llvmPackages.clang-unwrapped
      (freebsd.locales.override { locales = [ "C.UTF-8" ]; })
    ]
    # INSTRUCTIONS FOR GENERATING THE SPURIOUS LIST
    # - empty this list
    # - rebuild bootstrap files and update their urls and hashes
    # - turn on atime on your FreeBSD nix store filesystem
    # - run nix-collect-garbage on FreeBSD to make it so we rebuild FODs
    # - build the nixpkgs __bootstrapArchive attribute on FreeBSD
    # - reboot your FreeBSD system. Otherwise the atimes will simply be wrong because of kernel caching
    # - run a full build of stdenv on FreeBSD. with -j3, this takes 1h40 on my 20 cpu VM (AMD host)
    # - use the following to generate a list with access times and filenames
    #   find /nix/store/###-bootstrap-archive -type f | xargs stat | grep -E 'Access: 2|File:' | paste -d ' ' - - | awk '{ print $4 " " $5 " " $6 " " $2 }' | sort -n > atimes
    # - manually identify the point where files have no longer been accessed after the patching phase
    # - use your favorite text editor to snip out the time column, the /nix/store/###-bootstrap-archive/ prefix, and the files that have not been used during bootstrap
    # - turn off atime if it was off before since it will degrade performance
    # - manually remove from the list the following; they are not marked as atime'd even though they are used
    #   - bin/strings           # used only during bootstrap
    # - plop it here
  ) "xargs rm -f <${./bootstrap-files-spurious.txt}";
}
) { })
