inputs:
getter:

{
  imports =
    let
      lib = inputs.nixpkgs.lib;
    in
    lib.filter (x: x != null) (map getter (builtins.attrValues inputs));
}
