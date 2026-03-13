{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    searxng
  ];
  networking.extraHosts = ''
    127.0.0.2 localsearx
  '';
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.2";
        secret_key = "secret key";
      };
    };
  };
}
