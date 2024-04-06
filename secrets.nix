let 
  legion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+Jr/yT9Jzazr0mRg1ep2alG6fuqqtZ94PowZC8yHjp";
  hosts = [ legion ];

  roelc = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMv5eUMUemXu9U7hmGIqLCjtTrSX+O60Avwx10FVZxm" ];
  users = roelc;

in 
{
  "secrets/passwords/users/roelc.age".publicKeys = hosts ++ users;
  "secrets/passwords/users/root.age".publicKeys = hosts ++ users;
}
