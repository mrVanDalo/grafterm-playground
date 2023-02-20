{
  description = "grafterm playground";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      configuration = {
        version = "v1";
        datasources.prometheus.prometheus.address = "http://prometheus.pepe.private";
        dashboard = {
          grid.fixedWidgets = false;
          widgets = [
            {
              title = "Test";
              gridPos.w = 10;
              graph = {
                visualization = {
                  legend = {
                    disable = false;
                    rightSide = false;
                  };
                  yAxis = {
                    unit = "short";
                    decimals = 1;
                  };
                };
                queries = [
                  {
                    datasourceID = "prometheus";
                    legend = "Inside";
                    expr = "avg(homeassistant_sensor_temperature_celsius{friendly_name=~\"Temperatur_01_temperature|Temperatur_02_temperature|Temperatur_03_temperature|Temperatur_04_temperature|Temperatur_05_temperature\"})";
                  }
                  {
                    datasourceID = "prometheus";
                    legend = "Outside";
          expr = "homeassistant_sensor_temperature_celsius{entity=\"sensor.home_outdoor_temperature\"}";
                  }
                ];
              };
            }
          ];
        };
      };
    in
    {


      # nix develop
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.grafterm ];
      };

      # nix run
      apps.default = self.apps.${system}.test;

      # nix run ".#test"
      # nix run ".#test" -- -s 48h -e 0h
      apps.test = {
        type = "app";
        program = toString (pkgs.writeShellScript "test" ''
          ${pkgs.grafterm}/bin/grafterm -c ${pkgs.writeText "test" (builtins.toJSON configuration)} "$@"
        '');
      };
      apps.cat = self.apps.${system}.print;
      apps.print = {
        type = "app";
        program = toString (pkgs.writeShellScript "test" ''
          cat ${pkgs.writeText "test" (builtins.toJSON configuration)} | ${pkgs.jq}/bin/jq
        '');
      };
    }));
}
