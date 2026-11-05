# SOC-OS — Sistema Operacional de Controle

![Status](https://img.shields.io/badge/status-alpha-orange)
![Base](https://img.shields.io/badge/base-Arch%20Linux-blue)
![Interface](https://img.shields.io/badge/interface-TUI-green)
![License](https://img.shields.io/badge/license-GPL--2.0-lightgrey)

O **SOC-OS** é uma distribuição Linux minimalista, baseada no Arch Linux, projetada para rodar exclusivamente em interface de terminal (TUI). Inspirado na estética de terminais retrô (como os vistos em Fallout 4), mas com foco absoluto em **confiabilidade, previsibilidade e automação industrial**.

O sistema não possui interface gráfica (X11/Wayland) por padrão. Toda a interação, configuração e desenvolvimento ocorrem no terminal, otimizando o uso de hardware e garantindo estabilidade para ambientes de chão de fábrica e sistemas embarcados.
                                                                       -                                                                       
<pre style="color: green; font-family: monospace;">
                                            #                                            
                                            #+                                           
                                           ###                                           
                                          ##+##                                          
                                          #+++##                                         
                                         ##++++#                                         
                                        ##+++++##                                        
                                        #+++++++##                                       
                                       ##++++++++#                                       
                                      ##+++++++++##                                      
                                      #+++++++++++##                                     
                                     ##++++++++++++#.                                    
                                    ##+++++++++++++##                                    
                                    #++++##+++###+++##                                   
                               ##++++++#####+++++###+++#                                 
                              ##++###+++##+#########++++##                               
                             ##++###++##+#####+#++#++#++++###                            
                         ###+#+++##++##+#########+#+++#++++#+                            
                        #+++###++##++####+++#+++#+#++###+++###-                          
                      ###+++#####++#++#+++++++#####+####++#++++###                       
                #####++##++++######++##+#++############++###++++##+#####                 
           ####+++++++#++++++#######++++#######+++++##+#####+++++##++++++####            
      ####+++++++++++++##++++++######+++++#+#########+#####++++##+++++++++++++#####      
  ####++++++++++++++++++#+++++++########++++########+#####+++++#+++++++++++++++++++####  
       +####+++++++++++++##++++++###########++#########+++++++##+++++++++++++####        
             #####+++###+++++##++++################+++++++######+++++++####              
                  ###+++#########+++++#####++++++++#######++#++++####-                   
                     ##++++#+++#+#####+++##++++++++++##########+++##                     
                       ##+++++##+++++++#####++++++######++#+++++++####                   
                        ###++++#+++++++++##############+++++++###                        
                           #######++++++++++#######+##########                           
                                 ####++#########++++#-                                   
                                    ##+++++++++++++##                                    
                                     ##+++++++++++##                                     
                                      #+++++++++++#                                      
                                      -#+++++++++#+                                      
                                       ##+++++++##                                       
                                        ##++++++#                                        
                                         #+++++#-                                        
                                         ##+++##                                         
                                          ##++#                                          
                                           #+##                                          
                                           ###                                           
                                            ##                                           
                                            #                                            
</pre>
                                                                                         
                                                                                         
                                                                                         
                                                             
                                                                                                                                               
                                                                                                                                               
                                                                                                                                               
                                                                                                                                               
                                                                                                                                               


## 🚀 Funcionalidades (v0.1)

- **Interface TUI Integral**: Menu central em Bash com estética terminal e paleta de cores focada em legibilidade (verde fósforo).
- **Systemd-boot + UEFI**: Inicialização rápida e segura.
- **Autologin e Tmux**: O sistema inicia e cai direto no menu, com barra de status superior exibindo temperatura da CPU, uso de RAM e carga do sistema em tempo real.
- **Meta-pacotes**: Estrutura baseada em PKGBUILDs do Arch Linux (`soc-base`).
- **Repositório Local**: Instalação via repositório customizado `[soc]`.

### Menu Principal
Atualmente, o sistema oferece as seguintes rotas:
1. **Desenvolvedor**: Acesso ao VIM e toolchains básicas.
2. **Industrial**: Atalhos para ferramentas de automação (arduino-cli, beremiz, GnuCOBOL).
3. **Navegador Web**: Navegação via terminal (`w3m`, `lynx` ou `browsh`).
4. **Internet**: Gerenciamento de rede (Cabo/Wi-Fi/Autoconectar) via `NetworkManager`.
5. **IntraChat**: Sistema de mensagens locais (LAN) usando `ngircd` e `weechat`.
6. **Arquivos**: Gerenciador de arquivos em terminal.
7. **Bash Livre**: Shell puro.
8. **Sistema**: Monitoramento de temperatura, espaço em disco e atualizações.
9. **Energia**: Desligar, reiniciar ou suspender com confirmação.

## 🛠️ Tecnologias e Linguagens Suportadas
O SOC-OS foi desenhado para ser um canivete suíço para engenharia e automação:
- **Sistemas**: C, C++, Rust, Go.
- **Web/Scripts**: Python, Lua, Node.js, TypeScript, Perl.
- **Corporativo/Industrial**: Java (Temurin LTS), COBOL (GnuCOBOL), Ladder (via Beremiz/ClassicLadder).
- **Hardware**: Suporte a placas Arduino via `arduino-cli`.

## 📂 Estrutura do Projeto
A organização do código foi pensada para separar a lógica de instalação, os pacotes e as customizações do sistema:

```text
SOC-OS/
├── installer/         # Script principal de instalação (soc-install.sh)
├── packages/          # Meta-pacotes do SOC e repositório local
│   ├── soc-base/      # Pacote base (PKGBUILD do menu, autologin, configs)
│   └── repo/          # Repositório pacman local gerado [soc]
├── overlay/           # Arquivos que são copiados para o sistema final (/etc, /usr)
├── branding/          # Identidade visual (ASCII art, /etc/issue)
├── tests/             # Scripts e arquivos para testes em máquinas virtuais
└── docs/              # Documentação técnica, arquitetura e roadmap
```
## 💻 Como instalar (Ambiente de Desenvolvimento)

*Nota: O projeto está em estágio Alpha. Recomenda-se o uso em Máquinas Virtuais (VirtualBox ou QEMU/KVM) com UEFI habilitado.*

1. Inicie uma máquina virtual com a ISO oficial do Arch Linux (em modo UEFI).
2. No terminal do Arch ISO, digite as seguintes instruções:
   ```bash
   loadkeys br-abnt2
   pacman -Sy git
   git clone https://github.com/Tostesx/SOC-OS.git
   cd SOC-OS
   chmod +x installer/soc-install.sh
   ./installer/soc-install.sh
   ```
