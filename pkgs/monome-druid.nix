{
  lib,
  fetchFromGitHub,
  fetchurl,
  python3Packages,
}: let
  prompt_toolkit_v2 = python3Packages.buildPythonPackage {
    pname = "prompt-toolkit";
    version = "2.0.10";
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
      setuptools_scm
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

    meta = with lib; {
      description = "Terminal interface for crow";
      homepage = "https://github.com/monome/druid";
      license = licenses.gpl3;
      authors = ["Dennis Smith <github.com/dennissmith>"];
    };
  }
