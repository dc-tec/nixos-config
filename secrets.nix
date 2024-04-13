let 
  legion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+Jr/yT9Jzazr0mRg1ep2alG6fuqqtZ94PowZC8yHjp";
  hosts = [ legion ];

  roelc = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ7HSO8O+R1NoKTzdcqWrANt0przSD6ucWqY9G/tJN9" ];
  users = roelc;

in 
{
  "secrets/passwords/users/roelc.age".publicKeys = hosts ++ users;
  "secrets/passwords/users/root.age".publicKeys = hosts ++ users;

  "secrets/authorized_keys/roelc.age".publicKeys = hosts ++ users;
  "secrets/authorized_keys/root.age".publicKeys = hosts ++ users;

  "secrets/network/wireless.age".publicKeys = hosts ++ users;
}
