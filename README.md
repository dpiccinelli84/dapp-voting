# DApp di Voto NFT-Gated

Questa è un'applicazione decentralizzata (DApp) che implementa un sistema di voto **riservato ai possessori di un NFT**. Il progetto evolve il concetto di voto su blockchain, legando il diritto di partecipazione alla proprietà di un asset digitale unico, trasformandolo in un sistema di governance per community esclusive.

## Come Funziona: Architettura a due Contratti

A differenza di un sistema a contratto singolo, questa DApp utilizza un'architettura a due smart contract per separare la gestione delle iscrizioni dalla logica di voto:

1.  **`Membership.sol` (Contratto ERC721):**
    *   È un contratto standard per token non fungibili (NFT).
    *   Ogni NFT emesso da questo contratto agisce come una **tessera di iscrizione digitale**.
    *   Solo l'amministratore del sistema può creare (`mint`) nuovi NFT e assegnarli agli indirizzi degli utenti.

2.  **`Voting.sol` (Contratto di Voto):**
    *   Contiene la logica per creare sondaggi e contare i voti.
    *   **Prima di accettare un voto**, questo contratto interroga il contratto `Membership` per verificare che l'indirizzo del votante possieda almeno un NFT. Se non lo possiede, il voto viene respinto.

---

## Stack Tecnologico

*   **Smart Contract:** Solidity (con OpenZeppelin per standard ERC721 e Ownable)
*   **Ambiente di Sviluppo Ethereum:** Hardhat
*   **Blockchain Locale:** Ganache (per un ambiente di sviluppo stabile)
*   **Libreria di Interazione (Frontend):** Ethers.js
*   **Frontend:** HTML, CSS, JavaScript
*   **Wallet:** MetaMask

---

## Istruzioni per l'Esecuzione Locale

Questa guida garantisce un avvio pulito e funzionante del progetto.

### Prerequisiti

1.  **Node.js:** Assicurati di avere installato Node.js (versione 16 o successiva).
2.  **Ganache:** Installa Ganache a livello globale. Se non lo hai già fatto, esegui:
    ```bash
    # Potrebbe essere necessario usare 'sudo' a seconda della configurazione del tuo sistema
    npm install -g ganache
    ```
3.  **MetaMask:** Installa l'estensione per browser MetaMask.

### Passo 1: Installazione delle Dipendenze

Apri un terminale nella cartella principale del progetto ed esegui:
```bash
npm install
```

### Passo 2: Avvio della Blockchain Locale (Ganache)

In un terminale, avvia la blockchain Ganache con il nostro script personalizzato.
```bash
npm run start-chain
```
Vedrai una lista di account di test con le loro chiavi private. **Lascia questo terminale aperto.**

### Passo 3: Deploy degli Smart Contract

Apri un **secondo terminale** ed esegui lo script di deploy:
```bash
npx hardhat run scripts/deploy.js --network localhost
```
Questo comando:
1.  Compilerà i contratti.
2.  Pubblicherà `Membership.sol` e `Voting.sol` sulla tua blockchain Ganache.
3.  **Assegnerà automaticamente un NFT di prova** ai primi account di test.
4.  Creerà/aggiornerà il file `frontend/contractInfo.js` con le informazioni necessarie al frontend.

### Passo 4: Configurazione di MetaMask

1.  **Aggiungi la Rete Ganache a MetaMask:**
    *   `Impostazioni > Reti > Aggiungi rete > Aggiungi una rete manualmente`
    *   **Nome rete:** `Ganache Locale`
    *   **Nuovo URL RPC:** `http://127.0.0.1:8545`
    *   **ID catena:** `1337`
    *   **Simbolo valuta:** `ETH`

2.  **Importa gli Account di Test:**
    *   Nel terminale di Ganache, copia la **chiave privata** del primo account (`(0)`). In MetaMask, importa l'account. Questo sarà l'**Amministratore**.
    *   Fai lo stesso per il secondo account (`(1)`). Questo sarà un **Votante** che possiede già un NFT.

### Passo 5: Avvio del Frontend

Se vuoi, puoi usare un semplice server Python per servire il frontend. In un **terzo terminale**:
```bash
# Questo comando serve la cartella 'frontend' sulla porta 8000
python3 -m http.server 8000 --directory frontend
```
Altrimenti, puoi semplicemente aprire il file `frontend/index.html` direttamente nel tuo browser.

### Passo 6: Utilizzo della DApp

1.  **Apri il Browser:** Naviga a `http://localhost:8000` (se usi il server Python) o apri il file `index.html`.

2.  **Connetti come Amministratore:**
    *   Clicca su "Connetti Wallet" e scegli l'account dell'Amministratore.
    *   Vedrai il pannello di amministrazione. Da qui puoi **creare nuovi NFT** per altri indirizzi o **avviare un sondaggio**.

3.  **Vota come Membro:**
    *   In MetaMask, cambia account e seleziona il Votante.
    *   Ricarica la pagina. Il pannello di amministrazione sarà nascosto, ma potrai votare.

4.  **Testa un Utente non Membro:**
    *   Importa un altro account da Ganache (es. il terzo) che non ha ricevuto un NFT.
    *   Connettilo alla DApp. Vedrai lo stato "Non Membro" e non potrai votare.
