{
  disko.devices = {
    disk = {
      # --- SSD 1: SYSTEM ---
      system = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt_root";
                # Wir legen das Passwort temporär im Live-System hier ab
                passwordFile = "/tmp/secret.key";
                settings.allowDiscards = true;
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
      };
      # --- SSD 2: SPIELE ---
      games = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt_games";
                passwordFile = "/tmp/secret.key";
                settings.allowDiscards = true;
                content = {
                  type = "zfs";
                  pool = "gamepool";
                };
              };
            };
          };
        };
      };
    };
    
    # --- ZFS POOLS & DATASETS ---
    zpool = {
      rpool = {
        type = "zpool";
        options = { ashift = "12"; autotrim = "on"; };
        rootFsOptions = { acltype = "posixacl"; xattr = "sa"; compression = "lz4"; mountpoint = "none"; };
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            # Die EYD Magie: Disko erstellt den Snapshot automatisch nach Formatierung!
            postCreateHook = "zfs snapshot rpool/root@blank";
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            postCreateHook = "zfs snapshot rpool/home@blank";
          };
        };
      };
      gamepool = {
        type = "zpool";
        options = { ashift = "12"; autotrim = "on"; };
        rootFsOptions = { acltype = "posixacl"; xattr = "sa"; compression = "lz4"; mountpoint = "none"; };
        datasets = {
          "games" = {
            type = "zfs_fs";
            mountpoint = "/storage/games";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
