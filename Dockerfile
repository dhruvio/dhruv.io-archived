FROM nixos/nix:2.0

RUN nix-channel --add https://nixos.org/channels/nixos-18.03 nixpkgs \
 && nix-channel --update \
 && nix-env -i -A nixpkgs.chromium nixpkgs.nodejs-8_x nixpkgs.git nixpkgs.fontconfig nixpkgs.freefont_ttf \
 && ln -s /root/.nix-profile/etc/fonts /etc/fonts

ENV PORT=3000 HOSTNAME=0.0.0.0
EXPOSE 3000

ADD . /app
WORKDIR /app

RUN npm install

CMD ["npm", "start"]
