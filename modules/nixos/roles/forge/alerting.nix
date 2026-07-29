{
  services.prometheus = {
    ruleFiles = [ ./prometheus-rules.yml ];
    alertmanagers = [
      {
        static_configs = [
          { targets = [ "127.0.0.1:9093" ]; }
        ];
      }
    ];

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      configuration = {
        global.resolve_timeout = "5m";
        route = {
          receiver = "local-only";
          group_by = [
            "alertname"
            "instance"
          ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };
        receivers = [
          { name = "local-only"; }
        ];
      };
    };
  };
}
