{ self, lib, ... }:
count: lines:
lib.pipe lines [
  (lib.splitString "\n")
  (lib.map (self.indent count))
  (lib.concatStringsSep "\n")
]
