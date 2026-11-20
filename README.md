# Painel de Suporte de TI

🌐 **Português (BR)** | [English](README.en.md)

Script em **Batch (.bat)** com menu interativo para equipes de TI executarem tarefas comuns de manutenção, rede, impressão, diagnóstico e drivers em computadores Windows, sem precisar decorar comandos.

![Plataforma](https://img.shields.io/badge/plataforma-Windows%2010%2F11-0078D6)
![Linguagem](https://img.shields.io/badge/linguagem-Batch-4D4D4D)
![Requer](https://img.shields.io/badge/requer-Administrador%20(fun%C3%A7%C3%B5es%20cr%C3%ADticas)-red)

---

## Sumário

- [Funcionalidades](#funcionalidades)
- [Requisitos](#requisitos)
- [Como usar](#como-usar)
- [Controle de permissão (administrador)](#controle-de-permissão-administrador)
- [Registro de ações (log)](#registro-de-ações-log)
- [Detalhes das funções](#detalhes-das-funções)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Personalização](#personalização)
- [Avisos importantes](#avisos-importantes)
- [Solução de problemas](#solução-de-problemas)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

> **Nota:** o menu do script é exibido em português (sem acentos, para compatibilidade com o CMD). A documentação também está disponível em [inglês](README.en.md).

---

## Funcionalidades

| Nº | Função | Categoria | Exige admin |
|----|--------|-----------|:-----------:|
| 1 | Limpeza de arquivos temporários | Manutenção | Sim |
| 2 | Limpeza de disco avançada | Manutenção | Sim |
| 3 | Verificar e reparar arquivos do Windows (SFC) | Manutenção | Sim |
| 4 | Reparar a imagem do Windows (DISM) | Manutenção | Sim |
| 5 | Verificar o disco C: (CHKDSK) | Manutenção | Sim |
| 6 | Saúde do disco (HD/SSD) | Manutenção | Não |
| 7 | Reset de rede (IP, Winsock e DNS) | Rede e Internet | Sim |
| 8 | Informações de rede | Rede e Internet | Não |
| 9 | Testes de conectividade | Rede e Internet | Não |
| 10 | Limpar cache DNS | Rede e Internet | Sim |
| 11 | Abrir Conexões de Rede | Rede e Internet | Não |
| 12 | Limpar fila de impressão travada | Impressão | Sim |
| 13 | Listar impressoras | Impressão | Não |
| 14 | Informações do sistema | Diagnóstico | Não |
| 15 | Monitor de recursos e processos | Diagnóstico | Não |
| 16 | Dispositivos com erro | Drivers e Atualizações | Não |
| 17 | Atualizar drivers (Windows Update) | Drivers e Atualizações | Sim |
| 18 | Backup dos drivers | Drivers e Atualizações | Sim |
| 19 | Procurar atualizações do Windows | Drivers e Atualizações | Sim |
| 20 | Ver registro de ações deste PC | TI | Não |
| A | Reabrir o painel como Administrador | — | — |
| 0 | Sair | — | — |

---

## Requisitos

- Windows 10 ou Windows 11
- Windows PowerShell 5.1 (já incluso no Windows) — usado nas funções 6, 13, 15 e 16
- Permissão de administrador para as funções marcadas na tabela acima
- Acesso à internet para as funções 4 (DISM RestoreHealth), 9, 17 e 19

---

## Como usar

1. Baixe o arquivo `Painel_Suporte_TI.bat` (ou clone o repositório):
   ```bash
   git clone https://github.com/leoazevdo/it-support-panel.git
   ```
2. Clique com o **botão direito** no arquivo e escolha **Executar como administrador**.
3. Digite o número da opção desejada e pressione **Enter**.
4. Digite `0` para sair.

> Se abrir sem privilégios de administrador, o painel continua funcionando para as funções de consulta. Use a opção **[A]** para reabri-lo elevado.

---

## Controle de permissão (administrador)

Ao iniciar, o script verifica se está rodando como administrador (`net session`) e mostra o resultado no cabeçalho:

- `Permissão: ADMINISTRADOR` — todas as funções liberadas.
- `Permissão: USUÁRIO COMUM` — as funções críticas ficam bloqueadas.

Ao tentar uma função crítica sem privilégio, o painel exibe a mensagem de **acesso negado**, registra a tentativa no log e volta ao menu, sem executar nada.

---

## Registro de ações (log)

Cada ação executada (e cada tentativa bloqueada) é gravada em:

```
C:\ProgramData\Painel_Suporte_TI\registro_acoes.log
```

Se a pasta não puder ser criada, o log é gravado em `%TEMP%`.

Formato de cada linha:

```
[data hora] NOME_DO_PC / usuario - descrição da ação
```

O log pode ser consultado pela opção **[20]** do menu.

---

## Detalhes das funções

### Manutenção do sistema

- **[1] Arquivos temporários** — limpa `%TEMP%`, `C:\Windows\Temp` e `C:\Windows\Prefetch`. Arquivos em uso são ignorados.
- **[2] Limpeza de disco avançada** — abre a configuração do `cleanmgr` (`/sageset`) para você escolher os itens e executa a limpeza (`/sagerun`).
- **[3] SFC** — executa `sfc /scannow`.
- **[4] DISM** — executa `CheckHealth`, `ScanHealth` e `RestoreHealth`.
- **[5] CHKDSK** — roda `chkdsk C: /scan` (online) e oferece agendar `/f /r` para o próximo boot.
- **[6] Saúde do disco** — lista discos físicos (modelo, tipo, saúde) e volumes (espaço livre/total).

### Rede e Internet

- **[7] Reset de rede** — `netsh winsock reset`, `netsh int ip reset`, `ipconfig /release`, `/renew`, `/flushdns` e `/registerdns`. Pede confirmação; reinicie o PC depois.
- **[8] Informações de rede** — `ipconfig /all`.
- **[9] Conectividade** — testa loopback, gateway padrão, internet por IP (8.8.8.8) e resolução de nomes (google.com).
- **[10] Cache DNS** — `ipconfig /flushdns`.
- **[11] Conexões de rede** — abre `ncpa.cpl`.

### Impressão

- **[12] Fila travada** — para o serviço *Spooler*, apaga `C:\Windows\System32\spool\PRINTERS\*` e reinicia o serviço.
- **[13] Impressoras** — lista nome, driver, porta e status.

### Diagnóstico

- **[14] Informações do sistema** — `systeminfo`.
- **[15] Recursos e processos** — abre o Monitor de Recursos e lista os 15 processos que mais consomem memória.

### Drivers e atualizações

- **[16] Dispositivos com erro** — lista dispositivos PnP com status diferente de `OK`.
- **[17] Atualizar drivers** — `pnputil /scan-devices` e abre as atualizações opcionais do Windows Update.
- **[18] Backup dos drivers** — exporta com `DISM /Export-Driver` para `C:\Backup_Drivers\NOMEDOPC_AAAAMMDD_HHMMSS`.
- **[19] Atualizações do Windows** — `usoclient StartScan` e abre o Windows Update.

---

## Estrutura do repositório

```
.
├── Painel_Suporte_TI.bat   # script principal
├── README.md                                # documentação (português - BR)
├── README.en.md                             # documentation (English)
└── LICENSE                                  # licença MIT
```

---

## Personalização

- **Nome no cabeçalho:** o título e o cabeçalho do menu exibem `********` como espaço reservado; substitua pelo nome que preferir (`title` e a linha do cabeçalho).
- **Local do log:** edite a variável `LOGDIR` no início do script.
- **Pasta de backup de drivers:** edite a variável `DEST` na seção `:OPT18`.
- **Funções críticas:** para exigir ou liberar admin em uma opção, adicione ou remova estas duas linhas no início do bloco da opção:
  ```bat
  call :RequireAdmin
  if errorlevel 1 goto MENU
  ```
- **Nova função:** crie um novo rótulo `:OPTxx`, adicione o `if "%OPC%"=="xx" goto OPTxx` e a linha correspondente no menu.

---

## Avisos importantes

- O script executa comandos que alteram o sistema (limpeza de arquivos, reset de rede, reparo de disco). **Teste em um computador de homologação antes de usar em produção.**
- O **reset de rede (7)** derruba a conexão temporariamente e deve ser seguido de reinicialização.
- O **CHKDSK com `/f /r`** pode demorar bastante no próximo boot, conforme o tamanho e a condição do disco.
- Faça **backup** dos dados importantes antes de reparos de disco ou de imagem do Windows.
- O uso é de responsabilidade do operador. O projeto é fornecido "como está", sem garantias.

---

## Solução de problemas

| Problema | Possível causa / solução |
|----------|--------------------------|
| "Acesso negado" ao escolher uma opção | O painel não está elevado. Use **[A]** ou execute como administrador. |
| Caracteres estranhos no menu | O arquivo foi salvo com codificação diferente. Mantenha o script em ANSI/ASCII com quebras de linha CRLF. |
| Opções 6, 13, 15 ou 16 sem resultado | Verifique se o PowerShell não está bloqueado por política de grupo. |
| Opção 4 (DISM) falha | Confirme a conexão com a internet e com o Windows Update. |
| O log não é criado | Execute como administrador ou verifique permissões em `C:\ProgramData`. |

---

## Contribuindo

1. Faça um *fork* do repositório.
2. Crie uma branch: `git checkout -b minha-melhoria`.
3. Faça o commit: `git commit -m "Descreve a melhoria"`.
4. Envie: `git push origin minha-melhoria`.
5. Abra um *Pull Request*.

> Ao editar o `.bat`, mantenha as quebras de linha em **CRLF** e evite acentos nos textos do menu para não gerar caracteres quebrados no CMD.

---

## Licença

Distribuído sob a licença **MIT**. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Autor:** Leonardo Azevedo
