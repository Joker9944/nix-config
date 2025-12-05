{ jail, teamspeak3, ... }:
jail "jailed-teamspeak3" teamspeak3 (
  with jail.combinators;
  [
    network
    gui
  ]
)
