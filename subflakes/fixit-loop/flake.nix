{
  description = "fixit-loop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "fixit-loop";

    template = ./files;
    templateWelcome = "reprompt an llm until a problem is fixed";
  };
}
