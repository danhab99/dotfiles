with builtins;
let
  logFiles = filter (f: match ".*\\.md$" f != null) (attrNames (readDir ./.));

  splitAt = sep: str: i: builtins.elemAt (builtins.split sep str) i;

  logs = map (
    l:
    let
      part = splitAt "-" l;
    in
    {
      index = part 0;
      kind = part 2;
      name = part 4;
      content = readFile ./${l};
    }
  ) logFiles;

  sortedLogs = sort (l: r: l.index < r.index) logs;

in
foldl' (
  version: log:
  let
    parts = map fromJSON (builtins.splitVersion version);
    major = elemAt parts 0;
    minor = elemAt parts 1;
    patch = elemAt parts 2;

    buildVersion = v: concatStringsSep "." (map toString v);
  in
  if log.kind == "major" then
    buildVersion [
      (major + 1)
      0
      0
    ]
  else if log.kind == "minor" then
    buildVersion [
      major
      (minor + 1)
      0
    ]
  else if log.kind == "patch" then
    buildVersion [
      major
      minor
      (patch + 1)
    ]
  else
    throw "weird kind of thing"
) "0.0.0" sortedLogs
