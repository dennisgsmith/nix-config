{
  lib,
  fetchFromGitHub,
  fetchurl,
  python3Packages,
}: let
  prompt_toolkit_v2 = python3Packages.buildPythonPackage {
    pname = "prompt-toolkit";
    version = "2.0.10";
    pyproject = true;
    build-system = [python3Packages.setuptools];

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/source/p/prompt_toolkit/prompt_toolkit-2.0.10.tar.gz";
      sha256 = "8Vr2j2bmZOqlWdSsipKBEe69X+2gwRc4tZmARSJIKds=";
    };

    propagatedBuildInputs = with python3Packages; [six wcwidth];
    meta = with lib; {
      description = "prompt_toolkit 2.x – vendored for druid";
      homepage = "https://github.com/prompt-toolkit/prompt_toolkit";
      license = licenses.mit;
    };
  };
in
  python3Packages.buildPythonPackage rec {
    pname = "monome-druid";
    version = "1.1.5";

    src = fetchFromGitHub {
      owner = "monome";
      repo = "druid";
      rev = "v${version}";
      sha256 = "1zaix0s5dif75qgxz2wrhpain79ykqd8l2wxjiv7nysss0593aj9";
    };

    propagatedBuildInputs = with python3Packages; [
      prompt_toolkit_v2
      setuptools
      setuptools-scm
      click
      packaging
      pyserial
      pyusb
      requests
      websockets
    ];

    nativeBuildInputs = with python3Packages; [
      pytest
      pip
    ];

    # Modern setuptools-scm handles archives without this obsolete plugin.
    postPatch = ''
      substituteInPlace setup.py \
        --replace-fail '        "setuptools_scm_git_archive",' ""
      substituteInPlace src/druid/__init__.py \
        --replace-fail 'import pkg_resources' 'from importlib.metadata import version' \
        --replace-fail '    from pkg_resources import get_distribution' "" \
        --replace-fail 'get_distribution("monome-druid").version' 'version("monome-druid")'
      # websockets >= 14 passes only the connection to server handlers.
      substituteInPlace src/druid/server.py \
        --replace-fail 'async def handle(self, websocket, path):' 'async def handle(self, websocket):'
    '';

    meta = with lib; {
      description = "Terminal interface for crow";
      homepage = "https://github.com/monome/druid";
      license = licenses.gpl3;
      authors = ["Dennis Smith <github.com/dennissmith>"];
    };

    pyproject = true;
    build-system = [python3Packages.setuptools];
  }
