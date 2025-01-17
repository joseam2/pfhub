#
# $ nix-shell --pure --argstr tag 20.09
#

{
  tag ? "21.05",
}:
let
  pkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${tag}.tar.gz") {};
  pypkgs = pkgs.python3Packages;
  extra = with pypkgs; [ black pylint flake8 ipywidgets ];
in
  pkgs.mkShell rec {
    name = "pfhub-shell";
    nativeBuildInputs = with pypkgs; [
      jupyter
      pandas
      pip
      pyyaml
      toolz
      plotly
      ipywidgets
      dash
    ];

    shellHook = ''
      SOURCE_DATE_EPOCH=$(date +%s)
      export PYTHONUSERBASE=$PWD/.local
      export USER_SITE=`python -c "import site; print(site.USER_SITE)"`
      export PYTHONPATH=$PYTHONPATH:$USER_SITE
      export PATH=$PATH:$PYTHONUSERBASE/bin

      export OMPI_MCA_plm_rsh_agent="${pkgs.openssh.out}"/bin/ssh
      export PETSC_DIR="${pkgs.petsc.out}"
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

      jupyter nbextension install --py widgetsnbextension --user
      jupyter nbextension enable widgetsnbextension --user --py
      pip install jupyter_contrib_nbextensions --user > /dev/null 2>&1
      pip install jupyter_dash --user > /dev/null 2>&1
      jupyter contrib nbextension install --user > /dev/null 2>&1
      jupyter nbextension enable spellchecker/main > /dev/null 2>&1

    '';
  }
