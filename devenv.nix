{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [ git powershell rubyPackages_3_4.rubocop ];

  enterTest = ''
    pwsh -v
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    mdformat.enable = true;
    nixfmt-classic.enable = true;
    rubocop = {
      enable = true;
      name = "rubocop";
      entry = "${pkgs.rubyPackages_3_4.rubocop}/bin/rubocop -A";
      files = "(Vagrantfile$)";
    };
    trim-trailing-whitespace.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
