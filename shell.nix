{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [ 
      inlyne
      mdbook
      mdbook-d2
      mdformat
    ];

    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1;
}
