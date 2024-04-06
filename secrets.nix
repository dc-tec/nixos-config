let 
  legion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ3XBgAWMTPR/gR2v5zOmKZKUs8RYkKp+MK7tOzPn9G";
  hosts = [ legion ];

  roelc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBU9qmqJ/OBagFNN+xKNcFVcpA5tB+OKbT30yC0Y4aD";
  users = roelc;

in 
{
  "secrets/passwords/users/roelc.age".publicKeys = hosts ++ users;
  "secrets/passwords/users/root.age".publicKeys = hosts ++ users;
}
