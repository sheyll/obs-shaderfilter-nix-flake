{
  description = "Shaderfilter OBS plugin";

  inputs.obs-shaderfilter = {
    url = "github:exeldro/obs-shaderfilter?rev=fe622e1bfb27eac2a4fa96259824ab4cc33cc214";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    obs-shaderfilter,    
  }: let
    overlays = [
      (self: super: {
        obs-studio-plugins =
          (super.obs-studio-plugins or {})
          // {
            shaderfilter =
              self.callPackage
              ({
                lib,
                stdenv,
                cmake,
                obs-studio,
                libGL,
                pkg-config,
                qt5,
                addOpenGLRunpath,
              }:
                stdenv.mkDerivation rec {
                  pname = "shaderfilter";
                  version = "1.3";
                
                  src = obs-shaderfilter;

                  nativeBuildInputs = [cmake pkg-config qt5.wrapQtAppsHook ];
                  buildInputs = [obs-studio libGL qt5.qtbase];

                  cmakeFlags = ["-DOBSSourcePath=${obs-studio}"];
                  meta = with lib; {
                    description = "Plugin for OBS Studio that adds shaders.";
                    homepage = "https://github.com/exeldro/obs-shaderfilters";
                    maintainers = [];
                    license = licenses.gpl2Plus;
                    platforms = ["x86_64-linux" "i686-linux"];
                  };
                }){};
          };
      })
    ];
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      inherit overlays;
    };
  in {
    overlays.default = overlays;
    packages.x86_64-linux.shaderfilter = pkgs.obs-studio-plugins.shaderfilter;
    packages.x86_64-linux.default = self.packages.x86_64-linux.shaderfilter;
  };
}
