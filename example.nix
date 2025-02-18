{
  services.firewalld = {
    enable = true;
    services = {
      kdeconnect = {
        short = "KDE Connect";
        ports = [
          {
            port = {
              from = 1714;
              to = 1764;
            };
            protocol = "tcp";
          }
          {
            port = {
              from = 1714;
              to = 1764;
            };
            protocol = "udp";
          }
        ];
      };
      localsend = {
        short = "LocalSend";
        ports = [
          {
            port = 53317;
            protocol = "tcp";
          }
          {
            port = 53317;
            protocol = "udp";
          }
        ];
      };
    };
    zones = {
      public = {
        services = [
          "kdeconnect"
          "localsend"
        ];
      };
    };
  };
}
