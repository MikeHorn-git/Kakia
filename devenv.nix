{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    powershell
    rubocop
  ];

  enterTest = ''
    pwsh -v
    rubocop -v
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    mdformat.enable = true;
    nixfmt.enable = true;
    rubocop = {
      enable = true;
      name = "rubocop";
      entry = "${pkgs.rubocop}/bin/rubocop -A";
      files = "(Vagrantfile$)";
    };
    trim-trailing-whitespace.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
