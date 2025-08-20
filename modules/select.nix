select:
inputs@{ ... }:
{
  imports =
    let
      dir = builtins.readDir ../modules;
      names = builtins.attrNames dir;

      templates = builtins.filter
        (f:
          let
            isDirectory = dir.${f} == "directory";
            basename = builtins.baseNameOf f;
            matchExt = builtins.match "\\..*$" basename;
            extension = if matchExt == null then "" else builtins.elemAt matchExt 0;
          in
          (isDirectory && extension == "") || (extension == ".${select}")
        )
        names;

      getModuleSet = name: import ./${name};
      selectCorrectModule = name: builtins.getAttr select (getModuleSet name);
      selectedModules = map selectCorrectModule templates;
    in
    (map (m: m inputs) selectedModules);
}
