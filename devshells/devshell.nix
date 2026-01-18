{
  name,
  versions,
}:
inputs@{ pkgs, lib, ... }:
lib.attrsets.mapAttrs (
  version: body:
  pkgs.mkShell (
    body.env or { }
    // {
      name = "${name}-${version}";
      buildInputs = body.packages;
      shellHook = body.shellHook or "";
    }
  )
) (versions inputs)
