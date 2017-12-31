rec {
  packageOverrides = defaultPkgs: with defaultPkgs; {
    mytexlive = with pkgs; texlive.combine {
      inherit (texlive) scheme-small collection-langgerman
      IEEEtran
      collection-fontsrecommended
      collection-latex
      collection-latexextra
      tracklang;
    };

    home = with pkgs; buildEnv {
      name = "home";
      paths = [ firefox tree ];
    };

    latex = with pkgs; buildEnv {
      ignoreCollisions = true;
      name = "latex";
      paths = [ mytexlive gentium-book-basic pythonPackages.pygments ];
    };
  };
}
