{ config, pkgs, ... }:

{
  # --- ZFS Snapshot Automatisierung (Sanoid) ---
  services.sanoid = {
    enable = true;
    interval = "minutely"; # Prüft minütlich, aber erstellt Snapshots nach Plan

    # Templates definieren die Aufbewahrungsdauer
    templates = {
      default = {
        hourly = 24;   # Letzte 24 Stunden
        daily = 7;     # Letzte 7 Tage
        monthly = 2;   # Letzte 2 Monate
        autoprune = true;
        autosnap = true;
      };
      
      # Längere Speicherung für wichtige Backups
      backup = {
        hourly = 36;
        daily = 30;    # 30 Tage rückwirkend
        monthly = 6;   # 6 Monate rückwirkend
        autoprune = true;
        autosnap = true;
      };
      
      # Weniger wichtige Daten (Games/Media) - Spart Speicherplatz
      media = {
        hourly = 0; 
        daily = 3; 
        monthly = 0; 
        autoprune = true; 
        autosnap = true; 
      };
    };

    # Zu sichernde Datasets
    datasets = {
      # System & Home
      "rpool/home" = { use_template = [ "default" ]; };
      "rpool/root" = { use_template = [ "default" ]; };
    };
  };
  # NEU: Automatisches Scrubbing (Daten-Integritätsprüfung)
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";  # Prüft jede Woche auf Bit-Rot
  };
}
