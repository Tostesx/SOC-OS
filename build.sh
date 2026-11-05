#!/usr/bin/env bash
set -euo pipefail

# Define os caminhos
BASE_DIR="/home/tostesx/Documentos/GitHub/SOC-OS"
PKG_DIR="$BASE_DIR/packages/soc-base"
REPO_DIR="$BASE_DIR/packages/repo"

echo ">>> 1. Atualizando a versão do PKGBUILD automaticamente..."
cd "$PKG_DIR"
# Lê a versão atual e soma +1
CURRENT_REL=$(grep '^pkgrel=' PKGBUILD | cut -d'=' -f2)
NEXT_REL=$((CURRENT_REL + 1))
sed -i "s/^pkgrel=.*/pkgrel=$NEXT_REL/" PKGBUILD

echo ">>> 2. Limpando pacotes antigos da pasta soc-base..."
rm -f *.pkg.tar.zst

echo ">>> 3. Compilando o pacote (pegando o overlay novo)..."
makepkg -f --noextract -d

echo ">>> 4. Limpando a pasta do repositório..."
cd "$REPO_DIR"
rm -f *.pkg.tar.zst *.db* *.files*

echo ">>> 5. Copiando APENAS a versão nova e recriando o banco..."
# Copia o pacote exato que acabamos de compilar
cp "$PKG_DIR/soc-base-0.1.0-${NEXT_REL}-x86_64.pkg.tar.zst" .
repo-add soc.db.tar.gz soc-base-0.1.0-${NEXT_REL}-x86_64.pkg.tar.zst

echo ">>> 6. Consertando os links para o GitHub..."
rm -f soc.db soc.files
cp soc.db.tar.gz soc.db
cp soc.files.tar.gz soc.files

echo ">>> SUCESSO! Versão $NEXT_REL compilada e repositório atualizado."
echo ">>> Abra o GitHub Desktop, faça o Commit e o Push."
