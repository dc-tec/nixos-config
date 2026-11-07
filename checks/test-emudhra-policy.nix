{ lib, policy }:
let
  versions = [
    {
      version = "1.25.12";
      fixed = false;
    }
    {
      version = "1.26.9";
      fixed = false;
    }
    {
      version = "1.26.10";
      fixed = true;
    }
    {
      version = "1.26.11";
      fixed = true;
    }
    {
      version = "1.27.2";
      fixed = false;
    }
    {
      version = "1.27.3";
      fixed = true;
    }
    {
      version = "1.28.0";
      fixed = true;
    }
  ];
in
lib.all (case: policy.isFixedGo case.version == case.fixed) versions
&& policy.blacklistFor "3.131.0" == map (root: root.name) policy.roots
&& policy.blacklistFor "3.131.1" == [ "Comodo AAA Services root" ]
