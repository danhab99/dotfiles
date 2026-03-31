# File template wrapper — returns a flake-parts module.
#
# Usage:
#   import ../_template.nix { name = "blank"; description = "..."; path = ./_files; }
#
# Registers flake.templates.<name>.

{ name
, description ? name
, path
, welcomeText ? null
}:

{ ... }:
{
  flake.templates.${name} = {
    inherit description path;
  } // (if welcomeText != null then { inherit welcomeText; } else {});
}
