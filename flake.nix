{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        mermaid-cli = pkgs.buildNpmPackage (finalAttrs: {
          pname = "mermaid-cli";
          version = "11.14.0";

          src = pkgs.fetchFromGitHub {
            owner = "mermaid-js";
            repo = "mermaid-cli";
            tag = "${finalAttrs.version}";
            hash = "sha256-5AJZFZL5c0LCeo0hk+ONpGlY/LeB8XCKDZ6cug/TP2M=";
          };

          nativeBuildInputs = [];
          buildInputs = [];
          packages = [
            pkgs.noto-fonts-cjk-sans
          ];

          patches = [
            ./remove-puppeteer-from-dev-deps.patch # https://github.com/mermaid-js/mermaid-cli/issues/830
          ];

          npmDepsHash = "sha256-bb4t9jIyThEB9vrFx/tiQClNDdoAeDwGtaU4X3VXbrc=";

          env = {
            PUPPETEER_SKIP_DOWNLOAD = true;
          };

          npmBuildScript = "prepare";

          makeWrapperArgs = pkgs.lib.lists.optional (pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.chromium) "--set PUPPETEER_EXECUTABLE_PATH '${pkgs.lib.getExe pkgs.chromium}'";

          meta = {
            description = "Generation of diagrams from text in a similar manner as markdown";
            homepage = "https://github.com/mermaid-js/mermaid-cli";
            license = pkgs.lib.licenses.mit;
            mainProgram = "mmdc";
            maintainers = with pkgs.lib.maintainers; [ysndr];
            platforms = pkgs.lib.platforms.all;
          };
        });
      in {
        packages = {
          inherit mermaid-cli;
          default = mermaid-cli;
        };
      }
    );
}
